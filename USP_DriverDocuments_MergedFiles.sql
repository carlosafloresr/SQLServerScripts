/*
EXECUTE USP_DriverDocuments_MergedFiles @Company = 'GIS', @CheckDate = Null, @BatchId = 'DSDR042921CK,DSDR042921DD,DSDR042221CK,DSDR042221DD,'
EXECUTE USP_DriverDocuments_MergedFiles @Company = 'AIS', @CheckDate = '07/29/2021'
*/
ALTER PROCEDURE [dbo].[USP_DriverDocuments_MergedFiles]
		@Company	Varchar(5),
		@CheckDate	Datetime = Null,
		@BatchId	Varchar(500) = Null,
		@VendorId	Varchar(12) = Null,
		@DocTypes	Varchar(50) = Null,
		@PaidCard	Bit = 0
AS
DECLARE @tblBatches		Table (
		Company			Varchar(5),
		BatchId			Varchar(25),
		BatchDate		Date)

SET @CheckDate = IIF(@BatchId IS Null, @CheckDate, Null)

INSERT INTO @tblBatches
SELECT	DISTINCT [Company], RTRIM([BACHNUMB]) AS BACHNUMB, CAST(IIF(DATEPART(DW, [DOCDATE]) < 5, dbo.DayFwdBack([DOCDATE], 'N', 'Thursday'), [DOCDATE]) AS Date) AS DOCDATE
FROM	[GPCustom].[dbo].[PM10300]
WHERE	Company = @Company
		AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND DOCDATE BETWEEN DATEADD(DD, -4, @CheckDate) AND @CheckDate))
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(BACHNUMB) + '%', @BatchId) > 0))
		AND RIGHT(RTRIM(BACHNUMB), 2) IN ('CK','DD')
ORDER BY BACHNUMB

SELECT	DISTINCT [Company]
		,[RecordType]
		,[Display]
		,DocumentName
		,[Node]
		,[Parent]
		,[Sort]
		,[Icon]
		,[BatchId]
		,[WeekEndingDate]
		,[VendorId]
		,[DocumentTypeId]
		,[FileId]
		,IIF(Division = '', 'ALL', Division) AS [Division]
		,[EmailSent]
FROM	DriverDocuments_Inquiry
WHERE	Company = @Company
		AND WeekEndingDate IN (SELECT BatchDate FROM @tblBatches)
		AND RecordType < 2
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(BatchId) + '%', @BatchId) > 0))
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))
		AND (@DocTypes IS Null OR (@DocTypes IS NOT Null AND PATINDEX('%' + RTRIM(CAST(DocumentTypeId AS Char(3))) + '%', @DocTypes) > 0))
ORDER BY WeekEndingDate DESC, BatchId, Division