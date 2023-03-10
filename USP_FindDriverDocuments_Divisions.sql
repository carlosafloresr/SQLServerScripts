USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindDriverDocuments_Divisions]    Script Date: 5/14/2020 10:33:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindDriverDocuments_Divisions 'CFLORES', 'AIS', '05/14/2020'
EXECUTE USP_FindDriverDocuments_Divisions 'CFLORES', 'HMIS','06/27/2019'
*/
ALTER PROCEDURE [dbo].[USP_FindDriverDocuments_Divisions]
		@UserId		Varchar(25),
		@Company	Varchar(5),
		@CheckDate	Datetime,
		@DocTypes	Varchar(50) = Null,
		@PaidCard	Bit = 0
AS
SET NOCOUNT ON

DECLARE	@tblDivisions	TABLE (Division Char(2), VendorId Varchar(15))

DECLARE	@tblDrivers		TABLE (
		VendorId		Varchar(15),
		DriverName		Varchar(75),
		HireDate		Date,
		TerminationDate	Date Null,
		Division		Varchar(5),
		Agent			Varchar(5),
		DriverType		Varchar(10))

PRINT 'Starting: ' + CONVERT(Varchar, GETDATE(), 9)

INSERT INTO @tblDrivers
EXECUTE Intranet.dbo.USP_DriversByUser @Company, @UserId, 1, 0, NULL, 0

PRINT 'Pulled Drivers: ' + CONVERT(Varchar, GETDATE(), 9)

INSERT INTO @tblDivisions
SELECT	DISTINCT Division, VendorId 
FROM	View_DriverDocuments V2 
WHERE	V2.Company = @Company 
		AND V2.WeekEndingDate = @CheckDate
		AND VendorId IN (SELECT VendorId FROM @tblDrivers)

SELECT	DISTINCT *, --Counter = (SELECT COUNT(*) FROM (SELECT DISTINCT VendorId FROM View_DriverDocuments V2 WHERE V2.Company = @Company AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND V2.WeekEndingDate = @CheckDate)) AND V2.Division = V1.Division) DATA)
		Counter = (SELECT COUNT(*) FROM @tblDivisions DV WHERE DV.Division = V1.Division)
INTO	#tmpData
FROM	View_DriverDocuments V1
WHERE	Company = @Company
		AND BatchId <> ''
		AND VendorId IN (SELECT VendorId FROM @tblDrivers)
		AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND WeekEndingDate = @CheckDate))
		AND (@DocTypes IS Null OR (@DocTypes IS NOT Null AND PATINDEX('%' + RTRIM(CAST(Fk_DocumentTypeId AS Char(3))) + '%', @DocTypes) > 0))
		AND (@PaidCard = 0 OR (@PaidCard = 1 AND PaidByPayCard = 1))

PRINT 'Pulled Driver Data: ' + CONVERT(Varchar, GETDATE(), 9)

INSERT INTO #tmpData
SELECT	DISTINCT V1.DriverDocumentId
		,V3.Company
		,V3.VendorId
		,V3.BatchId
		,V1.WeekEndingDate
		,V1.Fk_DocumentTypeId
		,V1.DocumentName
		,V1.SharedDocumentName
		,V1.DocumentType
		,V1.Sort
		,V3.Category
		,V3.PaidByPayCard
		,V3.Agent
		,V3.Division
		,V3.FileFixed
		,0 AS Counter --= (SELECT COUNT(*) FROM (SELECT DISTINCT VendorId FROM View_DriverDocuments V2 WHERE V2.Company = V1.Company AND V2.WeekEndingDate = V1.WeekEndingDate AND V2.Division = V1.Division) DATA)
FROM	View_DriverDocuments V1
		INNER JOIN #tmpData V3 ON V1.Company = V3.Company AND V1.WeekEndingDate = V3.WeekEndingDate AND V1.VendorId = V3.VendorId AND V3.Fk_DocumentTypeId = 1
WHERE	V1.Company = @Company
		AND V1.BatchId = ''
		--AND V1.VendorId = 'ALL'
		AND V1.Fk_DocumentTypeId = 5
		AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND V1.WeekEndingDate = @CheckDate))

PRINT 'Pulled Company Notifications: ' + CONVERT(Varchar, GETDATE(), 9)

SELECT	DISTINCT *
FROM	(
		SELECT	DISTINCT Division
				,'' AS VendorId
				,Division AS Sort
				,'Division ' + RTRIM(Division) + ' - ' + CONVERT(Char(10), WeekEndingDate, 101) AS Display
				,'' AS DocumentName
				,'' AS SharedDocumentName
				,'DIV_' + RTRIM(Division) AS Node
				,'' AS Parent
				,80 AS Icon
				,'' AS BatchId
				,WeekEndingDate
				,1 AS RecordType
		FROM	#tmpData
		UNION
		SELECT	DISTINCT Division
						,'' AS VendorId
						,Division + '_DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) + RTRIM(CAST(1 AS Char(2))) AS Sort
						,BatchId AS Display
						,RTRIM(@Company) + '_Division' + Division + '_' + RTRIM(BatchId) + '.pdf' AS DocumentName
						,'' AS SharedDocumentName
						,'BCH_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RTRIM(Division) + RIGHT(RTRIM(BatchId), 2) AS Node
						,'DIV_' + RTRIM(Division) AS Parent
						,80 AS Icon
						,BatchId
						,WeekEndingDate
						,2 AS RecordType
				FROM	#tmpData
		UNION
		SELECT	DISTINCT Division
						,VendorId
						,Division + '_DAT_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RIGHT(RTRIM(BatchId), 2) + RTRIM(CAST(VendorId AS Char(12))) + RTRIM(CAST(Sort AS Char(2))) AS Sort
						,DocumentType
						,DocumentName
						,SharedDocumentName
						,'ADOC_' + RTRIM(CAST(VendorId AS Char(12))) + '_' + RTRIM(CAST(Fk_DocumentTypeId AS Char(10))) AS Node
						,'BCH_' + REPLACE(CONVERT(Char(10), WeekEndingDate, 101), '/', '') + RTRIM(Division) + RIGHT(RTRIM(BatchId), 2) AS Parent
						,Fk_DocumentTypeId AS Icon
						,BatchId
						,WeekEndingDate
						,3 AS RecordType
				FROM	#tmpData
		) DATA
ORDER BY 
		Division,
		BatchId, 
		VendorId, 
		Sort

DROP TABLE #tmpData
