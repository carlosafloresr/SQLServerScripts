DECLARE	@tblDeductions	Table (
		VendorId		Varchar(15),
		ProNumber		Varchar(15),
		Description		Varchar(100),
		Amount			Numeric(10,2))

INSERT INTO @tblDeductions
SELECT	AGT.VendorId,
		AST.ProNumber,
		AST.Description,
		AST.Amount
FROM	GPCustom.dbo.AgentsSettlementsTransactions AST
		INNER JOIN (
					SELECT	Agent, 
							MAX(VendorId) AS VendorId 
					FROM	GPCustom.dbo.Agents 
					WHERE	Inactive = 0 
							AND VendorId IS NOT Null 
					GROUP BY Agent
					) AGT ON AST.Agent = AGT.Agent
WHERE	AST.WeekendDate = '02/09/2019'
		AND AST.Amount <> 0
		AND AST.Amount IS NOT Null

INSERT INTO GPCustom.dbo.EscrowTransactions
		(Source
		,VoucherNumber
		,ItemNumber
		,CompanyId
		,Fk_EscrowModuleId
		,AccountNumber
		,AccountType
		,VendorId
		,DriverId
		,Division
		,Amount
		,ClaimNumber
		,DriverClass
		,AccidentType
		,Status
		,DMSubmitted
		,DeductionPlan
		,Comments
		,ProNumber
		,TransactionDate
		,PostingDate
		,EnteredBy
		,EnteredOn
		,ChangedBy
		,ChangedOn
		,Void
		,InvoiceNumber
		,BatchId)
SELECT	'AP' AS Source
		,APH.VCHRNMBR AS VoucherNumber
		,APD.DSTSQNUM AS ItemNumber
		,DB_NAME() AS CompanyId
		,ESA.Fk_EscrowModuleId
		,ESA.AccountNumber
		,APD.DISTTYPE
		,APH.VENDORID
		,Null AS DriverId
		,Null AS Division
		,DED.Amount * IIF(APD.CRDTAMNT = ABS(DED.Amount), -1, 1)
		,Null AS ClaimNumber
		,Null AS DriverClass
		,Null AS AccidentType
		,Null AS Status
		,Null AS DMSubmitted
		,Null AS DeductionPlan
		,APD.DistRef AS Comments
		,DED.ProNumber AS ProNumber
		,APH.DOCDATE AS TransactionDate
		,APH.PSTGDATE AS PSTGDATE
		,'CFLORES' AS EnteredBy
		,GETDATE() AS EnteredOn
		,'CFLORES' AS ChangedBy
		,GETDATE() AS ChangedOn
		,0 AS Void
		,DED.ProNumber AS InvoiceNumber
		,APH.BACHNUMB
FROM	PM30200 APH
		INNER JOIN PM30600 APD ON APH.VCHRNMBR = APD.VCHRNMBR AND APH.VENDORID = APD.VENDORID
		INNER JOIN GL00105 GLA ON APD.DSTINDX = GLA.ACTINDX
		INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON ESA.CompanyId = DB_NAME() AND GLA.ACTNUMST = ESA.AccountNumber AND ESA.Fk_EscrowModuleId = 5
		LEFT JOIN @tblDeductions DED ON APD.DistRef = LEFT(DED.Description, 30) AND (APD.CRDTAMNT = ABS(DED.Amount) OR APD.DEBITAMT = DED.Amount)
WHERE	APH.BACHNUMB = 'AGST-20190209'
		AND DED.Amount IS NOT Null

/*
SELECT	*
FROM	EscrowTransactions
WHERE	CompanyId = 'NDS'
		AND EnteredOn > '02/02/2019'
		AND VoucherNumber LIKE 'AGST1902%'
*/