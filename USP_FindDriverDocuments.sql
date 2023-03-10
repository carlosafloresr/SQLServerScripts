USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindDriverDocuments]    Script Date: 5/14/2020 8:19:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindDriverDocuments 'AIS', '05/14/2020', 'DSDR051420CK,DSDR051420DD,', 'A50462', NULL, 0
EXECUTE USP_FindDriverDocuments 'AIS', Null, 'DSDR040220CK,DSDR040220DD,DSDR032620CK,DSDR032620DD,DSDR031920CK,DSDR031920DD,', NULL, NULL, 0
*/
ALTER PROCEDURE [dbo].[USP_FindDriverDocuments]
		@Company	Varchar(5),
		@CheckDate	Datetime = Null,
		@BatchId	Varchar(500) = Null,
		@VendorId	Varchar(12) = Null,
		@DocTypes	Varchar(50) = Null,
		@PaidCard	Bit = 0
AS
SET NOCOUNT ON
DECLARE	@PayDate	Date = @CheckDate

IF dbo.OCCURS(',', @BatchId) > 1
	SET @CheckDate = Null

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
	[DocumentTypeId]	[int])

IF EXISTS(SELECT TOP 1 WeekEndingDate FROM DriverDocuments WHERE Company = @Company AND WeekEndingDate = @PayDate AND Fk_DocumentTypeId = 5 AND VendorId = 'ALL')
	SET @Notification = 1

PRINT @Notification

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
				,VendorId AS Display
				,Null AS DocumentName
				,'VND_' + RTRIM(CAST(VendorId AS Char(12))) AS Node
				,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) AS Parent
				,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) + RTRIM(CAST(VendorId AS Char(12))) + '0' AS Sort
				,90 AS Icon
				,BatchId
				,WeekEndingDate
				,'' AS VendorId
				,0 AS Fk_DocumentTypeId
		FROM	View_DriverDocuments
		WHERE	Company = @Company
				AND BatchId <> ''
				AND VendorId <> 'ALL'
				AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND WeekEndingDate = @CheckDate))
				AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(BatchId) + '%', @BatchId) > 0))
				AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))
				AND (@DocTypes IS Null OR (@DocTypes IS NOT Null AND PATINDEX('%' + RTRIM(CAST(Fk_DocumentTypeId AS Char(3))) + '%', @DocTypes) > 0))
				AND (@PaidCard = 0 OR (@PaidCard = 1 AND PaidByPayCard = 1))
		UNION
		SELECT	DISTINCT 3 AS RecordType
				,DocumentType
				,DocumentName
				,'DOC_' + RTRIM(CAST(VendorId AS Char(12))) + '_' + RTRIM(CAST(Fk_DocumentTypeId AS Char(10))) AS Node
				,'VND_' + RTRIM(CAST(VendorId AS Char(12))) AS Parent
				,'DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) + RTRIM(CAST(VendorId AS Char(12))) + RTRIM(CAST(Sort AS Char(2))) AS Sort
				,Fk_DocumentTypeId AS Icon
				,BatchId
				,WeekEndingDate
				,VendorId
				,Fk_DocumentTypeId
		FROM	View_DriverDocuments
		WHERE	Company = @Company
				AND VendorId <> 'ALL'
				AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND WeekEndingDate = @CheckDate))
				AND BatchId <> ''
				AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(BatchId) + '%', @BatchId) > 0))
				AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))
				AND (@DocTypes IS Null OR (@DocTypes IS NOT Null AND PATINDEX('%' + RTRIM(CAST(Fk_DocumentTypeId AS Char(3))) + '%', @DocTypes) > 0))
				AND (@PaidCard = 0 OR (@PaidCard = 1 AND PaidByPayCard = 1))
	) RECS
ORDER BY WeekEndingDate DESC, Sort, 1

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
	FROM	@tmpDocs TMP
			INNER JOIN View_DriverDocuments VDR ON TMP.VendorId = VDR.VendorId AND TMP.WeekEndingDate = VDR.WeekEndingDate AND VDR.Company = @Company AND VDR.Fk_DocumentTypeId = 5 AND TMP.DocumentTypeId = 1
	WHERE	TMP.DocumentTypeId = 1
END

SELECT	DISTINCT *
FROM	@tmpDocs
ORDER BY WeekEndingDate DESC, Sort

/*
EXECUTE USP_FindDriverDocuments 'AIS', NULL, 'DSDRV051409CK,DSDRV051409DD,DSDRV050709CK,DSDRV050709DD,', 'A0192'
*/