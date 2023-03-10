USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindDriverDocuments]    Script Date: 4/14/2021 9:45:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/*
EXECUTE USP_DriverDocuments_List @Company = 'AIS', @CheckDate = '07/29/2021', @Recreate = 1
EXECUTE USP_DriverDocuments_List @Company = 'NONE'

ALTER INDEX ALL ON DriverDocuments REBUILD WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = ON)
*/
ALTER PROCEDURE [dbo].[USP_DriverDocuments_List]
		@Company	Varchar(5),
		@CheckDate	Datetime = Null,
		@BatchId	Varchar(500) = Null,
		@VendorId	Varchar(12) = Null,
		@DocTypes	Varchar(50) = Null,
		@PaidCard	Bit = 0,
		@Recreate	Bit = 0
AS
SET NOCOUNT ON

DECLARE @nErrNum			Int = 0,
		@sErrProcedure		Varchar(35) = 'USP_DriverDocuments_List',
		@sErrMsg			Varchar(250)

DECLARE	@PayDate	Date = @CheckDate,
		@ProjectID	Int = 165,
		@CompanyNum	Int,
		@OOSDate	Date,
		@Query		Varchar(2000),
		@MergeFiles Varchar(150) = 'http://priapint01p/FileBoundFiles/' + RTRIM(@Company) + '_'
		
SET @CompanyNum	= (SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company)
SET @OOSDate	= dbo.DayFwdBack(@CheckDate, 'P', 'Saturday')

DECLARE @tblBatches		Table (
		Company			Varchar(5),
		BatchId			Varchar(25),
		BatchDate		Date)

INSERT INTO @tblBatches
SELECT	DISTINCT [Company], RTRIM([BACHNUMB]) AS BACHNUMB, CAST(IIF(DATEPART(DW, [DOCDATE]) < 5, dbo.DayFwdBack([DOCDATE], 'N', 'Thursday'), [DOCDATE]) AS Date) AS DOCDATE
FROM	[GPCustom].[dbo].[PM10300]
WHERE	Company = @Company
		AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND DOCDATE BETWEEN @OOSDate AND @CheckDate))
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(BACHNUMB) + '%', @BatchId) > 0))
		AND RIGHT(RTRIM(BACHNUMB), 2) IN ('CK','DD')
ORDER BY BACHNUMB

IF @Recreate = 1
BEGIN
	ALTER INDEX ALL ON DriverDocuments REBUILD WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = ON)

	DELETE	DriverDocuments_Inquiry
	WHERE	Company = @Company
			AND WeekEndingDate IN (SELECT BatchDate FROM @tblBatches)
END

IF dbo.OCCURS(',', @BatchId) > 1
	SET @CheckDate = Null

