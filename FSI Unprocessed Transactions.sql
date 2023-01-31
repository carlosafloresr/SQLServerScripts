SET NOCOUNT ON

DECLARE	@Company	Varchar(5),
		@BatchId	Varchar(25) = '9FSI20200603_1420'

SET @Company = (SELECT Company FROM IntegrationsDB.Integrations.dbo.FSI_ReceivedHeader WHERE BatchId = @BatchId)

PRINT 'COMPANY: ' + @Company

DECLARE	@Query		Varchar(MAX)
DECLARE @tblVendors	Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))
DECLARE @tblFSIData	Table (
	[Company] [varchar](5) NOT NULL,
	[BatchId] [varchar](25) NOT NULL,
	[WeekEndDate] [smalldatetime] NOT NULL,
	[IntegrationType] [varchar](4) NOT NULL,
	[CustomerNumber] [varchar](10) NOT NULL,
	[InvoiceNumber] [varchar](20) NOT NULL,
	[ApplyTo] [varchar](25) NOT NULL,
	[BillToRef] [varchar](50) NOT NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceTotal] [money] NULL,
	[InvoiceType] [char](1) NULL,
	[Processed] [bit] NOT NULL,
	[Status] [int] NOT NULL,
	[RecordType] [char](3) NOT NULL,
	[RecordCode] [varchar](12) NOT NULL,
	[ChargeAmount1] [money] NULL,
	[ChargeAmount2] [money] NULL,
	[AccCode] [varchar](5) NULL,
	[GPBatchId] [varchar](30) NULL,
	[Intercompany] [bit] NOT NULL,
	[VndIntercompany] [bit] NULL,
	[VendorReference] [varchar](25) NULL,
	[Equipment] [varchar](15) NULL,
	[Prepay] [bit] NULL,
	[PrePayType] [char](1) NULL,
	[AR_PrePayType] [char](1) NOT NULL,
	[ICB_AR] [bit] NOT NULL,
	[ICB_AP] [bit] NULL,
	[PerDiemType] [bit] NULL,
	[PrepayReference] [nvarchar](4000) NULL,
	[TrxDscrn] [varchar](43) NULL,
	[VendorDocument] [nvarchar](30) NULL,
	[VoucherId] [nvarchar](4000) NULL)

INSERT INTO @tblVendors
--SELECT	Company,
--		VarC,
--		'PD'
--FROM	GPCustom.dbo.Parameters 
--WHERE	Company = @Company
--		AND ParameterCode = 'PRD_VENDORCODE'
--UNION
SELECT	Company, 
		VendorId,
		'PP'
FROM	GPCustom.dbo.GPVendorMaster 
WHERE	Company = @Company 
		AND PierPassType = 1

INSERT INTO @tblFSIData
SELECT	Company,
		BatchId,
		WeekEndDate,
		CASE 
			WHEN Intercompany = 1 OR VndIntercompany = 1 THEN 'TIP' 
			WHEN VndIntercompany = 0 AND RecordType = 'VND'
					AND FS.PrePay = 0 
					AND FS.PrePayType IS Null
					AND FS.PerDiemType = 0 
					AND FS.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors)
					THEN 'FSIP'
			WHEN VndIntercompany = 0 AND ((((FS.PrePay = 1 AND ISNULL(FS.PrePayType, '') IN ('','P')))
					OR FS.PrePayType = 'A' 
					OR FS.PerDiemType = 1 
					OR (FS.RecordCode IN (SELECT VendorCode FROM @tblVendors) AND RecordType = 'VND'))
					OR (ISNULL(FS.AR_PrePayType, 'N') = 'A')) 
					THEN 'FSIG'
		ELSE 'FSI' END AS IntegrationType,
		CustomerNumber,
		InvoiceNumber,
		ApplyTo,
		BillToRef,
		InvoiceDate,
		InvoiceTotal,
		InvoiceType,
		Processed,
		Status,
		RecordType, 
		RecordCode,
		ChargeAmount1,
		ChargeAmount2,
		AccCode,
		GPBatchId,
		Intercompany,
		VndIntercompany,
		VendorReference,
		Equipment,
		Prepay,
		PrePayType,
		AR_PrePayType,
		ICB_AR,
		ICB_AP,
		PerDiemType,
		PrepayReference,
		'PN:' + RTRIM(FS.InvoiceNumber) + '/CNT:' + ISNULL(FS.Equipment,'No Defined') AS TrxDscrn,
		CASE WHEN FS.InvoiceType IN ('C','D') AND FS.VendorDocument IS NOT Null AND FS.VendorDocument <> '' THEN FS.VendorDocument
			 WHEN FS.InvoiceType IN ('C','D') AND (FS.VendorDocument IS Null OR FS.VendorDocument = '') THEN InvoiceNumber ELSE
		RTRIM(LEFT(CASE WHEN VendorDocument IS NOT Null THEN CASE WHEN RTRIM(VendorDocument) = RTRIM(FS.Equipment) THEN RTRIM(LEFT(FS.Equipment, 10)) + '/' + dbo.ReturnPureProNumberNew(FS.InvoiceNumber, 1) ELSE RTRIM(VendorDocument) END
						WHEN Equipment IS NOT Null AND Equipment <> '' THEN RTRIM(LEFT(FS.Equipment, 10)) + '/' + dbo.ReturnPureProNumberNew(FS.InvoiceNumber, 1)
						WHEN (LEN(RTRIM(ISNULL(FS.Equipment,''))) = 10 OR ISNULL(FS.Equipment,'') = 'FLATBED') AND ISNULL(FS.Equipment,'') <> VendorDocument THEN RTRIM(ISNULL(LEFT(FS.Equipment, 10),'')) + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
						ELSE CASE WHEN RTRIM(VendorDocument) = '' THEN CAST(FSI_ReceivedSubDetailId AS Varchar) ELSE RTRIM(VendorDocument) END + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
					END, 20)) END AS VendorDocument,
		'FSIP_' + dbo.PADL(FSI_ReceivedSubDetailId, 8, '0') AS VoucherId
