DECLARE	@VoucherNumber	Varchar(25),
		@Company		Varchar(5),
		@AccountNumber	Varchar(15),
		@AccountIndex	Int,
		@Division		Char(2)

SET		@VoucherNumber	= '00000000000025630'
SET		@Company		= 'NDS'
SET		@AccountNumber	= '25-09-1107'
SET		@Division		= '09'
SET		@AccountIndex	= (SELECT ACTINDX FROM NDS.dbo.GL00105 WHERE ACTNUMST = @AccountNumber)

SELECT	*
FROM	EscrowTransactions
WHERE	companyid = @Company
		AND AccountNumber = @AccountNumber
		AND VoucherNumber = @VoucherNumber

INSERT INTO [dbo].[EscrowTransactions]
		([Source]
		,[VoucherNumber]
		,[ItemNumber]
		,[CompanyId]
		,[Fk_EscrowModuleId]
		,[AccountNumber]
		,[AccountType]
		,[VendorId]
		,[DriverId]
		,[Division]
		,[Amount]
		,[ClaimNumber]
		,[DriverClass]
		,[AccidentType]
		,[Status]
		,[DMSubmitted]
		,[DeductionPlan]
		,[Comments]
		,[ProNumber]
		,[TransactionDate]
		,[PostingDate]
		,[EnteredBy]
		,[EnteredOn]
		,[ChangedBy]
		,[ChangedOn]
		,[Void]
		,[BatchId])
SELECT	'AP' AS Source
		,PMH.VCHRNMBR AS VoucherNumber
		,PMD.DSTSQNUM AS ItemNumber
		,@Company AS CompanyId
		,5 AS Fk_EscrowModuleId
		,@AccountNumber AS AccountNumber
		,PMD.DISTTYPE AS AccountType
		,PMH.VENDORID
		,PMH.VENDORID AS DriverId
		,@Division AS Division
		,CASE WHEN PMD.CRDTAMNT <> 0 THEN PMD.CRDTAMNT * -1 ELSE PMD.DEBITAMT END AS Amount
		,Null AS ClaimNumber
		,Null AS DriverClass
		,Null AS AccidentType
		,0 AS Status
		,1 AS DMSubmitted
		,'03/12' AS DeductionPlan
		,PMD.DistRef AS Comments
		,Null AS ProNumber
		,PMH.DOCDATE AS TransactionDate
		,PMD.PSTGDATE AS PostingDate
		,PMH.MDFUSRID AS EnteredBy
		,GETDATE() AS EnteredOn
		,PMH.MDFUSRID AS ChangedBy
		,GETDATE() AS ChangedOn
		,0 AS Void
		,PMH.BACHNUMB AS BatchId
FROM	NDS.dbo.PM30200 PMH
		INNER JOIN NDS.dbo.PM30600 PMD ON PMH.VCHRNMBR = PMD.VCHRNMBR AND PMH.TRXSORCE = PMD.TRXSORCE
		LEFT JOIN EscrowTransactions ESC ON PMH.VCHRNMBR = ESC.VoucherNumber AND PMD.DSTSQNUM = ESC.ItemNumber
WHERE	PMH.VCHRNMBR = @VoucherNumber
		AND PMD.DSTINDX = @AccountIndex
		AND ESC.EscrowTransactionId IS Null