USE [GPCustom]
GO

/*
EXECUTE USP_FindMissingFSI @Company = 'IMC', @Weekending = '01/23/2021'
EXECUTE USP_FindMissingFSI @Weekending = '12/12/2020'
*/ 
ALTER PROCEDURE USP_FindMissingFSI
		@Company	Varchar(5) = Null,
		@Weekending	Date = Null,
		@BatchId	Varchar(25) = Null
AS
SET NOCOUNT ON 

DELETE MissingIntegrations 

DECLARE	@Query		Varchar(MAX)

DECLARE @tblVendors	Table (Company Varchar(6), VendorCode Varchar(30), VndType Char(10))

DECLARE @tblFSIData	Table (
		[Company]			[varchar](6) NOT NULL,
		[BatchId]			[varchar](30) NOT NULL,
		[CustomerNumber]	[varchar](25) NOT NULL,
		[InvoiceNumber]		[varchar](30) NOT NULL,
		[InvoiceTotal]		[numeric](10,2) NOT Null,
		[InvoiceType]		[char](1) NULL,
		[RecordType]		[char](3) NOT NULL,
		[RecordCode]		[varchar](15) NOT NULL,
		[ChargeAmount1]		[numeric](10,2) NULL,
		[AccCode]			[varchar](10) NULL,
		[IntegrationType]	[varchar](15) NOT NULL,
		[VendorDocument]	[nvarchar](60) NULL,
		[VoucherId]			[nvarchar](60) NULL,
		[Equipment]			[varchar](25) NULL,
		[Sub_RecordId]		[int],
		[WeekEndDate]		[date],
		[PrepayReference]	[varchar](30))
		
IF @Weekending IS Null
BEGIN
	IF DATEPART(DW, GETDATE()) < 4
		SET @Weekending = DATEADD(Day, -7, GETDATE())
	ELSE
		SET @Weekending = GETDATE()
END

IF NOT DATENAME(weekday, @Weekending) = 'Saturday'
BEGIN
	IF DATENAME(weekday, @Weekending) = 'Monday'
		SET @Weekending = DATEADD(Day, 5, @Weekending)
	ELSE
	BEGIN
		IF DATENAME(weekday, @Weekending) = 'Tuesday'
			SET @Weekending = DATEADD(Day, 4, @Weekending)
		ELSE
		BEGIN
			IF DATENAME(weekday, @Weekending) = 'Wednesday'
				SET @Weekending = DATEADD(Day, 3, @Weekending)
			ELSE
			BEGIN
				IF DATENAME(weekday, @Weekending) = 'Thursday'
					SET @Weekending = DATEADD(Day, 2, @Weekending)
				ELSE
				BEGIN
					IF DATENAME(weekday, @Weekending) = 'Friday'
						SET @Weekending = DATEADD(Day, 1, @Weekending)
					ELSE
					BEGIN
						IF DATENAME(weekday, @Weekending) = 'Sunday'
							SET @Weekending = DATEADD(Day, 6, @Weekending)
					END
				END
			END
		END
	END
END

PRINT @Weekending

DECLARE curIntBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company,
		BatchId
FROM	IntegrationsDB.Integrations.dbo.FSI_ReceivedHeader
WHERE	CAST(WeekEndDate AS Date) = @Weekending
		AND (@Company IS Null OR (@Company IS NOT Null AND Company = @Company))
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND BatchId = @BatchId))
		AND BatchId NOT LIKE '%SUM'
ORDER BY 
		Company,
		ReceivedOn

