USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_Report_EscrowDetailTrialBalance]    Script Date: 04/10/2008 15:23:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXECUTE USP_Report_EscrowDetailTrialBalance 'AIS', 6, NULL, '10/01/2007', '11/03/2007', NULL, 'CFLORES', 1
-- EXECUTE USP_Report_EscrowDetailTrialBalance 'AIS', 8, NULL, '10/01/2007', '03/17/2008', 'A0071', 'CFLORES', 1, 0

ALTER PROCEDURE [dbo].[USP_Report_EscrowDetailTrialBalance]
		@CompanyId		Char(6), 
		@EscrowModule	Int,
		@Account		Char(15) = Null,
		@DateIni		DateTime,
		@DateEnd		DateTime,
		@VendorId		Char(10) = Null,
		@UserId			Varchar(25),
		@ReportId		Int = 1,
		@HideZeros		Bit = 0
AS
DECLARE	@IniDate		Char(10),
		@EndDate		Char(22),
		@Query			Varchar(5000),
		@Query2			Varchar(1000),
		@Query3			Varchar(3000),
		@QryVendor		Varchar(500)

SET	@CompanyId = RTRIM(@CompanyId)

DELETE EscrowBalancesReport WHERE UserId = @UserId

SET	@CompanyId = RTRIM(@CompanyId)

UPDATE	EscrowTransactions
SET	AccountNumber = SUBSTRING(AccountNumber, 1, 1) + '-' + SUBSTRING(AccountNumber, 2, 2) + '-' + SUBSTRING(AccountNumber, 4, 4) 
WHERE 	PATINDEX('%-%', AccountNumber) = 0 AND 
	LEN(AccountNumber) > 1

