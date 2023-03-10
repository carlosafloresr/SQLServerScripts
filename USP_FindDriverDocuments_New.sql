USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindDriverDocuments]    Script Date: 4/14/2021 9:45:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindDriverDocuments_New 'AIS', '04/15/2021'
EXECUTE USP_FindDriverDocuments 'IMC', '04/08/2021', 'DSDR122920DD,', NULL, NULL, 0
EXECUTE USP_FindDriverDocuments 'AIS', Null, 'DSDR040220CK,DSDR040220DD,DSDR032620CK,DSDR032620DD,DSDR031920CK,DSDR031920DD,', NULL, NULL, 0
*/
ALTER PROCEDURE [dbo].[USP_FindDriverDocuments_New]
		@Company	Varchar(5),
		@CheckDate	Datetime = Null,
		@BatchId	Varchar(500) = Null,
		@VendorId	Varchar(12) = Null,
		@DocTypes	Varchar(50) = Null,
		@PaidCard	Bit = 0
AS
SET NOCOUNT ON
DECLARE	@PayDate	Date = @CheckDate,
		@ProjectID	Int = 165,
		@CompanyNum	Int,
		@OOSDate	Date,
		@Query		Varchar(2000)

IF dbo.OCCURS(',', @BatchId) > 1
	SET @CheckDate = Null

SET @CompanyNum	= (SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company)
SET @OOSDate	= dbo.DayFwdBack(@CheckDate, 'P', 'Saturday')

DECLARE @BaseBatch		Varchar(15) = REPLACE(REPLACE(@BatchId, 'CK', ''), 'DD', ''),
		@Notification	Bit = 0

DECLARE @tmpDocs		Table (
	[RecordType]		[numeric](5, 1) NOT NULL,
	[Display]			[varchar](50) NULL,
	[DocumentName]		[varchar](250) NULL,
	[Node]				[varchar](25) NULL,
	[Parent]			[varchar](25) NULL,
	[Sort]				[varchar](100) NULL,
	[Icon]				[int] NOT NULL,
	[BatchId]			[varchar](20) NULL,
	[WeekEndingDate]	[datetime] NOT NULL,
	[VendorId]			[varchar](15),
	[DocumentTypeId]	[int],
	[FileId]			[int],
	[Division]			[char](2))

DECLARE @tblBatches		Table (
	Company				Varchar(5),
	BatchId				Varchar(25),
	BatchDate			Date)

DECLARE @tblDrivers		Table (
	DriverId			Varchar(15),
	PayType				Char(2),
	Division			Char(2))

IF EXISTS(SELECT TOP 1 WeekEndingDate FROM DriverDocuments WHERE Company = @Company AND WeekEndingDate = @PayDate AND Fk_DocumentTypeId = 5 AND VendorId = 'ALL')
	SET @Notification = 1

PRINT @Notification

SET @Query = 'SELECT driver_id, payment_method, division FROM OOS.Driver_Info WHERE COMPANY_ID = ' + CAST(@CompanyNum AS Varchar)

INSERT INTO @tblDrivers
EXECUTE USP_QuerySWS @Query, Null, 'POSTGRESQL_IMC_ENTERPRISE'

INSERT INTO @tblBatches
SELECT	DISTINCT [Company], RTRIM([BACHNUMB]) AS BACHNUMB, CAST([DOCDATE] AS Date) AS DOCDATE
FROM	[GPCustom].[dbo].[PM10300]
WHERE	Company = @Company
		AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND DOCDATE = @CheckDate))
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(BACHNUMB) + '%', @BatchId) > 0))
		AND RIGHT(RTRIM(BACHNUMB), 2) IN ('CK','DD')
ORDER BY BACHNUMB

