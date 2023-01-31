DECLARE	@BatchId		Varchar(30)

DECLARE @tblVendors		Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))

DECLARE @tblData		Table (
		Company			Varchar(5),
		IntegrationType	Varchar(10),
		TransType		Varchar(20),
		CreditAccount	Varchar(15),
		DebitAccount	Varchar(15),
		DataSource		Char(2))

INSERT INTO @tblVendors
SELECT	DISTINCT Company, 
		VendorId,
		'PP'
FROM	PRISQL01P.GPCustom.dbo.GPVendorMaster 
WHERE	PierPassType = 1

DECLARE curFSIBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT BatchId 
FROM	FSI_ReceivedHeader
WHERE	WeekEndDate > '01/01/2021'

OPEN curFSIBatches 
FETCH FROM curFSIBatches INTO @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Batch ' + @BatchId

	INSERT INTO @tblData
	SELECT	DISTINCT FSI.Company,
			'TIP' AS IntegrationType,
			IIF(FSI.ICB = 1, 'ICB', 'TIP') AS TransType,
			FSI.AccountNumber, -- Credit
			FSI.InterAccount, -- Debit
			'AR' AS DataSource
	FROM	View_FSI_Intercompany FSI
			LEFT JOIN TIP_IntegrationRecords TIP ON FSI.RecordId = TIP.TIPIntegrationId
			LEFT JOIN ReceivedIntegrations RCV ON FSI.OriginalBatchId = RCV.BatchId AND RCV.Integration = 'TIP'
	WHERE	FSI.FSIBatchId = @BatchId

	INSERT INTO @tblData
	SELECT	DISTINCT FSI.Company,
			'FSIG' AS IntegrationType,
			CASE WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 THEN 'PREPAY'
				 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN 'ACCRUAL'
				 WHEN FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN 'PIERPASS'
				 WHEN FSI.PerDiemType = 1 THEN 'PERDIEM'
			ELSE 'Unknow' END AS TransactionType,
			CASE WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = FSI.Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSIVENDORDEBACCT', 'FSIVENDORPREPAYDEBACCT'))
				 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = FSI.Company AND ParameterCode = IIF(FSI.AR_PrePayType = 'A', 'FSIACCRUDCREDIT','FSIACCRUDDEBIT'))
				 WHEN FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = FSI.Company AND ParameterCode = 'PIERPASS_ACCT_CREDIT')
				 WHEN FSI.PerDiemType = 1 THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (FSI.Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PRD_DEBITACCOUNT', 'PRD_CREDITACCOUNT'))
			ELSE 'Not Mapped' END AS CreditAccount,
			CASE WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = FSI.Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSIVENDORPREPAYDEBACCT', 'FSIVENDORDEBACCT'))
				 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = FSI.Company AND ParameterCode = IIF(FSI.AR_PrePayType = 'A', 'FSIACCRUDDEBIT','FSIACCRUDCREDIT'))
				 WHEN FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = FSI.Company AND ParameterCode = 'PIERPASS_ACCT_DEBIT')
				 WHEN FSI.PerDiemType = 1 THEN (SELECT REPLACE(VarC, 'DD', RTRIM(FSI.Division)) FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company IN (FSI.Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PRD_CREDITACCOUNT', 'PRD_DEBITACCOUNT'))
			ELSE 'Not Mapped' END AS DebitAccount,
			IIF(FSI.AR_PrePayType = 'A','AR','AP') AS DataType
	FROM	View_Integration_FSI_Full FSI
			LEFT JOIN @tblVendors VND ON FSI.Company = VND.Company AND FSI.RecordCode = VND.VendorCode AND VND.VndType = 'PP'
	WHERE	FSI.BatchId = @BatchId 
			AND FSI.VndIntercompany = 0
			AND (((FSI.RecordType = 'VND' 
				AND ((FSI.PrePay = 1 AND ISNULL(FSI.PrePayType, '') IN ('','P')))
				OR FSI.PrePayType = 'A' 
				OR FSI.PerDiemType = 1 
				OR FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors)))
			OR ((ISNULL(FSI.AR_PrePayType, 'N') = 'A' OR (FSI.RecordType = 'ACC' AND FSI.PerDiemType = 1))))

	INSERT INTO @tblData
	SELECT	Company
			,'FSI'
			,'SALES'
			,Credit = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = FSI.Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSISALESDEBACCT','FSISALESCREACCT'))
			,Debit = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = FSI.Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSISALESCREACCT','FSISALESDEBACCT'))
			,'AR' AS DataSource
	FROM	View_Integration_FSI FSI
	WHERE	FSI.BatchId = @BatchId
			AND FSI.Intercompany = 0
			AND FSI.InvoiceTotal <> 0
			AND FSI.ICB = 0
			AND FSI.PrePayType IS Null

	FETCH FROM curFSIBatches INTO @BatchId
END

CLOSE curFSIBatches
DEALLOCATE curFSIBatches

INSERT INTO @tblData
SELECT	DISTINCT FSIN.Company,
		FSIN.IntegrationType,
		FSIN.TransType,
		FSIN.CreditAccount,
		FSIN.DebitAccount,
		'AP' AS DataSource
FROM	FSI_NonSalesRecords FSIN
		INNER JOIN FSI_ReceivedHeader FSIH ON FSIN.BatchId = FSIH.BatchId
WHERE	FSIH.WeekEndDate > '01/01/2021'
		AND FSIN.IntegrationType = 'FSIP'

SELECT	DISTINCT *
FROM	@tblData
ORDER BY 1,2,3