IF @CompanyId = 'AIS'
BEGIN
	DELETE 	Purchasing_Vouchers
	FROM	Purchasing_Vouchers
		INNER JOIN (SELECT Purchasing_Vouchers.VoucherNumber,
			MIN(VoucherLineId) AS VoucherLineId
		FROM	Purchasing_Vouchers
			INNER JOIN (SELECT VoucherNumber, 
						COUNT(VoucherNumber) AS Counter 
				FROM 	Purchasing_Vouchers 
				WHERE	CompanyId = RTRIM(@CompanyId)
				GROUP BY VoucherNumber 
				HAVING COUNT(VoucherNumber) > 1) DU ON Purchasing_Vouchers.VoucherNumber = DU.VoucherNumber
		WHERE	Purchasing_Vouchers.CompanyId = RTRIM(@CompanyId)
		GROUP BY Purchasing_Vouchers.VoucherNumber) DU ON Purchasing_Vouchers.VoucherNumber = DU.VoucherNumber
	WHERE	Purchasing_Vouchers.VoucherLineId > DU.VoucherLineId AND
		Purchasing_Vouchers.VoucherNumber = DU.VoucherNumber AND
		Purchasing_Vouchers.CompanyId = RTRIM(@CompanyId)

	UPDATE 	EscrowTransactions
	SET	ItemNumber = T1.DstSqNum,
		PostingDate = CASE WHEN PostingDate IS NULL THEN T1.PstgDate ELSE EscrowTransactions.PostingDate END,
		Amount = CASE WHEN (Amount < 0 AND T1.TAmount < 0) OR (Amount > 0 AND T1.TAmount > 0) THEN Amount ELSE Amount * T1.AmountSign END
	FROM	(SELECT	ET.EscrowTransactionId,
		PD.Vchrnmbr AS Vchrnmbr,
		PD.PstgDate AS PstgDate,
		PD.DstSqNum AS DstSqNum,
		CASE WHEN ET.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9) THEN CASE WHEN PD.CrdTAmnt <> 0 THEN 1 ELSE -1 END
		ELSE CASE WHEN PD.CrdTAmnt <> 0 THEN -1 ELSE 1 END END AS AmountSign,
		CASE WHEN ET.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9) THEN CASE WHEN PD.CrdTAmnt <> 0 THEN PD.CrdTAmnt ELSE PD.DebitAmt * -1 END
		ELSE CASE WHEN PD.CrdTAmnt <> 0 THEN PD.CrdTAmnt * -1 ELSE PD.DebitAmt END END AS TAmount,
		PD.DstIndx,
		EA.AccountNumber
	FROM 	EscrowTransactions ET
		INNER JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId
		INNER JOIN AIS.dbo.PM30200 PH ON (VoucherNumber = PH.Vchrnmbr OR VoucherNumber = PH.DocNumbr)
		INNER JOIN AIS.dbo.PM30600 PD ON PH.Vchrnmbr = PD.Vchrnmbr AND EA.AccountIndex = PD.DstIndx AND ET.AccountType = PD.DistType
	WHERE 	ET.CompanyID = RTRIM(@CompanyId) AND
		PD.Vchrnmbr IS NOT Null AND
		ET.Source = 'AP' AND
		ET.PostingDate IS Null) T1
	WHERE	EscrowTransactions.EscrowTransactionId = T1.EscrowTransactionId

	UPDATE 	EscrowTransactions
	SET	PostingDate = CASE WHEN PostingDate IS NULL THEN T1.PstgDate ELSE EscrowTransactions.PostingDate END
	FROM	(SELECT	ET.EscrowTransactionId,
		PH.PstgDate AS PstgDate
	FROM 	EscrowTransactions ET
		INNER JOIN AIS.dbo.PM20000 PH ON Vchrnmbr = RTRIM(VoucherNumber) OR DocNumbr = RTRIM(VoucherNumber)
	WHERE 	ET.CompanyID = @CompanyId AND
		ET.Source = 'AP' AND
		ET.PostingDate IS Null) T1
	WHERE	EscrowTransactions.EscrowTransactionId = T1.EscrowTransactionId

	UPDATE	EscrowTransactions
	SET	PostingDate = SO.GLPostDt
	FROM	(SELECT SH.SopNumbe, SH.GLPostDt
		FROM 	EscrowTransactions ET
			INNER JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId
			INNER JOIN AIS.DBO.SOP30200 SH ON ET.VoucherNumber = SH.SopNumbe
		WHERE	ET.Source = 'SO' AND
			ET.PostingDate IS Null) SO
	WHERE	EscrowTransactions.VoucherNumber = SO.SopNumbe

	UPDATE 	EscrowTransactions
	SET	PostingDate = CASE WHEN EscrowTransactions.Source = 'GL' THEN T1.TrxDate ELSE T1.OrPstDdt END
	FROM	(SELECT	TD.OrPstDdt,
			TD.TrxDate,
			ET.EscrowTransactionId
		FROM	AIS.dbo.GL20000 TD
			INNER JOIN GPCustom.dbo.EscrowAccounts EA ON TD.ActIndx = EA.AccountIndex AND EA.CompanyId = RTRIM(@CompanyId)
			LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON TD.JrnEntry = ET.VoucherNumber AND TD.SeqNumbr = ET.ItemNumber AND ET.AccountType = 99 AND ET.Source = 'GL'
		WHERE	LEFT(TD.TrxSorce, 5) = 'GLTRX' AND
			TD.Voided = 0 AND
			ET.VoucherNumber IS NOT NULL AND
			ET.PostingDate IS NULL) T1
		WHERE	EscrowTransactions.EscrowTransactionId = T1.EscrowTransactionId
END