IF NOT EXISTS(SELECT TOP 1 RecordId FROM DriverDocuments_Inquiry WHERE Company = @Company AND WeekEndingDate IN (SELECT BatchDate FROM @tblBatches)) AND @Company <> 'NONE'
BEGIN
	PRINT 'CREATE RECORD'

	DECLARE @BaseBatch		Varchar(15) = REPLACE(REPLACE(@BatchId, 'CK', ''), 'DD', ''),
			@Notification	Bit = 0

	DECLARE @tmpOOS_Documents		Table (
		[RecordType]		[numeric](5, 1) NOT NULL,
		[Display]			[varchar](50) NULL,
		[DocumentName]		[varchar](250) NULL,
		[Node]				[varchar](25) NULL,
		[Parent]			[varchar](25) NULL,
		[Sort]				[varchar](100) NULL,
		[Icon]				[int] NOT NULL,
		[BatchId]			[varchar](20) NULL,
		[WeekEndingDate]	[datetime] NULL,
		[VendorId]			[varchar](15),
		[DocumentTypeId]	[int],
		[FileId]			[int],
		[Division]			[char](2))

	DECLARE @tblFileBound	Table (
		FileId				Int, 
		FullFileName		Varchar(150), 
		VendorId			Varchar(15), 
		WeekEndigDate		Date, 
		DocType				Varchar(50))

	DECLARE @tblDrivers		Table (
		DriverId			Varchar(15),
		PayType				Char(2),
		Division			Char(2))

	IF EXISTS(SELECT TOP 1 WeekEndingDate FROM DriverDocuments WHERE Company = @Company AND WeekEndingDate = @PayDate AND Fk_DocumentTypeId = 5 AND VendorId = 'ALL')
		SET @Notification = 1

	INSERT INTO @tblFileBound
	SELECT	FileId, FullFileName, Field2, Field4, Field5
	FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments DEX
	WHERE	DEX.ProjectID = @ProjectID
			AND DEX.Field1 = @CompanyNum
			AND CAST(DEX.Field4 AS Date) BETWEEN @OOSDate AND @CheckDate
			--AND Field5 <> 'LEGACY_DRAYAGE'

	SET @Query = 'SELECT driver_id, payment_method, division FROM OOS.Driver_Info WHERE COMPANY_ID = ' + CAST(@CompanyNum AS Varchar)

	INSERT INTO @tblDrivers
	EXECUTE USP_QuerySWS @Query, Null, 'POSTGRESQL_IMC_ENTERPRISE'
	
	INSERT INTO @tmpOOS_Documents
	SELECT	DISTINCT *
	FROM	(
			SELECT	DISTINCT 1 AS RecordType
					,CONVERT(Char(10), WeekEndingDate, 101) + ' - ' + RIGHT(RTRIM(BatchId), 2) AS Display
					,@MergeFiles + RTRIM(BatchId) + '.pdf' AS DocumentName
					,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) AS Node
					,Null AS Parent
					,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) AS Sort
					,80 AS Icon
					,BatchId
					,ISNULL(WeekEndingDate, GETDATE()) AS WeekEndingDate
					,'' AS VendorId
					,0 AS Fk_DocumentTypeId
					,0 AS FileId
					,'' AS Division
			FROM	View_DriverDocuments
			WHERE	Company = @Company
					AND BatchId <> ''
					AND VendorId <> 'ALL'
					AND WeekEndingDate IN (SELECT BatchDate FROM @tblBatches)
					AND ISNULL(TerminationDate, DATEADD(DD, 5, GETDATE())) > WeekEndingDate
			UNION
			SELECT	DISTINCT 2 AS RecordType
					,VDD.VendorId AS Display
					,Null AS DocumentName
					,'VND_' + RTRIM(CAST(VDD.VendorId AS Char(12))) AS Node
					,'DIV_' + RIGHT(RTRIM(BatchId), 2) + '_' + DRM.Division AS Parent
					,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) + DRM.Division + RTRIM(CAST(VDD.VendorId AS Char(12))) + '0' AS Sort
					,90 AS Icon
					,BatchId
					,ISNULL(WeekEndingDate, GETDATE())
					,'' AS VendorId
					,0 AS Fk_DocumentTypeId
					,0 AS FileId
					,DRM.Division
			FROM	View_DriverDocuments VDD
					INNER JOIN VendorMaster DRM ON VDD.VendorId = DRM.VendorId AND VDD.Company = DRM.Company
			WHERE	VDD.Company = @Company
					AND BatchId <> ''
					AND VDD.VendorId <> 'ALL'
					AND WeekEndingDate IN (SELECT BatchDate FROM @tblBatches)
					AND ISNULL(VDD.TerminationDate, DATEADD(DD, 5, GETDATE())) > WeekEndingDate
			UNION
			SELECT	DISTINCT 3 AS RecordType
					,DocumentType
					,DocumentName
					,'DOC_' + RTRIM(CAST(VDD.VendorId AS Char(12))) + '_' + RTRIM(CAST(Fk_DocumentTypeId AS Char(10))) AS Node
					,'VND_' + RTRIM(CAST(VDD.VendorId AS Char(12))) AS Parent
					,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) + DRM.Division + RTRIM(CAST(VDD.VendorId AS Char(12))) + RTRIM(CAST(Sort AS Char(2))) AS Sort
					,Fk_DocumentTypeId AS Icon
					,BatchId
					,ISNULL(WeekEndingDate, GETDATE())
					,VDD.VendorId
					,Fk_DocumentTypeId
					,0 AS FileId
					,DRM.Division
			FROM	View_DriverDocuments VDD
					INNER JOIN VendorMaster DRM ON VDD.VendorId = DRM.VendorId AND VDD.Company = DRM.Company
			WHERE	VDD.Company = @Company
					AND VDD.VendorId <> 'ALL'
					AND WeekEndingDate IN (SELECT BatchDate FROM @tblBatches)
					AND ISNULL(VDD.TerminationDate, DATEADD(DD, 5, GETDATE())) > WeekEndingDate
					AND BatchId <> ''
		) RECS
	ORDER BY WeekEndingDate DESC, Sort, 1

	--select * from @tmpOOS_Documents

	INSERT INTO @tmpOOS_Documents
	SELECT	DISTINCT *
	FROM	(
	SELECT	DISTINCT 1 AS RecordType
					,CONVERT(Char(10), BAT.BatchDate, 101) + ' - ' + RIGHT(RTRIM(BAT.BatchId), 2) AS Display
					,@MergeFiles + RTRIM(BatchId) + '.pdf' AS DocumentName
					,'DAT_' + REPLACE(CONVERT(Char(10), BAT.BatchDate, 101), '/', '') + RIGHT(RTRIM(BAT.BatchId), 2) AS Node
					,Null AS Parent
					,'DAT_' + REPLACE(CONVERT(Char(10), BAT.BatchDate, 101), '/', '') + RIGHT(RTRIM(BAT.BatchId), 2) AS Sort
					,80 AS Icon
					,BAT.BatchId
					,ISNULL(BAT.BatchDate, GETDATE()) AS WeekEndingDate
					,'' AS VendorId
					,0 AS Fk_DocumentTypeId
					,0 AS FileId
					,'' AS Division
			FROM	@tblFileBound DEX
					INNER JOIN @tblDrivers DRV ON DEX.VendorId = DRV.DriverId
					INNER JOIN VendorMaster VMA ON VMA.VendorId = DEX.VendorId AND VMA.Company = @Company
					INNER JOIN DocumentTypes DOT ON DEX.DocType = DOT.OOS_DocType
					LEFT JOIN @tblBatches BAT ON BAT.BatchId LIKE ('%' + DRV.PayType + '%')
			WHERE	DEX.WeekEndigDate > VMA.NewOOSDate
			UNION
			SELECT	DISTINCT 2 AS RecordType
					,DEX.VendorId AS Display
					,'' AS DocumentName
					,'VND_' + RTRIM(CAST(DEX.VendorId AS Char(12))) AS Node
					,'DIV_' + RIGHT(RTRIM(BatchId), 2) + '_' + DRV.Division AS Parent
					,'DAT_' + REPLACE(CONVERT(Char(10), BAT.BatchDate, 101), '/', '') + RIGHT(RTRIM(BAT.BatchId), 2) + DRV.Division + RTRIM(CAST(DEX.VendorId AS Char(12))) + '0' AS Sort
					,90 AS Icon
					,BAT.BatchId
					,ISNULL(BAT.BatchDate, GETDATE()) AS WeekEndingDate
					,DEX.VendorId
					,0 AS Fk_DocumentTypeId
					,0 AS FileId
					,DRV.Division
			FROM	@tblFileBound DEX
					INNER JOIN @tblDrivers DRV ON DEX.VendorId = DRV.DriverId
					INNER JOIN VendorMaster VMA ON VMA.VendorId = DEX.VendorId AND VMA.Company = @Company
					INNER JOIN DocumentTypes DOT ON DEX.DocType = DOT.OOS_DocType
					LEFT JOIN @tblBatches BAT ON BAT.BatchId LIKE ('%' + DRV.PayType + '%')
			WHERE	DEX.WeekEndigDate > VMA.NewOOSDate
			UNION
			SELECT	DISTINCT 3 AS RecordType
					,DOT.DocumentType AS Display
					,DEX.FullFileName AS DocumentName --CAST(DEX.FileId AS varchar) AS DocumentName
					,'VND_' + RTRIM(CAST(DEX.VendorId AS Char(12))) AS Node
					,'VND_' + RTRIM(CAST(DEX.VendorId AS Char(12))) AS Parent
					,'DAT_' + REPLACE(CONVERT(Char(10), BAT.BatchDate, 101), '/', '') + RIGHT(RTRIM(BAT.BatchId), 2) + DRV.Division + RTRIM(CAST(DEX.VendorId AS Char(12))) + '0' AS Sort
					,90 AS Icon
					,BAT.BatchId
					,ISNULL(BAT.BatchDate, GETDATE()) AS WeekEndingDate
					,DEX.VendorId
					,DOT.DocumentTypeId
					,DEX.FileId
					,DRV.Division
			FROM	@tblFileBound DEX
					INNER JOIN @tblDrivers DRV ON DEX.VendorId = DRV.DriverId
					INNER JOIN VendorMaster VMA ON VMA.VendorId = DEX.VendorId AND VMA.Company = @Company
					INNER JOIN DocumentTypes DOT ON DEX.DocType = DOT.OOS_DocType
					LEFT JOIN @tblBatches BAT ON BAT.BatchId LIKE ('%' + DRV.PayType + '%')
			WHERE	DEX.WeekEndigDate > VMA.NewOOSDate
		) DATA

	IF @Notification = 1
	BEGIN
		INSERT INTO @tmpOOS_Documents
		SELECT	2.5 AS RecordType
				,VDR.DocumentType
				,VDR.DocumentName
				,'DOC_' + RTRIM(CAST(VDR.VendorId AS Char(12))) + '_' + RTRIM(CAST(VDR.Fk_DocumentTypeId AS Char(10))) AS Node
				,'VND_' + RTRIM(CAST(VDR.VendorId AS Char(12))) AS Parent
				,'DAT_' + REPLACE(CONVERT(Char(10), VDR. WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(TMP.BatchId), 2) + VMA.Division + RTRIM(CAST(VDR.VendorId AS Char(12))) + RTRIM(CAST(TMP.Sort AS Char(2))) AS Sort
				,VDR.Fk_DocumentTypeId AS Icon
				,TMP.BatchId
				,VDR.WeekEndingDate
				,TMP.VendorId
				,VDR.Fk_DocumentTypeId
				,0 AS FileId
				,'' AS Division
		FROM	@tmpOOS_Documents TMP
				INNER JOIN View_DriverDocuments VDR ON TMP.VendorId = VDR.VendorId AND TMP.WeekEndingDate = VDR.WeekEndingDate AND VDR.Company = @Company AND VDR.Fk_DocumentTypeId = 5 AND TMP.DocumentTypeId = 1
				INNER JOIN VendorMaster VMA ON VMA.VendorId = TMP.VendorId AND VMA.Company = @Company
		WHERE	TMP.DocumentTypeId = 1
	END

	INSERT INTO @tmpOOS_Documents
	SELECT	1.5 AS RecordType
			,'Division ' + Division AS Display
			,@MergeFiles + RTRIM(BatchId) + '_' + Division + '.pdf' AS DocumentName
			,'DIV_' + RIGHT(RTRIM(BatchId), 2) + '_' + Division AS Node
			,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) AS Parent
			,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) + Division AS Sort
			,80 AS Icon
			,BatchId
			,WeekEndingDate
			,'' AS VendorId
			,0 AS Fk_DocumentTypeId
			,0 AS FileId
			,Division
	FROM	(
			SELECT	DISTINCT BatchId, WeekEndingDate, Division
			FROM	@tmpOOS_Documents
			WHERE	Division <> ''
			) DATA

	INSERT INTO [dbo].[DriverDocuments_Inquiry]
			   ([Company]
			   ,[RecordType]
			   ,[Display]
			   ,[DocumentName]
			   ,[Node]
			   ,[Parent]
			   ,[Sort]
			   ,[Icon]
			   ,[BatchId]
			   ,[WeekEndingDate]
			   ,[VendorId]
			   ,[DocumentTypeId]
			   ,[FileId]
			   ,[Division]
			   ,[EmailSent])
	SELECT	DISTINCT @Company AS Company,
			TMP.*, 
			CAST(ISNULL(ELO.EmailSent, 0) AS Bit) AS EmailSent
	FROM	@tmpOOS_Documents TMP
			LEFT JOIN OOS_EmailLog ELO ON TMP.WeekEndingDate = ELO.WeekendingDate AND TMP.VendorId = ELO.vendorId AND ELO.Company = @Company
	ORDER BY TMP.WeekEndingDate DESC, TMP.Sort
