USE [GPCustom]
GO 

/*
EXECUTE USP_FindMissingFSI @Company = 'IMC', @Weekending = '12/26/2020'
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
		[VndCustId]			[varchar](15) NOT NULL,
		[InvoiceNumber]		[varchar](30) NOT NULL,
		[Amount]			[numeric](12,2) NOT NULL,
		[IntegrationType]	[varchar](15) NOT NULL,
		[VoucherId]			[nvarchar](60) NULL,
		[Sub_RecordId]		[int],
		[WeekEndDate]		[date],
		[RefDocument]		[nvarchar](30) NULL,
		[RecordType]		[varchar](15) NULL)
		
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
SELECT	DISTINCT Company,
		BatchId
FROM	IntegrationsDB.Integrations.dbo.FSI_TransactionDetails
WHERE	CAST(WeekEndDate AS Date) = @Weekending
		AND (@Company IS Null OR (@Company IS NOT Null AND Company = @Company))
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND BatchId = @BatchId))
		AND BatchId NOT LIKE '%SUM'
ORDER BY 
		Company

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
			VndCustId, 
			InvoiceNumber,
			Amount,
			IntegrationType,
			VoucherNumber,
			SourceRecordId,
			WeekendDate,
			RefDocument,
			TransType
	FROM	IntegrationsDB.Integrations.dbo.FSI_TransactionDetails FS
	WHERE	Company =  @Company
			AND BatchId = @BatchId

	IF EXISTS(SELECT TOP 1 Company FROM @tblFSIData WHERE IntegrationType = 'FSI' AND BatchId = @BatchId)
	BEGIN
		SELECT	DISTINCT Company, BatchId, VndCustId, InvoiceNumber, Amount, IntegrationType, Sub_RecordId, WeekEndDate, RecordType
		INTO	##tmpFSIIntegrationData
		FROM	@tblFSIData 
		WHERE	IntegrationType = 'FSI'
				AND Amount <> 0
		ORDER BY InvoiceNumber

		SET @Query = N'SELECT TMP.Company,
				TMP.BatchId,
				TMP.IntegrationType AS Integration,
				RTRIM(CUS.CustNmbr) AS CustVnd,
				TMP.InvoiceNumber AS DocRef,
				TMP.Amount,
				TMP.Sub_RecordId AS RecordId,
				TMP.WeekEndDate,
				TMP.RecordType
		FROM	##tmpFSIIntegrationData TMP
				LEFT JOIN CustomerMaster CUS ON TMP.VndCustId IN (CUS.SWSCustomerId, CUS.CustNmbr) AND CUS.CompanyId = TMP.Company 
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
			WeekEndDate,
			RecordType)
		EXECUTE(@Query)

		DROP TABLE ##tmpFSIIntegrationData
	END

	IF EXISTS(SELECT TOP 1 Company FROM @tblFSIData WHERE IntegrationType = 'FSIG' AND BatchId = @BatchId)
	BEGIN
		SELECT	DISTINCT Company, BatchId, VndCustId, RefDocument, Amount, IntegrationType, Sub_RecordId, WeekEndDate, RecordType
		INTO	##tmpFSIIntegrationGL
		FROM	@tblFSIData 
		WHERE	IntegrationType = 'FSIG'
				AND BatchId = @BatchId
				AND Amount <> 0
		ORDER BY VndCustId, RefDocument

		SET @Query = N'SELECT TMP.Company,
				TMP.BatchId,
				TMP.IntegrationType, 
				TMP.VndCustId,
				TMP.RefDocument,
				TMP.Amount,
				TMP.Sub_RecordId,
				TMP.WeekEndDate,
				TMP.RecordType
		FROM	##tmpFSIIntegrationGL TMP
				LEFT JOIN ' + @Company + '.dbo.GL20000 GLT ON TMP.RefDocument  = GLT.REFRENCE AND LEFT(TMP.BatchId, 15) = GLT.ORGNTSRC
				LEFT JOIN ' + @Company + '.dbo.GL10000 GL1 ON TMP.RefDocument  = GL1.REFRENCE AND LEFT(TMP.BatchId, 15) = GL1.BACHNUMB
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
			WeekEndDate,
			RecordType)
		EXECUTE(@Query)

		DROP TABLE ##tmpFSIIntegrationGL
	END

	IF EXISTS(SELECT TOP 1 Company FROM @tblFSIData WHERE IntegrationType = 'TIP' AND BatchId = @BatchId)
	BEGIN
		SELECT	DISTINCT Company, BatchId, VndCustId, RefDocument, Amount, IntegrationType, Sub_RecordId, WeekEndDate, RecordType
		INTO	##tmpFSIIntegrationTIP
		FROM	@tblFSIData 
		WHERE	IntegrationType = 'TIP'
				AND BatchId = @BatchId
				AND Amount <> 0
		ORDER BY VndCustId, RefDocument

		SET @Query = N'SELECT TMP.Company,
				TMP.BatchId,
				TMP.IntegrationType,
				TMP.VndCustId,
				TMP.RefDocument,
				TMP.Amount,
				TMP.Sub_RecordId,
				TMP.WeekEndDate,
				TMP.RecordType
		FROM	##tmpFSIIntegrationTIP TMP
				LEFT JOIN ' + @Company + '.dbo.GL20000 GLT ON TMP.RefDocument  = GLT.REFRENCE AND LEFT(TMP.BatchId, 15) = GLT.ORGNTSRC
				LEFT JOIN ' + @Company + '.dbo.GL10000 GL1 ON TMP.RefDocument  = GL1.REFRENCE AND LEFT(TMP.BatchId, 15) = GL1.BACHNUMB
		WHERE	GLT.REFRENCE IS Null AND GL1.REFRENCE IS Null'

		INSERT INTO MissingIntegrations (
			Company,
			BatchId,
			Integration,
			CustVnd,
			DocRef,
			Amount,
			RecordId,
			WeekEndDate,
			RecordType)
		EXECUTE(@Query)

		DROP TABLE ##tmpFSIIntegrationTIP
	END

	IF EXISTS(SELECT TOP 1 Company FROM @tblFSIData WHERE IntegrationType = 'FSIP' AND BatchId = @BatchId)
	BEGIN
		SELECT	DISTINCT VndCustId,
				RefDocument AS APDocument,
				Amount,
				VoucherId,
				InvoiceNumber,
				Sub_RecordId,
				WeekEndDate,
				RecordType
		INTO	##tmpFSIIntegrationAP
		FROM	@tblFSIData FSI
		WHERE	IntegrationType = 'FSIP'
				AND BatchId = @BatchId
				AND Amount <> 0

		SET @Query = N'SELECT ''' + @Company + ''' AS Company,
				''' + @BatchId + ''' AS BatchId,
				''FSIP'' AS Integration,
				VMA.VendorId AS RecordCode,
				TMP.APDocument,
				TMP.Amount,
				TMP.Sub_RecordId,
				TMP.WeekendDate,
				TMP.RecordType
		FROM	##tmpFSIIntegrationAP TMP
				LEFT JOIN GPVendorMaster VMA ON TMP.VndCustId IN (VMA.SWSVendorID, VMA.VendorId) AND VMA.Company = ''' + @Company + ''' 
				LEFT JOIN ' + @Company + '.dbo.PM00400 APT ON VMA.VendorId = APT.VENDORID AND TMP.APDocument = APT.DOCNUMBR
		WHERE	APT.DOCNUMBR IS Null'

		INSERT INTO MissingIntegrations (
			Company,
			BatchId,
			Integration,
			CustVnd,
			DocRef,
			Amount,
			RecordId,
			WeekEndDate,
			RecordType)
		EXECUTE(@Query)

		DROP TABLE ##tmpFSIIntegrationAP
	END

	--IF (SELECT COUNT(*) FROM MissingIntegrations WHERE Company = @Company AND BatchId = @BatchId) = 0
	--	UPDATE	IntegrationsDB.Integrations.dbo.ReceivedIntegrations
	--	SET		Validated = 1
	--	WHERE	Integration = 'FSI'
	--			AND Company = @Company
	--			AND BatchId = @BatchId

	-- PROCESS END

	FETCH FROM curIntBatches INTO @Company, @BatchId
END

CLOSE curIntBatches
DEALLOCATE curIntBatches

SELECT	*,
		CAST(RecordId AS Varchar) + ',' AS strRecordId
FROM	MissingIntegrations
ORDER BY Company, BatchId, Integration, CustVnd
