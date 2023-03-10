/*
EXECUTE USP_UpdateEscrowTransactions
*/
ALTER PROCEDURE [dbo].[USP_UpdateEscrowTransactions]
AS
SET NOCOUNT ON

DECLARE @CompanyId	Varchar(5) = DB_NAME(),
		@StartDate	Date = DATEADD(DD, -8, GETDATE())

IF EXISTS(SELECT TOP 1 AccountNumber FROM GPCustom.dbo.EscrowTransactions WHERE CompanyId = @CompanyId AND EnteredOn >= @StartDate AND PostingDate IS Null AND DeletedOn IS Null)
BEGIN
	DECLARE	@tblTransaction Table (
			EscrowTransactionId	Int,
			AccountNumber		Varchar(20),
			VoucherNumber		Varchar(20),
			TransactionDate		Date,
			PostingDate			Date,
			BatchId				Varchar(25),
			VendorId			Varchar(15),
			Source				Char(2))

	INSERT INTO @tblTransaction
	SELECT	EscrowTransactionId,
			AccountNumber,
			VoucherNumber,
			TransactionDate,
			PostingDate,
			BatchId,
			VendorId,
			Source
	FROM	GPCustom.dbo.EscrowTransactions 
	WHERE	CompanyId = DB_NAME()
			AND EnteredOn >= @StartDate
			AND PostingDate IS Null 
			AND DeletedOn IS Null
	
	IF EXISTS(SELECT TOP 1 Source FROM @tblTransaction WHERE Source = 'AP')
	BEGIN
		UPDATE 	GPCustom.dbo.EscrowTransactions
		SET		PostingDate = T1.PstgDate
		FROM	(
				SELECT	EscrowTransactionId,
						MAX(PstgDate) AS PstgDate
				FROM	(
						SELECT	DISTINCT ET.EscrowTransactionId,
								PH.PstgDate
						FROM 	@tblTransaction ET
								INNER JOIN GL00105 GL ON GL.ACTNUMST = ET.AccountNumber
								INNER JOIN PM10100 PD ON ET.VoucherNumber = PD.VCHRNMBR --AND ET.VendorId = PD.VENDORID
								INNER JOIN PM20000 PH ON PD.VCHRNMBR = PH.VCHRNMBR --AND ET.VendorId = PH.VENDORID
						WHERE 	ET.Source = 'AP'
								AND PH.DOCTYPE <> 6
						UNION
						SELECT	DISTINCT ET.EscrowTransactionId,
								PH.PstgDate
						FROM 	@tblTransaction ET
								INNER JOIN GL00105 GL ON GL.ACTNUMST = ET.AccountNumber
								INNER JOIN PM30600 PD ON ET.VoucherNumber = PD.VCHRNMBR --AND ET.VendorId = PD.VENDORID
								INNER JOIN PM30200 PH ON PD.VCHRNMBR = PH.VCHRNMBR --AND ET.VendorId = PH.VENDORID
						WHERE 	ET.Source = 'AP'
								AND PH.DOCTYPE <> 6
						) ESCR
				GROUP BY EscrowTransactionId
				) T1
		WHERE	EscrowTransactions.EscrowTransactionId = T1.EscrowTransactionId
				AND EscrowTransactions.CompanyId = @CompanyId

		IF @@ROWCOUNT <> 0
			PRINT CAST(@@ROWCOUNT AS Varchar) + ' AP Escrow Tansactions Updated at ' + CONVERT(Varchar, GETDATE(), 109)
	END
		
	IF EXISTS(SELECT TOP 1 Source FROM @tblTransaction WHERE Source = 'GL')
	BEGIN
		UPDATE	GPCustom.dbo.EscrowTransactions
		SET		EscrowTransactions.TransactionDate = RECS.TrxDate,
				EscrowTransactions.PostingDate = RECS.TrxDate
		FROM	(
				SELECT	ET.EscrowTransactionId,
						GL.TrxDate
				FROM	@tblTransaction ET
						INNER JOIN GL00105 AC ON ET.AccountNumber = AC.ActNumSt
						INNER JOIN GL20000 GL ON ET.VoucherNumber = CAST(GL.JrnEntry AS Varchar) AND AC.ActIndx = GL.ActIndx
				WHERE	ET.Source = 'GL'
						AND ET.PostingDate IS Null
				) RECS
		WHERE	EscrowTransactions.EscrowTransactionId = RECS.EscrowTransactionId

		IF @@ROWCOUNT <> 0
			PRINT CAST(@@ROWCOUNT AS Varchar) + ' GL Escrow Tansactions Updated at ' + CONVERT(Varchar, GETDATE(), 109)
	END
		
	IF EXISTS(SELECT TOP 1 Source FROM @tblTransaction WHERE Source IN ('AR','SO'))
	BEGIN
		UPDATE	GPCustom.dbo.EscrowTransactions
		SET		PostingDate = SO.GLPostDt
		FROM	(SELECT	SH.SopNumbe, 
						SH.GLPostDt
				FROM 	@tblTransaction ET
						INNER JOIN SOP30200 SH ON ET.VoucherNumber = SH.SopNumbe
				WHERE	ET.Source IN ('SO')
				UNION
				SELECT	SH.DOCNUMBR, 
						SH.GLPostDt
				FROM 	@tblTransaction ET
						INNER JOIN RM20101 SH ON ET.VoucherNumber = SH.DOCNUMBR
				WHERE	ET.Source IN ('AR')
				UNION
				SELECT	SH.DOCNUMBR, 
						SH.GLPostDt
				FROM 	@tblTransaction ET
						INNER JOIN RM30101 SH ON ET.VoucherNumber = SH.DOCNUMBR
				WHERE	ET.Source IN ('AR')
				) SO
		WHERE	EscrowTransactions.VoucherNumber = SO.SopNumbe
				AND EscrowTransactions.PostingDate IS Null
				AND EscrowTransactions.CompanyID = RTRIM(@CompanyId)

		IF @@ROWCOUNT <> 0
			PRINT CAST(@@ROWCOUNT AS Varchar) + ' AR/SO Escrow Tansactions Updated at ' + CONVERT(Varchar, GETDATE(), 109)
	END