INSERT INTO @tmpDocs
SELECT	DISTINCT *
FROM	(
		SELECT	DISTINCT 1 AS RecordType
				,CONVERT(Char(10), WeekEndingDate, 101) + ' - ' + RTRIM(BatchId) AS Display
				,Null AS DocumentName
				,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) AS Node
				,Null AS Parent
				,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) AS Sort
				,80 AS Icon
				,BatchId
				,WeekEndingDate
				,'' AS VendorId
				,0 AS Fk_DocumentTypeId
				,0 AS FileId
				,'' AS Division
		FROM	View_DriverDocuments
		WHERE	Company = @Company
				AND BatchId <> ''
				AND VendorId <> 'ALL'
				--AND (BatchId LIKE '%CK%' OR BatchId LIKE '%DD%')
				AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND WeekEndingDate = @CheckDate))
				AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(BatchId) + '%', @BatchId) > 0))
				AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))
				AND (@DocTypes IS Null OR (@DocTypes IS NOT Null AND PATINDEX('%' + RTRIM(CAST(Fk_DocumentTypeId AS Char(3))) + '%', @DocTypes) > 0))
				AND (@PaidCard = 0 OR (@PaidCard = 1 AND PaidByPayCard = 1))
		UNION
		SELECT	DISTINCT 2 AS RecordType
				,'      ' + VDD.VendorId AS Display
				,Null AS DocumentName
				,'VND_' + RTRIM(CAST(VDD.VendorId AS Char(12))) AS Node
				,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) AS Parent
				,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) + RTRIM(CAST(VDD.VendorId AS Char(12))) + '0' AS Sort
				,90 AS Icon
				,BatchId
				,WeekEndingDate
				,'' AS VendorId
				,0 AS Fk_DocumentTypeId
				,0 AS FileId
				,DRM.Division
		FROM	View_DriverDocuments VDD
				INNER JOIN VendorMaster DRM ON VDD.VendorId = DRM.VendorId AND VDD.Company = DRM.Company
		WHERE	VDD.Company = @Company
				AND BatchId <> ''
				AND VDD.VendorId <> 'ALL'
				AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND WeekEndingDate = @CheckDate))
				AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(BatchId) + '%', @BatchId) > 0))
				AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VDD.VendorId = @VendorId))
				AND (@DocTypes IS Null OR (@DocTypes IS NOT Null AND PATINDEX('%' + RTRIM(CAST(Fk_DocumentTypeId AS Char(3))) + '%', @DocTypes) > 0))
				AND (@PaidCard = 0 OR (@PaidCard = 1 AND VDD.PaidByPayCard = 1))
		UNION
		SELECT	DISTINCT 3 AS RecordType
				,'          ' + DocumentType
				,DocumentName
				,'DOC_' + RTRIM(CAST(VDD.VendorId AS Char(12))) + '_' + RTRIM(CAST(Fk_DocumentTypeId AS Char(10))) AS Node
				,'VND_' + RTRIM(CAST(VDD.VendorId AS Char(12))) AS Parent
				,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) + RTRIM(CAST(VDD.VendorId AS Char(12))) + RTRIM(CAST(Sort AS Char(2))) AS Sort
				,Fk_DocumentTypeId AS Icon
				,BatchId
				,WeekEndingDate
				,VDD.VendorId
				,Fk_DocumentTypeId
				,0 AS FileId
				,DRM.Division
		FROM	View_DriverDocuments VDD
				INNER JOIN VendorMaster DRM ON VDD.VendorId = DRM.VendorId AND VDD.Company = DRM.Company
		WHERE	VDD.Company = @Company
				AND VDD.VendorId <> 'ALL'
				AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND WeekEndingDate = @CheckDate))
				AND BatchId <> ''
				AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(BatchId) + '%', @BatchId) > 0))
				AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VDD.VendorId = @VendorId))
				AND (@DocTypes IS Null OR (@DocTypes IS NOT Null AND PATINDEX('%' + RTRIM(CAST(Fk_DocumentTypeId AS Char(3))) + '%', @DocTypes) > 0))
				AND (@PaidCard = 0 OR (@PaidCard = 1 AND VDD.PaidByPayCard = 1))
	) RECS
ORDER BY WeekEndingDate DESC, Sort, 1