END

SELECT	DISTINCT [Company]
		,[RecordType]
		,[Display]
		,[DocumentName]
		,[Node]
		,[Parent]
		,[Sort]
		,[Icon]
		,[BatchId]
		,[WeekEndingDate]
		,[VendorId]
		,[DocumentTypeId]
		,[FileId]
		,[Division]
		,[EmailSent]
		,IIF([FileId] = 0, [DocumentName], CAST([FileId] AS Varchar)) AS ObjectDocument
FROM	DriverDocuments_Inquiry
WHERE	Company = @Company
		AND RecordType = 3
		AND BatchId IS NOT Null
		AND WeekEndingDate IN (SELECT BatchDate FROM @tblBatches)
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(BatchId) + '%', @BatchId) > 0))
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))
		AND (@DocTypes IS Null OR (@DocTypes IS NOT Null AND PATINDEX('%' + RTRIM(CAST(DocumentTypeId AS Char(3))) + '%', @DocTypes) > 0))
		AND (@PaidCard = 0 OR (@PaidCard = 1 AND [VendorId] IN (SELECT VendorId FROM VendorMaster WHERE Company = @Company AND TerminationDate IS Null AND PaidByPayCard = 1)))
ORDER BY WeekEndingDate DESC, BatchId, VendorId, Sort

/*
EXECUTE USP_FindDriverDocuments 'AIS', NULL, 'DSDRV051409CK,DSDRV051409DD,DSDRV050709CK,DSDRV050709DD,', 'A0192'
TRUNCATE TABLE DriverDocuments_Inquiry
*/