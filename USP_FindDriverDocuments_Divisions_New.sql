USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindDriverDocuments_Divisions]    Script Date: 4/14/2021 2:21:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindDriverDocuments_Divisions_New 'CFLORES', 'AIS', '04/08/2021'
*/
ALTER PROCEDURE [dbo].[USP_FindDriverDocuments_Divisions_New]
		@UserId		Varchar(25),
		@Company	Varchar(5),
		@CheckDate	Datetime,
		@DocTypes	Varchar(50) = Null,
		@PaidCard	Bit = 0
AS
SET NOCOUNT ON
DECLARE	@PayDate	Date = @CheckDate,
		@ProjectID	Int = 165,
		@CompanyNum	Int,
		@OOSDate	Date,
		@Query		Varchar(2000)

DECLARE	@tblDivisions	TABLE (Division Char(2), VendorId Varchar(15))

DECLARE	@tblDrivers		TABLE (
		VendorId		Varchar(15),
		DriverName		Varchar(75),
		HireDate		Date,
		TerminationDate	Date Null,
		Division		Varchar(5),
		Agent			Varchar(5),
		DriverType		Varchar(10))

DECLARE @tblBatches		Table (
		Company			Varchar(5),
		BatchId			Varchar(25),
		BatchDate		Date)

DECLARE @tblOOSDrivers	Table (
		DriverId		Varchar(15),
		PayType			Char(2))

SET @CompanyNum	= (SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company)
SET @OOSDate	= dbo.DayFwdBack(@CheckDate, 'P', 'Saturday')

PRINT 'Starting: ' + CONVERT(Varchar, GETDATE(), 9)

SET @Query = 'SELECT driver_id, payment_method FROM OOS.Driver_Info WHERE COMPANY_ID = ' + CAST(@CompanyNum AS Varchar)

INSERT INTO @tblOOSDrivers
EXECUTE USP_QuerySWS @Query, Null, 'POSTGRESQL_IMC_ENTERPRISE'

INSERT INTO @tblBatches
SELECT	DISTINCT [Company], RTRIM([BACHNUMB]) AS BACHNUMB, CAST([DOCDATE] AS Date) AS DOCDATE
FROM	[GPCustom].[dbo].[PM10300]
WHERE	Company = @Company
		AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND DOCDATE = @CheckDate))
		AND RIGHT(RTRIM(BACHNUMB), 2) IN ('CK','DD')
ORDER BY BACHNUMB

INSERT INTO @tblDrivers
EXECUTE Intranet.dbo.USP_DriversByUser @Company, @UserId, 1, 0, NULL, 0

PRINT 'Pulled Drivers: ' + CONVERT(Varchar, GETDATE(), 9)

INSERT INTO @tblDivisions
SELECT	DISTINCT V2.Division, V2.VendorId 
FROM	VendorMaster V2
		INNER JOIN @tblDrivers DRV ON V2.VendorId = DRV.VendorId
WHERE	V2.Company = @Company
		AND V2.VendorId IN (SELECT VendorId FROM DriverDocuments WHERE Company = @Company AND WeekEndingDate = @CheckDate AND Fk_DocumentTypeId = 5)

PRINT 'Pulled Drivers Divisions: ' + CONVERT(Varchar, GETDATE(), 9)

SELECT	DISTINCT V1.*,
		Counter = (SELECT COUNT(*) FROM @tblDivisions DV WHERE DV.Division = V1.Division)
INTO	#tmpData
FROM	View_DriverDocuments V1
		INNER JOIN @tblDrivers DRV ON V1.VendorId = DRV.VendorId
WHERE	Company = @Company
		AND BatchId <> ''
		AND WeekEndingDate = @CheckDate
		AND (@DocTypes IS Null OR (@DocTypes IS NOT Null AND PATINDEX('%' + RTRIM(CAST(Fk_DocumentTypeId AS Char(3))) + '%', @DocTypes) > 0))
		AND (@PaidCard = 0 OR (@PaidCard = 1 AND PaidByPayCard = 1))

PRINT	@@ROWCOUNT
PRINT	'Pulled Driver Data: ' + CONVERT(Varchar, GETDATE(), 9)

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
		,V3.NewOOSDate
		,0 AS Counter
FROM	View_DriverDocuments V1
		INNER JOIN #tmpData V3 ON V1.DriverDocumentId = V3.DriverDocumentId --V1.Company = V3.Company AND V1.WeekEndingDate = V3.WeekEndingDate AND V1.VendorId = V3.VendorId AND V3.Fk_DocumentTypeId = 1
WHERE	V1.Company = @Company
		AND V1.BatchId = ''
		AND V1.Fk_DocumentTypeId = 5
		AND V1.WeekEndingDate = @CheckDate

PRINT	@@ROWCOUNT
PRINT	'Pulled Company Notifications: ' + CONVERT(Varchar, GETDATE(), 9)

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