FROM	IntegrationsDB.Integrations.dbo.View_Integration_FSI_Full FS
WHERE	Company =  @Company
		AND BatchId = @BatchId
		AND RecordType <> 'EQP'

IF EXISTS(SELECT TOP 1 Company FROM @tblFSIData WHERE IntegrationType = 'FSI')
BEGIN
	SELECT	IntegrationType
			,TMP.Company
			,WeekEndDate
			,TMP.BatchId
			,DetailId
			,VoucherNumber
			,FSI.InvoiceNumber
			,Original_InvoiceNumber
			,FSI.CustomerNumber
			,ApplyTo
			,BillToRef
			,InvoiceDate
			,InvoiceTotal
			,DocumentType
			,InvoiceType
			,Division
			,DetailProcessed AS Processed
			,Status
			,Agent
			,Equipment
			,FSI_ReceivedDetailId
			,ReceivedOn
	INTO	##tmpFSIIntegrationData
	FROM	IntegrationsDB.Integrations.dbo.View_Integration_FSI FSI
			INNER JOIN (
						SELECT	DISTINCT Company, BatchId, CustomerNumber, InvoiceNumber, IntegrationType
						FROM	@tblFSIData 
						WHERE	IntegrationType = 'FSI'
						) TMP ON FSI.Company = TMP.Company AND FSI.BatchId = TMP.BatchId AND FSI.CustomerNumber = TMP.CustomerNumber AND FSI.InvoiceNumber = TMP.InvoiceNumber
	WHERE	FSI.InvoiceTotal <> 0
			--AND (VFSI.PrePayType IS Null OR VFSI.PrePayType <> 'A')
			--AND ((VFSI.DetailProcessed = @Status AND @Status <> 10)
			--OR (VFSI.InvoiceType = 'C' AND @Status = 10))
	ORDER BY FSI.InvoiceNumber

	SET @Query = N'SELECT ''FSI'' AS Integration,
			TMP.CustomerNumber,
			TMP.InvoiceNumber,
			ART.DOCNUMBR
	FROM	##tmpFSIIntegrationData TMP
			LEFT JOIN ' + @Company + '.dbo.RM00401 ART ON TMP.CustomerNumber = ART.CUSTNMBR AND TMP.InvoiceNumber = ART.DOCNUMBR
	WHERE	ART.DOCNUMBR IS Null'

	EXECUTE(@Query)

	DROP TABLE ##tmpFSIIntegrationData
END

