USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_TIP_Transactions_Integration]    Script Date: 9/6/2018 10:57:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_TIP_Transactions_Integration 'GSA', '243', 'GLSO', '1565', '04/10/2018'
*/
ALTER PROCEDURE [dbo].[USP_TIP_Transactions_Integration]
		@MainCompany	Varchar(5),
		@VendorId		Varchar(20),
		@SubCompany		Varchar(5),
		@CustomerId		Varchar(20),
		@PostingDate	Date
AS
DECLARE	@Query			Varchar(Max),
		@CompanyAlias1	Varchar(5),
		@CompanyAlias2	Varchar(5),
		@DatePortion	varchar(20),
		@Integration	varchar(6),
        @Company		varchar(5),
        @BatchId		varchar(25),
        @DOCNUMBR		varchar(20),
		@DOCDESCR		varchar(30),
        @CUSTNMBR		varchar(15),
        @DOCDATE		datetime,
        @DUEDATE		datetime,
        @DOCAMNT		numeric(10,2),
        @SLSAMNT		numeric(10,2),
        @RMDTYPAL		int,
		@DISTTYPE		int,
        @ACTNUMST		varchar(15),
        @DEBITAMT		numeric(10,2),
        @CRDTAMNT		numeric(10,2),
        @DistRef		varchar(30),
		@ApplyTo		varchar(30) = Null,
		@Division		varchar(3) = Null,
        @ProNumber		varchar(12) = Null,
        @DistRecords	int = 0,
        @IntApToBal		numeric(10,2) = 0,
        @GPAptoBal		numeric(10,2) = 0,
		@UserId			varchar(25) = 'AR Integrator',
		@IntDate		datetime = GETDATE(),
		@APAccount		varchar(15) = '0-00-2000',
		@ARAccount		varchar(15) = '0-00-1050',
		@APCpyAcct		varchar(15),
		@ARCpyAcct		varchar(15),
		@NewBatchId		varchar(15),
		@NewDocument	varchar(25),
		@AR_Document	varchar(25),
		@ARBatch		varchar(25),
		@APBatch		varchar(25),
		@StrTime		Varchar(20)

SET @VendorId		= RTRIM(@VendorId)
SET @CompanyAlias1	= (SELECT ISNULL(CompanyAlias, CompanyId) AS Alias FROM Companies WHERE CompanyId = @MainCompany)
SET @CompanyAlias2	= (SELECT ISNULL(CompanyAlias, CompanyId) AS Alias FROM Companies WHERE CompanyId = @SubCompany)
SET @StrTime		= CONVERT(VARCHAR, @IntDate, 114)
SET @DatePortion	= dbo.PADL(MONTH(@IntDate), 2, '0') + dbo.PADL(DAY(@IntDate), 2, '0') + RIGHT(dbo.PADL(YEAR(@IntDate), 4, '0'), 2) + SUBSTRING(@StrTime, 1, dbo.AT(':', @StrTime, 1) - 1) + SUBSTRING(@StrTime, dbo.AT(':', @StrTime, 1) + 1, dbo.AT(':', @StrTime, 2) - 1 - dbo.AT(':', @StrTime, 1))
SET @APCpyAcct		= (SELECT AccountNumber FROM IntegrationsDB.Integrations.dbo.FSI_Intercompany_Companies WHERE ForCompany = @MainCompany AND LinkedCompany = @SubCompany AND LinkType = 'P')
SET @ARCpyAcct		= (SELECT AccountNumber FROM IntegrationsDB.Integrations.dbo.FSI_Intercompany_Companies WHERE ForCompany = @SubCompany AND LinkedCompany = @MainCompany AND LinkType = 'R')

DECLARE	@tblAPData		Table (
		Ap_Document		Varchar(30),
		Ap_DocAmount	Numeric(10,2))

DECLARE	@tblGPAR		Table (CustomerId Varchar(15), Document Varchar(25), Balance Numeric(10,2))