INSERT INTO @tmpDocs
SELECT	DISTINCT *
FROM	(
SELECT	DISTINCT 1 AS RecordType
				,CONVERT(Char(10), BAT.BatchDate, 101) + ' - ' + RTRIM(BAT.BatchId) AS Display
				,Null AS DocumentName
				,'DAT_' + REPLACE(CONVERT(Char(10), BAT.BatchDate, 101), '/', '') + RIGHT(RTRIM(BAT.BatchId), 2) AS Node
				,Null AS Parent
				,'DAT_' + REPLACE(CONVERT(Char(10), BAT.BatchDate, 101), '/', '') + RIGHT(RTRIM(BAT.BatchId), 2) AS Sort
				,80 AS Icon
				,BAT.BatchId
				,BAT.BatchDate
				,'' AS VendorId
				,0 AS Fk_DocumentTypeId
				,0 AS FileId
				,'' AS Division
		FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments DEX
				INNER JOIN @tblDrivers DRV ON DEX.Field2 = DRV.DriverId
				INNER JOIN VendorMaster VMA ON VMA.VendorId = DEX.Field2 AND VMA.Company = @Company
				INNER JOIN DocumentTypes DOT ON DEX.Field5 = DOT.OOS_DocType
				LEFT JOIN @tblBatches BAT ON BAT.BatchId LIKE ('%' + DRV.PayType + '%')
		WHERE	DEX.ProjectID = @ProjectID
				AND DEX.Field1 = @CompanyNum
				AND CAST(DEX.Field4 AS Date) > VMA.NewOOSDate
				AND CAST(DEX.Field4 AS Date) BETWEEN @OOSDate AND @CheckDate
				AND DOT.DocumentType <> 'Settlement Sheet'
		UNION
		SELECT	DISTINCT 2 AS RecordType
				,'      ' + DEX.Field2 AS Display
				,Null AS DocumentName
				,'VND_' + RTRIM(CAST(DEX.Field2 AS Char(12))) AS Node
				,'DAT_' + REPLACE(CONVERT(Char(10), BAT.BatchDate, 101), '/', '') + RIGHT(RTRIM(BAT.BatchId), 2) AS Parent
				,'DAT_' + REPLACE(CONVERT(Char(10), BAT.BatchDate, 101), '/', '') + RIGHT(RTRIM(BAT.BatchId), 2) + RTRIM(CAST(DEX.Field2 AS Char(12))) + '0' AS Sort
				,90 AS Icon
				,BAT.BatchId
				,BAT.BatchDate
				,'' AS VendorId
				,0 AS Fk_DocumentTypeId
				,0 AS FileId
				,DRV.Division
		FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments DEX
				INNER JOIN @tblDrivers DRV ON DEX.Field2 = DRV.DriverId
				INNER JOIN VendorMaster VMA ON VMA.VendorId = DEX.Field2 AND VMA.Company = @Company
				INNER JOIN DocumentTypes DOT ON DEX.Field5 = DOT.OOS_DocType
				LEFT JOIN @tblBatches BAT ON BAT.BatchId LIKE ('%' + DRV.PayType + '%')
		WHERE	DEX.ProjectID = @ProjectID
				AND DEX.Field1 = @CompanyNum
				AND CAST(DEX.Field4 AS Date) > VMA.NewOOSDate
				AND CAST(DEX.Field4 AS Date) BETWEEN @OOSDate AND @CheckDate
				AND DOT.DocumentType <> 'Settlement Sheet'
		UNION
		SELECT	DISTINCT 3 AS RecordType
				,'          ' + DOT.DocumentType AS Display
				,CAST(DEX.FileId AS Varchar) AS DocumentName --FullFileName AS DocumentName
				,'VND_' + RTRIM(CAST(DEX.Field2 AS Char(12))) AS Node
				,'VND_' + RTRIM(CAST(DEX.Field2 AS Char(12))) AS Parent
				,'DAT_' + REPLACE(CONVERT(Char(10), BAT.BatchDate, 101), '/', '') + RIGHT(RTRIM(BAT.BatchId), 2) + RTRIM(CAST(DEX.Field2 AS Char(12))) + '0' AS Sort
				,90 AS Icon
				,BAT.BatchId
				,BAT.BatchDate
				,'' AS VendorId
				,DOT.DocumentTypeId
				,DEX.FileId
				,DRV.Division
		FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments DEX
				INNER JOIN @tblDrivers DRV ON DEX.Field2 = DRV.DriverId
				INNER JOIN VendorMaster VMA ON VMA.VendorId = DEX.Field2 AND VMA.Company = @Company
				INNER JOIN DocumentTypes DOT ON DEX.Field5 = DOT.OOS_DocType
				LEFT JOIN @tblBatches BAT ON BAT.BatchId LIKE ('%' + DRV.PayType + '%')
		WHERE	DEX.ProjectID = @ProjectID
				AND DEX.Field1 = @CompanyNum
				AND CAST(DEX.Field4 AS Date) > VMA.NewOOSDate
				AND CAST(DEX.Field4 AS Date) BETWEEN @OOSDate AND @CheckDate
				AND DOT.DocumentType <> 'Settlement Sheet'
	) DATA

IF @Notification = 1
BEGIN
	INSERT INTO @tmpDocs
	SELECT	2.5 AS RecordType
			,VDR.DocumentType
			,VDR.DocumentName
			,'DOC_' + RTRIM(CAST(VDR.VendorId AS Char(12))) + '_' + RTRIM(CAST(VDR.Fk_DocumentTypeId AS Char(10))) AS Node
			,'VND_' + RTRIM(CAST(VDR.VendorId AS Char(12))) AS Parent
			,'DAT_' + REPLACE(CONVERT(Char(10), VDR. WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(TMP.BatchId), 2) + RTRIM(CAST(VDR.VendorId AS Char(12))) + RTRIM(CAST(TMP.Sort AS Char(2))) AS Sort
			,VDR.Fk_DocumentTypeId AS Icon
			,TMP.BatchId
			,VDR.WeekEndingDate
			,TMP.VendorId
			,VDR.Fk_DocumentTypeId
			,0 AS FileId
			,'' AS Division
	FROM	@tmpDocs TMP
			INNER JOIN View_DriverDocuments VDR ON TMP.VendorId = VDR.VendorId AND TMP.WeekEndingDate = VDR.WeekEndingDate AND VDR.Company = @Company AND VDR.Fk_DocumentTypeId = 5 AND TMP.DocumentTypeId = 1
	WHERE	TMP.DocumentTypeId = 1
END

SELECT	DISTINCT TMP.*, CAST(ISNULL(ELO.EmailSent, 0) AS Bit) AS EmailSent
FROM	@tmpDocs TMP
		LEFT JOIN OOS_EmailLog ELO ON TMP.WeekEndingDate = ELO.WeekendingDate AND TMP.VendorId = ELO.vendorId AND ELO.Company = @Company
ORDER BY TMP.WeekEndingDate DESC, TMP.Sort

/*
EXECUTE USP_FindDriverDocuments 'AIS', NULL, 'DSDRV051409CK,DSDRV051409DD,DSDRV050709CK,DSDRV050709DD,', 'A0192'
*/