IF @CompanyId = 'IMCT'
BEGIN
	DELETE 	Purchasing_Vouchers
	FROM	Purchasing_Vouchers
		INNER JOIN (SELECT Purchasing_Vouchers.VoucherNumber,
				MIN(VoucherLineId) AS VoucherLineId
		FROM	Purchasing_Vouchers
			INNER JOIN (SELECT VoucherNumber, 
						COUNT(VoucherNumber) AS Counter 
				FROM 	Purchasing_Vouchers 
				WHERE	CompanyId = RTRIM(@CompanyId)
				GROUP BY VoucherNumber 
				HAVING COUNT(VoucherNumber) > 1) DU ON Purchasing_Vouchers.VoucherNumber = DU.VoucherNumber
		WHERE	Purchasing_Vouchers.CompanyId = RTRIM(@CompanyId)
		GROUP BY Purchasing_Vouchers.VoucherNumber) DU ON Purchasing_Vouchers.VoucherNumber = DU.VoucherNumber
	WHERE	Purchasing_Vouchers.VoucherLineId > DU.VoucherLineId AND
		Purchasing_Vouchers.VoucherNumber = DU.VoucherNumber AND
		Purchasing_Vouchers.CompanyId = RTRIM(@CompanyId)

	UPDATE 	EscrowTransactions
	SET	ItemNumber = T1.DstSqNum,
		PostingDate = CASE WHEN PostingDate IS NULL THEN T1.PstgDate ELSE EscrowTransactions.PostingDate END,
		Amount = CASE WHEN (Amount < 0 AND T1.TAmount < 0) OR (Amount > 0 AND T1.TAmount > 0) THEN Amount ELSE Amount * T1.AmountSign END
	FROM	(SELECT	ET.EscrowTransactionId,
		PD.Vchrnmbr AS Vchrnmbr,
		PD.PstgDate AS PstgDate,
		PD.DstSqNum AS DstSqNum,
		CASE WHEN ET.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9) THEN CASE WHEN PD.CrdTAmnt <> 0 THEN 1 ELSE -1 END
		ELSE CASE WHEN PD.CrdTAmnt <> 0 THEN -1 ELSE 1 END END AS AmountSign,
		CASE WHEN ET.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9) THEN CASE WHEN PD.CrdTAmnt <> 0 THEN PD.CrdTAmnt ELSE PD.DebitAmt * -1 END
		ELSE CASE WHEN PD.CrdTAmnt <> 0 THEN PD.CrdTAmnt * -1 ELSE PD.DebitAmt END END AS TAmount,
		PD.DstIndx,
		EA.AccountNumber
	FROM 	EscrowTransactions ET
		INNER JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId
		INNER JOIN IMCT.dbo.PM30200 PH ON (VoucherNumber = PH.Vchrnmbr OR VoucherNumber = PH.DocNumbr)
		INNER JOIN IMCT.dbo.PM30600 PD ON PH.Vchrnmbr = PD.Vchrnmbr AND EA.AccountIndex = PD.DstIndx AND ET.AccountType = PD.DistType
	WHERE 	ET.CompanyID = RTRIM(@CompanyId) AND
		PD.Vchrnmbr IS NOT Null AND
		ET.Source = 'AP' AND
		ET.PostingDate IS Null) T1
	WHERE	EscrowTransactions.EscrowTransactionId = T1.EscrowTransactionId

	UPDATE 	EscrowTransactions
	SET	PostingDate = CASE WHEN PostingDate IS NULL THEN T1.PstgDate ELSE EscrowTransactions.PostingDate END
	FROM	(SELECT	ET.EscrowTransactionId,
		PH.PstgDate AS PstgDate
	FROM 	EscrowTransactions ET
		INNER JOIN IMCT.dbo.PM20000 PH ON Vchrnmbr = RTRIM(VoucherNumber) OR DocNumbr = RTRIM(VoucherNumber)
	WHERE 	ET.CompanyID = @CompanyId AND
		ET.Source = 'AP' AND
		ET.PostingDate IS Null) T1
	WHERE	EscrowTransactions.EscrowTransactionId = T1.EscrowTransactionId

	UPDATE	EscrowTransactions
	SET	PostingDate = SO.GLPostDt
	FROM	(SELECT SH.SopNumbe, SH.GLPostDt
		FROM 	EscrowTransactions ET
			INNER JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId
			INNER JOIN IMCT.DBO.SOP30200 SH ON ET.VoucherNumber = SH.SopNumbe
		WHERE	ET.Source = 'SO' AND
			ET.PostingDate IS Null) SO
	WHERE	EscrowTransactions.VoucherNumber = SO.SopNumbe

	UPDATE 	EscrowTransactions
	SET	PostingDate = CASE WHEN EscrowTransactions.Source = 'GL' THEN T1.TrxDate ELSE T1.OrPstDdt END
	FROM	(SELECT	TD.OrPstDdt,
			TD.TrxDate,
			ET.EscrowTransactionId
		FROM	IMCT.dbo.GL20000 TD
			INNER JOIN GPCustom.dbo.EscrowAccounts EA ON TD.ActIndx = EA.AccountIndex AND EA.CompanyId = RTRIM(@CompanyId)
			LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON TD.JrnEntry = ET.VoucherNumber AND TD.SeqNumbr = ET.ItemNumber AND ET.AccountType = 99 AND ET.Source = 'GL'
		WHERE	LEFT(TD.TrxSorce, 5) = 'GLTRX' AND
			TD.Voided = 0 AND
			ET.VoucherNumber IS NOT NULL AND
			ET.PostingDate IS NULL) T1
		WHERE	EscrowTransactions.EscrowTransactionId = T1.EscrowTransactionId