IF EXISTS(SELECT TOP 1 Company FROM @tblFSIData WHERE IntegrationType = 'FSIG')
BEGIN
	SELECT	FSI.*,
			IIF(FSI.Company = 'GLSO', FSI.InvoiceNumber + '|' + FSI.VendorDocument, FSI.Equipment + '|' + FSI.InvoiceNumber) AS GLReference,
			PierPassType = CAST(IIF(VND.VendorCode IS Null, 0, 1) AS Bit),
			ISNULL(VND.VendorCode,'') AS VendorCode
	INTO	##tmpFSIIntegrationGL
	FROM	@tblFSIData FSI
			LEFT JOIN @tblVendors VND ON FSI.Company = VND.Company AND FSI.RecordCode = VND.VendorCode AND VND.VndType = 'PP'
	WHERE	IntegrationType = 'FSIG'

	SET @Query = N'SELECT ''FSIG'' AS Integration, 
			TMP.InvoiceNumber,
			TMP.RecordCode,
			TMP.ChargeAmount1,
			TMP.GLReference,
			GLT.REFRENCE
	FROM	##tmpFSIIntegrationGL TMP
			LEFT JOIN ' + @Company + '.dbo.GL20000 GLT ON TMP.GLReference  = GLT.REFRENCE AND LEFT(TMP.BatchId, 15) = GLT.ORGNTSRC
			LEFT JOIN ' + @Company + '.dbo.GL10000 GL1 ON TMP.GLReference  = GL1.REFRENCE AND LEFT(TMP.BatchId, 15) = GL1.BACHNUMB
	WHERE	GLT.REFRENCE IS Null
			AND GL1.REFRENCE IS Null'

	EXECUTE(@Query)

	DROP TABLE ##tmpFSIIntegrationGL
END

IF EXISTS(SELECT TOP 1 Company FROM @tblFSIData WHERE IntegrationType = 'TIP')
BEGIN
	SELECT	DISTINCT 'TIP' AS IntegrationType,
			FSI.RecordId,
			FSI.Company,
			FSI.BooksAccount,
			FSI.Description,
			FSI.InvoiceDate,
			FSI.Amount,
			FSI.LinkType,
			FSI.AccountNumber, -- Credit
			FSI.InterAccount, -- Debit
			FSI.PrePay,
			RCV.ReverseBatch,
			RCV.Reprocess,
			FSI.Parameter,
			FSI.AR_PrePayType,
			FSI.FSIBatchId
	INTO	##tmpFSIIntegrationTIP
	FROM	IntegrationsDB.Integrations.dbo.View_FSI_Intercompany FSI
			LEFT JOIN IntegrationsDB.Integrations.dbo.TIP_IntegrationRecords TIP ON FSI.RecordId = TIP.TIPIntegrationId
			LEFT JOIN IntegrationsDB.Integrations.dbo.ReceivedIntegrations RCV ON FSI.OriginalBatchId = RCV.BatchId AND RCV.Integration = 'TIP'
	WHERE	FSI.Company = @Company
			AND FSI.FSIBatchId = @BatchId
	ORDER BY FSI.LinkType, FSI.Description

	SET @Query = N'SELECT ''TIP'' AS Integration,
			TMP.RecordId,
			TMP.BooksAccount,
			TMP.Description,
			TMP.Amount,
			TMP.LinkType,
			TMP.AccountNumber,
			TMP.InterAccount,
			GLT.REFRENCE
	FROM	##tmpFSIIntegrationTIP TMP
			LEFT JOIN ' + @Company + '.dbo.GL20000 GLT ON TMP.Description  = GLT.REFRENCE AND LEFT(TMP.FSIBatchId, 15) = GLT.ORGNTSRC
	WHERE	GLT.REFRENCE IS Null'

	EXECUTE(@Query)

	DROP TABLE ##tmpFSIIntegrationTIP
END

IF EXISTS(SELECT TOP 1 Company FROM @tblFSIData WHERE IntegrationType = 'FSIP')
BEGIN
	SELECT	RecordCode,
			IIF(LEN(VendorDocument) = 20 AND InvoiceType <> 'A', LEFT(VendorDocument,19), VendorDocument) + IIF(InvoiceType = 'A', '', InvoiceType) AS APDocument,
			ChargeAmount1,
			VoucherId,
			InvoiceNumber
	INTO	##tmpFSIIntegrationAP
	FROM	@tblFSIData FSI
	WHERE	IntegrationType = 'FSIP'

	SET @Query = N'SELECT ''FSIP'' AS Integration,
			TMP.InvoiceNumber,
			TMP.RecordCode,
			TMP.APDocument,
			TMP.ChargeAmount1,
			APT.DOCNUMBR
	FROM	##tmpFSIIntegrationAP TMP
			LEFT JOIN ' + @Company + '.dbo.PM00400 APT ON TMP.RecordCode = APT.VENDORID AND TMP.APDocument = APT.DOCNUMBR
	WHERE	APT.DOCNUMBR IS Null'

	EXECUTE(@Query)

	DROP TABLE ##tmpFSIIntegrationAP
END