SET	@Query = N'SELECT CUSTNMBR, DOCNUMBR, CURTRXAM FROM ' + RTRIM(@SubCompany) + '.dbo.RM20101 WHERE CustNmbr = ''' + RTRIM(@CustomerId) + ''''

INSERT INTO @tblGPAR
EXECUTE(@Query)

SELECT	DISTINCT DATA.Ar_CustomerId,
		DATA.Ar_Document,
		DATA.Ar_DocDate,
		DATA.Ar_BatchNumber,
		DATA.Ar_DocAmount,
		DATA.Ar_Description,
		DATA.Difference,
		DATA.KeyWord
INTO	#tmpReportData
FROM	TIP_Transactions DATA
		LEFT JOIN @tblGPAR TMP ON DATA.Ar_CustomerId = TMP.CustomerId AND DATA.Ar_Document = TMP.Document
WHERE	DATA.AP_Company = @MainCompany 
		AND DATA.AR_Company = @SubCompany 
		AND DATA.VendorId = @VendorId 
		AND DATA.CustomerId = @CustomerId
		AND DATA.BatchDate = CAST(GETDATE() AS Date)
		AND DATA.Approved = 1
		AND ISNULL(TMP.Balance, 1) > 0
ORDER BY 2,6

SET @DOCAMNT = (SELECT SUM(Ar_DocAmount) AS Amount FROM #tmpReportData WHERE Difference = 0)
SET @Integration = 'TIPAR'
SET @NewBatchId = @Integration + @DatePortion
SET @NewDocument = 'TIP' + @DatePortion
SET @ARBatch = @NewBatchId

DELETE IntegrationsDB.Integrations.dbo.Integrations_AR WHERE Integration = @Integration AND Company = @SubCompany AND BatchId = @NewBatchId
DELETE IntegrationsDB.Integrations.dbo.Integrations_ApplyTo WHERE Integration = @Integration AND Company = @SubCompany AND BatchId = @NewBatchId

BEGIN TRY
	----------- R E C E I V A B L E S ------------
	INSERT INTO IntegrationsDB.Integrations.dbo.Integrations_AR
           ([Integration]
           ,[Company]
           ,[BatchId]
           ,[DOCNUMBR]
		   ,[DOCDESCR]
           ,[CUSTNMBR]
           ,[DOCDATE]
           ,[DUEDATE]
           ,[DOCAMNT]
           ,[SLSAMNT]
           ,[RMDTYPAL]
           ,[DISTTYPE]
           ,[ACTNUMST]
           ,[DEBITAMT]
           ,[CRDTAMNT]
           ,[DistRef]
           ,[VendorId]
		   ,[IntApToBal]
		   ,[GPAptoBal]
		   ,[PostingDate]
		   ,[WithApplyTo])
	SELECT	@Integration AS Integration,
			@SubCompany AS Company,
			@NewBatchId AS BatchId,
			@NewDocument AS DOCNUMBR,
			'TIP ' + CAST(CAST(@IntDate AS Date) AS Varchar) AS DOCDESCR,
			@CustomerId AS CUSTNMBR,
			CAST(@IntDate AS Date) AS DOCDATE,
			DATEADD(dd, 30, CAST(@IntDate AS Date)) AS DUEDATE,
			@DOCAMNT AS DOCAMNT,
			@DOCAMNT AS SLSAMNT,
			7 AS RMDTYPAL,
			3 AS DISTTYPE,
			@ARAccount AS ACTNUMST,
			0 AS DEBITAMT,
			@DOCAMNT AS CRDTAMNT,
			'TIP ' + CAST(CAST(@IntDate AS Date) AS Varchar) AS DistRef,
			@VendorId,
			@IntApToBal,
			@GPAptoBal,
			@PostingDate AS PostingDate,
			1
	UNION
	SELECT	@Integration AS Integration,
			@SubCompany AS Company,
			@NewBatchId AS BatchId,
			@NewDocument AS DOCNUMBR,
			'TIP ' + CAST(CAST(@IntDate AS Date) AS Varchar) AS DOCDESCR,
			@CustomerId AS CUSTNMBR,
			CAST(@IntDate AS Date) AS DOCDATE,
			DATEADD(dd, 30, CAST(@IntDate AS Date)) AS DUEDATE,
			@DOCAMNT AS DOCAMNT,
			@DOCAMNT AS DOCAMNT,
			7 AS RMDTYPAL,
			19 AS DISTTYPE,
			@ARCpyAcct AS ACTNUMST,
			@DOCAMNT AS DEBITAMT,
			0 AS CRDTAMNT,
			'TIP ' + CAST(CAST(@IntDate AS Date) AS Varchar) AS DistRef,
			@VendorId,
			@IntApToBal,
			@GPAptoBal,
			@PostingDate AS PostingDate,
			1
END TRY
BEGIN CATCH
	PRINT 'ErrorNumber: ' + CAST(ERROR_NUMBER() AS Varchar)
	PRINT 'ErrorSeverity: ' + CAST(ERROR_SEVERITY() AS Varchar)
	PRINT 'ErrorLine : ' + CAST(ERROR_LINE() AS Varchar)
	PRINT 'ErrorMessage: ' + CAST(ERROR_MESSAGE() AS Varchar)
END CATCH

INSERT INTO IntegrationsDB.Integrations.dbo.Integrations_ApplyTo
		([Integration]
		,[Company]
		,[BatchId]
		,[CustomerVendor]
		,[ApplyFrom]
		,[ApplyTo]
		,[ApplyAmount]
		,[RecordType]
		,[Processed])
SELECT	@Integration,
		@SubCompany,
		@NewBatchId,
		Ar_CustomerId,
		@NewDocument,
		Ar_Document,
		Ar_DocAmount,
		'AR',
		0
FROM	#tmpReportData
WHERE	Difference = 0.00

----------- P A Y A B L E S ------------
SET @Integration	= 'TIPAP'
SET @NewBatchId		= @Integration + @DatePortion
SET @APBatch		= @NewBatchId

DELETE IntegrationsDB.Integrations.dbo.Integrations_AP WHERE Integration = @Integration AND Company = @MainCompany AND BatchId = @NewBatchId
DELETE IntegrationsDB.Integrations.dbo.Integrations_ApplyTo WHERE Integration = @Integration AND Company = @MainCompany AND BatchId = @NewBatchId

INSERT INTO	IntegrationsDB.Integrations.dbo.Integrations_AP
		(Integration,
		Company,
		BatchId,
		VCHNUMWK,
		VENDORID,
		DOCNUMBR,
		DOCTYPE,
		DOCAMNT,
		DOCDATE,
		PSTGDATE,
		PORDNMBR,
		CHRGAMNT,
		TEN99AMNT,
		PRCHAMNT,
		TRXDSCRN,
		DISTTYPE,
		ACTNUMST,
		DEBITAMT,
		CRDTAMNT,
		DISTREF,
		RECORDID,
		WithApplyTo)
SELECT	@Integration AS Integration,
		@MainCompany AS Company,
		@NewBatchId AS BatchId,
		@NewBatchId AS VCHNUMWK,
		@VendorId,
		@NewDocument AS DOCNUMBR,
		5 AS DOCTYPE,
		@DOCAMNT AS DOCAMNT,
		CAST(@IntDate AS Date) AS DOCDATE,
		@PostingDate,
		Null AS PORDNMBR,
		@DOCAMNT AS CHRGAMNT,
		0 AS TEN99AMNT,
		@DOCAMNT AS PRCHAMNT,
		'TIP ' + CAST(CAST(@IntDate AS Date) AS Varchar) AS TRXDSCRN,
		2 AS DISTTYPE,
		@APAccount AS ACTNUMST,
		@DOCAMNT AS DEBITAMT,
		0 AS CRDTAMNT,
		'TIP ' + CAST(CAST(@IntDate AS Date) AS Varchar) AS DistRef,
		0,
		1
UNION
SELECT	@Integration AS Integration,
		@MainCompany AS Company,
		@NewBatchId AS BatchId,
		@NewBatchId AS VCHNUMWK,
		@VendorId,
		@NewDocument AS DOCNUMBR,
		5 AS DOCTYPE,
		@DOCAMNT AS DOCAMNT,
		CAST(@IntDate AS Date) AS DOCDATE,
		@PostingDate,
		Null AS PORDNMBR,
		@DOCAMNT AS CHRGAMNT,
		0 AS TEN99AMNT,
		@DOCAMNT AS PRCHAMNT,
		'TIP ' + CAST(CAST(@IntDate AS Date) AS Varchar) AS TRXDSCRN,
		6 AS DISTTYPE,
		@APCpyAcct AS ACTNUMST,
		0 AS DEBITAMT,
		@DOCAMNT AS CRDTAMNT,
		'TIP ' + CAST(CAST(@IntDate AS Date) AS Varchar) AS DistRef,
		0,
		1

DECLARE curAPData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	LEFT(RTRIM(AR_Document), 9) 
FROM	#tmpReportData
WHERE	Difference = 0.00

OPEN curAPData 
FETCH FROM curAPData INTO @AR_Document

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblAPData

	IF EXISTS(SELECT AP_Document FROM TIP_Transactions_Assigned WHERE AP_Company = @MainCompany AND VendorId = @VendorId AND AR_Document = @AR_Document)
		INSERT INTO @tblAPData
		SELECT	AP_Document,
				AP_DocAmount
		FROM	TIP_Transactions_Assigned
		WHERE	AP_Company = @MainCompany 
				AND VendorId = @VendorId 
				AND AR_Document = @AR_Document
	ELSE
	BEGIN
		SET	@Query = N'SELECT AP.DOCNUMBR,
				CASE WHEN AP.DOCTYPE < 5 THEN 1 ELSE -1 END * AP.CURTRXAM AS DocAmnt
		FROM	' + RTRIM(@MainCompany) + '.dbo.PM20000 AP
		WHERE	AP.VendorId = ''' + @VendorId + ''' 
				AND LEFT(AP.DOCNUMBR, 9) = ''' + @AR_Document + ''''

		INSERT INTO @tblAPData
		EXECUTE(@Query)
	END

	IF @@ROWCOUNT > 0
	BEGIN
		INSERT INTO IntegrationsDB.Integrations.dbo.Integrations_ApplyTo
				([Integration]
				,[Company]
				,[BatchId]
				,[CustomerVendor]
				,[ApplyFrom]
				,[ApplyTo]
				,[ApplyAmount]
				,[RecordType]
				,[Processed])
		SELECT	@Integration,
				@MainCompany,
				@NewBatchId,
				@VendorId,
				@NewDocument,
				Ap_Document,
				Ap_DocAmount,
				'AP',
				0
		FROM	@tblAPData
	END

	FETCH FROM curAPData INTO @AR_Document
END

CLOSE curAPData
DEALLOCATE curAPData

DROP TABLE #tmpReportData

IF @@ERROR = 0
BEGIN
	EXECUTE IntegrationsDB.Integrations.dbo.USP_ReceivedIntegrations 'TIPAR', @SubCompany, @ARBatch
	EXECUTE IntegrationsDB.Integrations.dbo.USP_ReceivedIntegrations 'TIPAP', @MainCompany, @APBatch
	PRINT 'END'
END