END

IF EXISTS(SELECT TOP 1 DocNumber FROM GPCustom.dbo.ExpenseRecovery WHERE Company = @CompanyId AND EffDate IS Null AND ReceivedOn >= @StartDate)
BEGIN
	SELECT	ExpenseRecoveryId,
			VoucherNo,
			DocNumber,
			Source,
			EffDate
	INTO	##TmpExpenseRecoveryData
	FROM	GPCustom.dbo.ExpenseRecovery
	WHERE	Company = @CompanyId
			AND ReceivedOn >= @StartDate
			AND EffDate IS Null

	UPDATE	GPCustom.dbo.ExpenseRecovery
	SET		EffDate = DAT.PstgDate
	FROM	(
				SELECT	EX.ExpenseRecoveryId,
						PM.PstgDate
				FROM	##TmpExpenseRecoveryData EX
						INNER JOIN PM20000 PM ON EX.VoucherNo = PM.VchrNmbr AND EX.DocNumber = PM.DocNumbr
				WHERE	EX.Source = 'AP'
						AND (PM.PstgDate IS Null
						OR PM.PstgDate <> EX.EffDate)
				UNION
				SELECT	EX.ExpenseRecoveryId,
						PM.PstgDate
				FROM	##TmpExpenseRecoveryData EX
						INNER JOIN PM30200 PM ON EX.VoucherNo = PM.VchrNmbr AND EX.DocNumber = PM.DocNumbr
				WHERE	EX.Source = 'AP'
						AND (PM.PstgDate IS Null
						OR PM.PstgDate <> EX.EffDate)
				UNION
				SELECT	EX.ExpenseRecoveryId,
						PM.ORPstDdt AS PstgDate
				FROM	##TmpExpenseRecoveryData EX
						INNER JOIN GL20000 PM ON EX.VoucherNo = CAST(PM.JRNENTRY AS Varchar)
				WHERE	EX.Source = 'GL'
						AND (PM.ORPstDdt IS Null
						OR PM.ORPstDdt <> EX.EffDate)
			) DAT
	WHERE	ExpenseRecovery.ExpenseRecoveryId = DAT.ExpenseRecoveryId

	DROP TABLE ##TmpExpenseRecoveryData

	IF @@ROWCOUNT <> 0
		PRINT CAST(@@ROWCOUNT AS Varchar) + ' M&R Escrow Tansactions Updated at ' + CONVERT(Varchar, GETDATE(), 109)
END