END

IF @Account IS Null
	SET	@Query2 = ''
ELSE
	SET	@Query2 = 'E1.AccountNumber = ''' + RTRIM(@Account) + ''' AND '

IF @VendorId IS Null
	SET	@QryVendor = ''
ELSE
	SET 	@QryVendor = 'ET.VendorId = ''' + RTRIM(@VendorId) + ''' AND '

SET	@IniDate	= CONVERT(Char(10), @DateIni, 101)
SET	@EndDate	= CONVERT(Char(10), @DateEnd, 101) + ' 11:59:59 PM'

SET	@Query3		= 'UPDATE EscrowTransactions SET EscrowTransactions.PostingDate = T1.PstgDate FROM (SELECT P1.* FROM EscrowTransactions LEFT JOIN ' + @CompanyId + '.dbo.PM10000 P1 ON 
	EscrowTransactions.VoucherNumber = P1.Vchrnmbr WHERE CompanyID = ''' + @CompanyId + ''' AND P1.Vchrnmbr IS NOT Null) T1 WHERE EscrowTransactions.VoucherNumber = T1.Vchrnmbr AND EscrowTransactions.PostingDate IS NULL'
EXECUTE(@Query3)

SET	@Query3		= 'UPDATE EscrowTransactions SET EscrowTransactions.PostingDate = T1.PstgDate FROM (SELECT P1.* FROM EscrowTransactions LEFT JOIN ' + @CompanyId + '.dbo.PM20000 P1 ON 
	EscrowTransactions.VoucherNumber = P1.Vchrnmbr WHERE CompanyID = ''' + @CompanyId + ''' AND P1.Vchrnmbr IS NOT Null) T1 WHERE EscrowTransactions.VoucherNumber = T1.Vchrnmbr AND EscrowTransactions.PostingDate IS NULL'
EXECUTE(@Query3)

-- Calculate Balance
IF @EscrowModule = 5 AND @ReportId = 2
		SET @Query3	= 'SELECT E1.AccountNumber, COALESCE(E1.ProNumber, PV.ProNumber, ''BLANK'') AS ProNumber, SUM(E1.Amount) AS Balance 
				FROM EscrowTransactions E1
				LEFT JOIN Purchasing_Vouchers PV ON E1.CompanyId = PV.CompanyId AND E1.VoucherNumber =  PV.VoucherNumber
				WHERE ' + @Query2 + 'E1.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND E1.Fk_EscrowModuleId = 5 ' + 
				' AND E1.PostingDate < ''' + @IniDate + ''' GROUP BY E1.AccountNumber, COALESCE(E1.ProNumber, PV.ProNumber, ''BLANK'')'
	ELSE
		SET @Query3	= 'SELECT E1.AccountNumber, E1.VendorId, SUM(E1.Amount) AS Balance 
				FROM EscrowTransactions E1 WHERE ' + @Query2 + 'CompanyId = ''' + RTRIM(@CompanyId) + ''' AND Fk_EscrowModuleId = ' + 
				RTRIM(CAST(@EscrowModule AS Char(10))) + ' AND E1.PostingDate < ''' + @IniDate + ''' GROUP BY E1.AccountNumber, E1.VendorId'
--EXECUTE (@Query3)
SET	@Query2 = REPLACE(@Query2, 'E1', 'ET')

SET 	@Query 		= 'INSERT INTO EscrowBalancesReport SELECT DISTINCT ET.*, dbo.Proper(COALESCE(G0.Refrence, P0.DistRef, P1.TrxDscrn, P2.TrxDscrn, ET.Comments, '' '')) AS TransDescription, CmpnyNam AS CompanyName, LEFT(dbo.PROPER(VendName), 40) AS VendName, ISNULL(BA.Balance, 0.00) AS Balance, UPPER(GL.ActDescr) AS ActDescr, 
	PV.ProNumber AS ProNumberMain, PV.ChassisNumber, PV.TrailerNumber, COALESCE(P1.DocNumbr, P2.DocNumbr, '' '') AS DocNumber, ET.PostingDate, ''' + RTRIM(@UserId) + ''' AS UserId, EM.ModuleDescription AS Module
	FROM EscrowTransactions ET
	LEFT JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId 
	LEFT JOIN Purchasing_Vouchers PV ON ET.CompanyId = PV.CompanyId AND ET.VoucherNumber = PV.VoucherNumber 
	LEFT JOIN EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
	LEFT JOIN ' + @CompanyId + '.dbo.PM30600 P0 ON ET.VoucherNumber = P0.Vchrnmbr AND ET.AccountType = P0.DistType AND ET.ItemNumber = P0.DstSqNum
	LEFT JOIN ' + @CompanyId + '.dbo.PM20000 P1 ON ET.VoucherNumber = P1.Vchrnmbr AND ET.VendorId = P1.VendorId
	LEFT JOIN ' + @CompanyId + '.dbo.PM10000 P2 ON ET.VoucherNumber = P2.VchnumWk AND ET.VendorId = P2.VendorId
	LEFT JOIN ' + @CompanyId + '.dbo.GL30000 G0 ON ET.VoucherNumber = CAST(G0.JrnEntry AS Char(20)) AND G0.SourcDoc <> ''PMTRX''
	LEFT JOIN ' + @CompanyId + '.dbo.PM00200 VE ON ET.VendorId = VE.VendorId
	LEFT JOIN ' + @CompanyId + '.dbo.GL00100 GL ON EA.AccountIndex = GL.ActIndx 
	LEFT JOIN Dynamics.dbo.View_AllCompanies CO ON ET.CompanyID = CO.InterID '

	IF @EscrowModule = 5 AND @ReportId = 2
		SET @Query = @Query + 'FULL OUTER JOIN (' + @Query3 + ') BA ON ET.AccountNumber = BA.AccountNumber AND ISNULL(PV.ProNumber, ''BLANK'') = BA.ProNumber WHERE '
	ELSE
		SET @Query = @Query + 'FULL OUTER JOIN (' + @Query3 + ') BA ON ET.AccountNumber = BA.AccountNumber AND ET.VendorId = BA.VendorId WHERE '

	SET @Query = @Query + @Query2 + @QryVendor + 'ET.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND ET.Fk_EscrowModuleId = ' + RTRIM(CAST(@EscrowModule AS Char(10))) +
	' AND ET.PostingDate BETWEEN ''' + @IniDate + ''' AND ''' + @EndDate + ''' AND ET.PostingDate IS NOT Null ORDER BY ET.AccountNumber, ET.VendorId, ET.PostingDate, ET.VoucherNumber'
PRINT @Query
EXECUTE (@Query)

--IF @EscrowModule NOT IN (6)
--BEGIN
	IF @EscrowModule = 5 AND @ReportId = 2
	BEGIN
		SET	@Query3	= 'INSERT INTO EscrowBalancesReport (TransDescription, CompanyId, AccountNumber, Balance, ProNumber, UserId)
			SELECT DISTINCT ''BALANCE'', ''' + RTRIM(@CompanyId) + ''', ET.AccountNumber, SUM(ET.Amount) AS Balance, ISNULL(ET.ProNumber, PV.ProNumber), ''' + RTRIM(@UserId) + '''
			FROM EscrowTransactions ET
			LEFT JOIN Purchasing_Vouchers PV ON ET.CompanyId = PV.CompanyId AND ET.VoucherNumber =  PV.VoucherNumber
			WHERE ' + @QryVendor + @Query2 + 'ET.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND ET.PostingDate IS NOT Null AND Fk_EscrowModuleId = 5 ' + 
			'AND ET.PostingDate < ''' + @IniDate + ''' AND AccountNumber + PV.ProNumber NOT IN ' +
			'(SELECT AccountNumber + ProNumber FROM EscrowBalancesReport WHERE UserId = ''' + RTRIM(@UserId) + ''') 
			GROUP BY ET.AccountNumber, ISNULL(ET.ProNumber, PV.ProNumber)'
	END
	ELSE
	BEGIN
		IF @EscrowModule = 6
		BEGIN
			SET	@Query3	= 'INSERT INTO EscrowBalancesReport (TransDescription, CompanyId, CompanyName, AccountNumber, ActDescr, Balance, ClaimNumber, UserId)
				SELECT DISTINCT ''BALANCE'', ''' + RTRIM(@CompanyId) + ''', CO.CmpnyNam, ET.AccountNumber, UPPER(GL.ActDescr), SUM(ET.Amount) AS Balance, UPPER(ET.ClaimNumber), ''' + RTRIM(@UserId) + '''
				FROM EscrowTransactions ET
				LEFT JOIN Purchasing_Vouchers PV ON ET.CompanyId = PV.CompanyId AND ET.VoucherNumber =  PV.VoucherNumber
				LEFT JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId 
				LEFT JOIN Dynamics.dbo.View_AllCompanies CO ON ET.CompanyID = CO.InterID
				LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.GL00100 GL ON EA.AccountIndex = GL.ActIndx 
				WHERE ' + @QryVendor + @Query2 + 'ET.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND ET.PostingDate IS NOT Null AND ET.Fk_EscrowModuleId = 6 ' + 
				'AND ET.PostingDate < ''' + @IniDate + ''' AND ET.AccountNumber + UPPER(ET.ClaimNumber) NOT IN ' +
				'(SELECT AccountNumber + UPPER(ClaimNumber) FROM EscrowBalancesReport WHERE UserId = ''' + RTRIM(@UserId) + ''') 
				GROUP BY ET.AccountNumber, UPPER(GL.ActDescr), UPPER(ET.ClaimNumber), CO.CmpnyNam '
		END
		ELSE
		BEGIN
			SET	@Query3	= 'INSERT INTO EscrowBalancesReport (TransDescription, CompanyId, ClaimNumber, AccountNumber, VendorId, VendName, UserId, Balance, Module, CompanyName)
				SELECT DISTINCT ''BALANCE'', ''' + RTRIM(@CompanyId) + ''', ''BALANCE'' + ET.VendorId, ET.AccountNumber, ET.VendorId, LEFT(dbo.PROPER(VendName), 40) AS VendName, ''' + RTRIM(@UserId) + ''', SUM(ET.Amount) AS Balance, EM.ModuleDescription, CmpnyNam
				FROM EscrowTransactions ET
				LEFT JOIN EscrowModules EM ON ET.Fk_EscrowModuleId = EM.EscrowModuleId
				LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM20000 P1 ON ET.VoucherNumber = P1.Vchrnmbr 
				LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM10000 P2 ON ET.VoucherNumber = P2.VchnumWk 
				LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM00200 VE ON ET.VendorId = VE.VendorId
				LEFT JOIN Dynamics.dbo.View_AllCompanies CO ON ET.CompanyID = CO.InterID 
				WHERE ' + @QryVendor + @Query2 + 'ET.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND ET.PostingDate IS NOT Null AND Fk_EscrowModuleId = ' + 
				RTRIM(CAST(@EscrowModule AS Char(10))) + ' AND ET.PostingDate < ''' + @IniDate + ''' AND AccountNumber + ET.VendorId NOT IN ' +
				'(SELECT AccountNumber + VendorId FROM EscrowBalancesReport WHERE UserId = ''' + RTRIM(@UserId) + ''') 
				GROUP BY ET.AccountNumber, ET.VendorId, LEFT(dbo.PROPER(VendName), 40), EM.ModuleDescription, CmpnyNam'
		END
	END

	PRINT @Query3
	EXECUTE (@Query3)
--END

UPDATE	EscrowBalancesReport
SET	ProNumber = ProNumberMain
WHERE	(ProNumber IS Null OR ProNumber = '') AND
	UserId = @UserId

IF @ReportId = 2 AND @HideZeros = 1
BEGIN
	IF @Account IS Null
		SELECT 	DISTINCT * 
		FROM 	EscrowBalancesReport 
		WHERE 	UserId = @UserId AND
			CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END IN (
				SELECT	CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END
				FROM	EscrowBalancesReport ES
					INNER JOIN (SELECT CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END AS Pro_Number, 
					Balance AS IniBalance,
					SUM(Amount) AS SumAmount
				FROM 	EscrowBalancesReport WHERE UserId = @UserId
				GROUP BY CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END, Balance
				HAVING	Balance + SUM(Amount) <> 0) SM ON CASE WHEN ES.ProNumber IS Null OR RTRIM(ES.ProNumber) = '' THEN ES.VendorId ELSE ES.ProNumber END = SM.Pro_Number
				WHERE	UserId = @UserId)
		ORDER BY AccountNumber, VendorId, TransactionDate, EscrowTransactionId
	ELSE
		SELECT 	DISTINCT * 
		FROM 	EscrowBalancesReport 
		WHERE 	UserId = @UserId AND 
			AccountNumber = @Account AND
			CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END IN (
				SELECT	CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END
				FROM	EscrowBalancesReport ES
					INNER JOIN (SELECT CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END AS Pro_Number, 
					Balance AS IniBalance,
					SUM(Amount) AS SumAmount
				FROM 	EscrowBalancesReport WHERE UserId = @UserId
				GROUP BY CASE WHEN ProNumber IS Null OR RTRIM(ProNumber) = '' THEN VendorId ELSE ProNumber END, Balance
				HAVING	Balance + SUM(Amount) <> 0) SM ON CASE WHEN ES.ProNumber IS Null OR RTRIM(ES.ProNumber) = '' THEN ES.VendorId ELSE ES.ProNumber END = SM.Pro_Number
				WHERE	UserId = @UserId)
		ORDER BY VendorId, TransactionDate, EscrowTransactionId
END
ELSE
BEGIN
	IF @EscrowModule = 6
	BEGIN
		IF @Account IS Null
			SELECT DISTINCT * FROM EscrowBalancesReport WHERE UserId = @UserId ORDER BY AccountNumber, ClaimNumber, PostingDate
		ELSE
			SELECT DISTINCT * FROM EscrowBalancesReport WHERE UserId = @UserId AND AccountNumber = @Account ORDER BY ClaimNumber, PostingDate
	END
	ELSE
	BEGIN
		IF @ReportId = 1 AND @HideZeros = 1
		BEGIN
			IF @Account IS Null
			BEGIN
				SELECT 	DISTINCT * 
				FROM 	EscrowBalancesReport ER
				WHERE 	UserId = @UserId AND
					ER.AccountNumber + ER.VendorId IN (
						SELECT	AccountNumber + ES.VendorId AS VendorId
						FROM	EscrowBalancesReport ES
							INNER JOIN (SELECT AccountNumber + VendorID AS VendorId, 
							Balance AS IniBalance,
							SUM(Amount) AS SumAmount
						FROM 	EscrowBalancesReport WHERE UserId = @UserId
						GROUP BY AccountNumber + VendorID, Balance
						HAVING	Balance + SUM(Amount) <> 0) SM ON ER.AccountNumber + ER.VendorId = SM.VendorId
						WHERE	UserId = @UserId)
				ORDER BY AccountNumber, ER.VendorId, TransactionDate, EscrowTransactionId
			END
			ELSE
			BEGIN
				SELECT 	DISTINCT * 
				FROM 	EscrowBalancesReport ER
				WHERE 	UserId = @UserId AND 
					AccountNumber = @Account AND
					ER.AccountNumber + ER.VendorId IN (
						SELECT	AccountNumber + ES.VendorId AS VendorId
						FROM	EscrowBalancesReport ES
							INNER JOIN (SELECT AccountNumber + VendorID AS VendorId, 
							Balance AS IniBalance,
							SUM(Amount) AS SumAmount
						FROM 	EscrowBalancesReport WHERE UserId = @UserId
						GROUP BY AccountNumber + VendorID, Balance
						HAVING	Balance + SUM(Amount) <> 0) SM ON ER.AccountNumber + ER.VendorId = SM.VendorId
						WHERE	UserId = @UserId)
				ORDER BY AccountNumber, ER.VendorId, TransactionDate, EscrowTransactionId
			END
		END
		ELSE
		BEGIN
			IF @Account IS Null
				SELECT DISTINCT * FROM EscrowBalancesReport WHERE UserId = @UserId ORDER BY AccountNumber, VendorId, TransactionDate
			ELSE
				SELECT DISTINCT * FROM EscrowBalancesReport WHERE UserId = @UserId AND AccountNumber = @Account ORDER BY VendorId, TransactionDate
		END
	END
END