OPEN curIntBatches 
FETCH FROM curIntBatches INTO @Company, @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'COMPANY: ' + @Company + ' / Batch Id: ' + @BatchId 

	DELETE @tblVendors
	DELETE @tblFSIData

	-- PROCESS START

	INSERT INTO @tblVendors
	SELECT	Company, 
			VendorId,
			'PP'
	FROM	GPCustom.dbo.GPVendorMaster 
	WHERE	Company = @Company 
			AND PierPassType = 1			

	INSERT INTO @tblFSIData
	SELECT	Company, 
			BatchId, 
			CustomerNumber, 
			InvoiceNumber,
			InvoiceTotal,
			InvoiceType,
			RecordType,
			RecordCode,
			ChargeAmount1,
			AccCode,
			IntegrationType,
			LEFT(VendorDocument, 20),
			VoucherId,
			Equipment,
			FSI_ReceivedSubDetailId,
			WeekEndDate,
			PrepayReference
	FROM	(
			SELECT	Company, 
					BatchId, 
					CustomerNumber, 
					InvoiceNumber,
					InvoiceTotal,
					InvoiceType,
					RecordType,
					RecordCode,
					ChargeAmount1,
					AccCode,
					CASE 
						WHEN Intercompany = 1 OR VndIntercompany = 1 OR ICB_AR = 1 OR ICB_AP = 1 THEN 'TIP' 
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
					CASE WHEN FS.InvoiceType IN ('C','D') AND FS.VendorDocument IS NOT Null AND FS.VendorDocument <> '' THEN FS.VendorReference
						 WHEN FS.InvoiceType IN ('C','D') AND (FS.VendorDocument IS Null OR FS.VendorDocument = '') THEN InvoiceNumber 
						 ELSE RTRIM(LEFT(CASE WHEN VendorDocument IS NOT Null THEN CASE WHEN RTRIM(VendorDocument) = RTRIM(FS.Equipment) THEN RTRIM(LEFT(FS.Equipment, 10)) + '/' + dbo.ReturnPureProNumberNew(FS.InvoiceNumber, 1) ELSE RTRIM(VendorDocument) END
									WHEN Equipment IS NOT Null AND Equipment <> '' THEN RTRIM(LEFT(FS.Equipment, 10)) + '/' + dbo.ReturnPureProNumberNew(FS.InvoiceNumber, 1)
									WHEN (LEN(RTRIM(ISNULL(FS.Equipment,''))) = 10 OR ISNULL(FS.Equipment,'') = 'FLATBED') AND ISNULL(FS.Equipment,'') <> VendorDocument THEN RTRIM(ISNULL(LEFT(FS.Equipment, 10),'')) + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
									ELSE CASE WHEN RTRIM(VendorDocument) = '' THEN CAST(FSI_ReceivedSubDetailId AS Varchar) ELSE RTRIM(VendorDocument) END + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
								END, 20)) END AS VendorDocument,
					'FSIP_' + dbo.PADL(FSI_ReceivedSubDetailId, 8, '0') AS VoucherId,
					Equipment,
					FSI_ReceivedSubDetailId,
					WeekEndDate,
					PrepayReference
			FROM	IntegrationsDB.Integrations.dbo.View_Integration_FSI_Full FS
			WHERE	Company =  @Company
					AND BatchId = @BatchId
					AND RecordType <> 'EQP'
	) DATA

	--print 'end selection'

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
		ORDER BY FSI.InvoiceNumber

		SET @Query = N'SELECT ''' + @Company + ''' AS Company,
				''' + @BatchId + ''' AS BatchId,
				''FSI'' AS Integration,
				CUS.CustNmbr AS CustomerNumber,
				TMP.InvoiceNumber,
				TMP.InvoiceTotal,
				TMP.FSI_ReceivedDetailId,
				TMP.WeekEndDate
		FROM	##tmpFSIIntegrationData TMP
				LEFT JOIN CustomerMaster CUS ON TMP.CustomerNumber IN (CUS.SWSCustomerId, CUS.CustNmbr) AND CUS.CompanyId = ''' + @Company + ''' 
				LEFT JOIN ' + @Company + '.dbo.RM00401 ART ON CUS.CustNmbr = ART.CUSTNMBR AND TMP.InvoiceNumber = ART.DOCNUMBR
		WHERE	ART.DOCNUMBR IS Null'

		INSERT INTO MissingIntegrations (
			Company,
			BatchId,
			Integration,
			CustVnd,
			DocRef,
			Amount,
			RecordId,
			WeekEndDate)
		EXECUTE(@Query)

		DROP TABLE ##tmpFSIIntegrationData
	END

	IF EXISTS(SELECT TOP 1 Company FROM @tblFSIData WHERE IntegrationType = 'FSIG')
	BEGIN
		SELECT	FSI.*,
				FSI.PrepayReference AS GLReference,
				PierPassType = CAST(IIF(VND.VendorCode IS Null, 0, 1) AS Bit),
				ISNULL(VND.VendorCode,'') AS VendorCode
		INTO	##tmpFSIIntegrationGL
		FROM	@tblFSIData FSI
				LEFT JOIN @tblVendors VND ON FSI.Company = VND.Company AND FSI.RecordCode = VND.VendorCode AND VND.VndType = 'PP'
		WHERE	IntegrationType = 'FSIG'

		SET @Query = N'SELECT ''' + @Company + ''' AS Company,
				''' + @BatchId + ''' AS BatchId,
				''FSIG'' AS Integration, 
				TMP.RecordCode,
				TMP.GLReference,
				TMP.ChargeAmount1,
				TMP.Sub_RecordId,
				TMP.WeekEndDate
		FROM	##tmpFSIIntegrationGL TMP
				LEFT JOIN ' + @Company + '.dbo.GL20000 GLT ON TMP.GLReference  = GLT.REFRENCE AND LEFT(TMP.BatchId, 15) = GLT.ORGNTSRC
				LEFT JOIN ' + @Company + '.dbo.GL10000 GL1 ON TMP.GLReference  = GL1.REFRENCE AND LEFT(TMP.BatchId, 15) = GL1.BACHNUMB
		WHERE	GLT.REFRENCE IS Null
				AND GL1.REFRENCE IS Null'

		INSERT INTO MissingIntegrations (
			Company,
			BatchId,
			Integration,
			CustVnd,
			DocRef,
			Amount,
			RecordId,
			WeekEndDate)
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
				FSI.FSIBatchId,
				FSI.WeekEndDate
		INTO	##tmpFSIIntegrationTIP
		FROM	IntegrationsDB.Integrations.dbo.View_FSI_Intercompany FSI
				LEFT JOIN IntegrationsDB.Integrations.dbo.TIP_IntegrationRecords TIP ON FSI.RecordId = TIP.TIPIntegrationId
				LEFT JOIN IntegrationsDB.Integrations.dbo.ReceivedIntegrations RCV ON FSI.OriginalBatchId = RCV.BatchId AND RCV.Integration = 'TIP'
		WHERE	FSI.Company = @Company
				AND FSI.FSIBatchId = @BatchId
		ORDER BY FSI.LinkType, FSI.Description

		SET @Query = N'SELECT ''' + @Company + ''' AS Company,
				''' + @BatchId + ''' AS BatchId,
				''TIP'' AS Integration,
				TMP.BooksAccount,
				TMP.Description,
				TMP.Amount,
				TMP.RecordId,
				TMP.WeekEndDate
		FROM	##tmpFSIIntegrationTIP TMP
				LEFT JOIN ' + @Company + '.dbo.GL20000 GLT ON TMP.Description  = GLT.REFRENCE AND LEFT(TMP.FSIBatchId, 15) = GLT.ORGNTSRC
				LEFT JOIN ' + @Company + '.dbo.GL10000 GL1 ON TMP.Description  = GL1.REFRENCE AND LEFT(TMP.FSIBatchId, 15) = GL1.BACHNUMB
		WHERE	GLT.REFRENCE IS Null AND GL1.REFRENCE IS Null'

		INSERT INTO MissingIntegrations (
			Company,
			BatchId,
			Integration,
			CustVnd,
			DocRef,
			Amount,
			RecordId,
			WeekEndDate)
		EXECUTE(@Query)

		DROP TABLE ##tmpFSIIntegrationTIP
	END

	IF EXISTS(SELECT TOP 1 Company FROM @tblFSIData WHERE IntegrationType = 'FSIP')
	BEGIN
		SELECT	RecordCode,
				IIF(LEN(VendorDocument) = 20 AND InvoiceType <> 'A', LEFT(VendorDocument,19), VendorDocument) + IIF(InvoiceType = 'A', '', InvoiceType) AS APDocument,
				ChargeAmount1,
				VoucherId,
				InvoiceNumber,
				Sub_RecordId
		INTO	##tmpFSIIntegrationAP
		FROM	@tblFSIData FSI
		WHERE	IntegrationType = 'FSIP'

		SET @Query = N'SELECT ''' + @Company + ''' AS Company,
				''' + @BatchId + ''' AS BatchId,
				''FSIP'' AS Integration,
				VMA.VendorId AS RecordCode,
				TMP.APDocument,
				TMP.ChargeAmount1,
				TMP.Sub_RecordId
		FROM	##tmpFSIIntegrationAP TMP
				LEFT JOIN GPVendorMaster VMA ON TMP.RecordCode IN (VMA.SWSVendorID, VMA.VendorId) AND VMA.Company = ''' + @Company + ''' 
				LEFT JOIN ' + @Company + '.dbo.PM00400 APT ON VMA.VendorId = APT.VENDORID AND TMP.APDocument = APT.DOCNUMBR
		WHERE	APT.DOCNUMBR IS Null'

		INSERT INTO MissingIntegrations (
			Company,
			BatchId,
			Integration,
			CustVnd,
			DocRef,
			Amount,
			RecordId)
		EXECUTE(@Query)

		DROP TABLE ##tmpFSIIntegrationAP
	END

	IF (SELECT COUNT(*) FROM MissingIntegrations WHERE Company = @Company AND BatchId = @BatchId) = 0
		UPDATE	IntegrationsDB.Integrations.dbo.ReceivedIntegrations
		SET		Validated = 1
		WHERE	Integration = 'FSI'
				AND Company = @Company
				AND BatchId = @BatchId

	-- PROCESS END

	FETCH FROM curIntBatches INTO @Company, @BatchId
END

CLOSE curIntBatches
DEALLOCATE curIntBatches

SELECT	*,
		CAST(RecordId AS Varchar) + ',' AS strRecordId
FROM	MissingIntegrations
ORDER BY Company, BatchId, Integration, CustVnd
