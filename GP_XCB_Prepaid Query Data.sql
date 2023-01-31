/*
EXECUTE USP_GL_XCB_DetailTrailBalance_Report 'NOV-22'
*/
CREATE PROCEDURE USP_GL_XCB_DetailTrailBalance_Report
		@GP_Period		Char(6)
AS
SET NOCOUNT ON

DECLARE	@GLAccount		Varchar(15) = '0-88-1866',
		@AcctIndex		Int,
		@FiscalPeriod	Char(7),
		@StartDate		Date,
		@EndDate		Date,
		@ReportTotal	Numeric(12,2) = 0,
		@Counter		Int = 0

SET @AcctIndex = (SELECT ACTINDX FROM GLSO.dbo.GL00105 WHERE ACTNUMST = @GLAccount)

SET @FiscalPeriod = CASE LEFT(@GP_Period, 3)
			 WHEN 'JAN' THEN '01-20'
			 WHEN 'FEB' THEN '02-20'
			 WHEN 'MAR' THEN '03-20'
			 WHEN 'APR' THEN '04-20'
			 WHEN 'MAY' THEN '05-20'
			 WHEN 'JUN' THEN '06-20'
			 WHEN 'JUL' THEN '07-20'
			 WHEN 'AUG' THEN '08-20'
			 WHEN 'SEP' THEN '09-20'
			 WHEN 'OCT' THEN '10-20'
			 WHEN 'NOV' THEN '11-20'
			 ELSE '12-20' END + RIGHT(@GP_Period, 2)

SELECT	@StartDate	= StartDate,
		@EndDate	= EndDate
FROM	DYNAMICS.dbo.View_Fiscalperiod 
WHERE	GP_Period = @FiscalPeriod

SELECT	*
INTO	#tmpReport
FROM	(
		SELECT	0 AS RecordId,
				'12/01/2019' AS TrxDate, -- PREVIOUS MONTHS MATCHED
				0 AS JournalNo,
				'' AS Audit_Trial,
				'Previous Matched' AS [Distribution Reference],
				'' AS DocumentNo,
				'' AS Vendor,
				SUM(XCB.Amount) AS Amount,
				'00 Matched' AS ProNumber,
				'PREV' AS [AP Period],
				'Auto' AS [Initials of SWS Validation],
				CAST(GETDATE() AS Date) AS [Date Validated],
				'' AS [Payout in SWS],
				Null AS Manifested,
				SUM(ISNULL(XCB.SWSVndCost, 0)) AS [VP Cost],
				'' AS [Manifested Y/N],
				'' AS SWSStatus,
				'Y' AS Matched,
				'12/01/2019' AS FP_StartDate,
				'PREV_MONTH_MATCHED' AS DataType
		FROM	GP_XCB_Prepaid XCB
		WHERE	XCB.FP_StartDate < @StartDate
				AND XCB.Matched = 1
		UNION
		SELECT	XCB.RecordId,
				XCB.TrxDate, -- PREVIOUS MONTHS UNMATCHED
				XCB.JournalNo,
				XCB.Audit_Trial,
				XCB.Reference AS [Distribution Reference],
				ISNULL(IIF(XCB.DocumentNo = '', XCB.SWSVndInvoice, XCB.DocumentNo), '') AS DocumentNo,
				ISNULL(IIF(XCB.Vendor = '', XCB.SWSVendor, XCB.Vendor), '') AS Vendor,
				XCB.Amount,
				XCB.ProNumber,
				XCB.GPPeriod AS [AP Period],
				'Auto' AS [Initials of SWS Validation],
				CAST(GETDATE() AS Date) AS [Date Validated],
				IIF(SWSVendor IS Null, 'N', 'Y') AS [Payout in SWS],
				IIF(XCB.SWSManifestDate IS Null, '', FORMAT(XCB.SWSManifestDate, 'd', 'en-US')) AS Manifested,
				ISNULL(XCB.SWSVndCost, 0) AS [VP Cost],
				IIF(XCB.SWSManifestDate IS Null, 'No', 'Yes') AS [Manifested Y/N],
				ISNULL(XCB.SWSStatus, '') AS SWSStatus,
				'N' AS Matched,
				XCB.FP_StartDate,
				'PREV_MONTH_UNMATCHED' AS DataType
		FROM	GP_XCB_Prepaid XCB
		WHERE	XCB.FP_StartDate < @StartDate
				AND XCB.Matched = 0
		UNION
		SELECT	XCB.RecordId,
				XCB.TrxDate, -- REPORTING MONTH
				XCB.JournalNo,
				XCB.Audit_Trial,
				XCB.Reference AS [Distribution Reference],
				ISNULL(IIF(XCB.DocumentNo = '', XCB.SWSVndInvoice, XCB.DocumentNo), '') AS DocumentNo,
				ISNULL(IIF(XCB.Vendor = '', XCB.SWSVendor, XCB.Vendor), '') AS Vendor,
				XCB.Amount,
				XCB.ProNumber,
				XCB.GPPeriod AS [AP Period],
				'Auto' AS [Initials of SWS Validation],
				CAST(GETDATE() AS Date) AS [Date Validated],
				IIF(SWSVendor IS Null, 'N', 'Y') AS [Payout in SWS],
				IIF(XCB.SWSManifestDate IS Null, '', FORMAT(XCB.SWSManifestDate, 'd', 'en-US')) AS Manifested,
				ISNULL(XCB.SWSVndCost, 0) AS [VP Cost],
				IIF(XCB.SWSManifestDate IS Null, 'No', 'Yes') AS [Manifested Y/N],
				ISNULL(XCB.SWSStatus, '') AS SWSStatus,
				'Y' AS Matched,
				XCB.FP_StartDate,
				'REPORTING_MONTH' AS DataType
		FROM	GP_XCB_Prepaid XCB
		WHERE	XCB.GPPeriod = @GP_Period
		) DATA

UPDATE	#tmpReport
SET		[Payout in SWS] = 'N',
		Manifested = '',
		[VP Cost] = 0,
		[Manifested Y/N] = 'N',
		SWSStatus = ''
FROM	(
		SELECT	RecordId AS RowId
		FROM	#tmpReport
		WHERE	CAST(Manifested AS Date) > @EndDate
				AND DataType <> 'PREV_MONTH_MATCHED'
		) DATA
WHERE	RecordId = DATA.RowId

SELECT	RecordId,
		TrxDate,
		JournalNo,
		Audit_Trial,
		[Distribution Reference],
		DocumentNo,
		Vendor,
		Amount,
		ProNumber,
		[AP Period],
		[Initials of SWS Validation],
		[Date Validated],
		[Payout in SWS],
		Manifested,
		[VP Cost],
		[Manifested Y/N],
		SWSStatus,
		[Matched]
FROM	#tmpReport
ORDER BY DataType, ProNumber, ABS(Amount), FP_StartDate, Amount

--SELECT	@ReportTotal = SUM(Amount),
--		@Counter = COUNT(*) 
--FROM	#tmpReport

--PRINT @StartDate
--PRINT @Counter

--PRINT FORMAT(@ReportTotal, 'N', 'en-us')

DROP TABLE #tmpReport

/*
$ 56,217,226.95
DROP TABLE tmpXCBNovember
SELECT * FROM DYNAMICS.dbo.View_Fiscalperiod FP WHERE YEAR1 = 2022 ORDER BY PERIODID

DECLARE @Counter Int = 0

WHILE @Counter <= 3
BEGIN
	EXECUTE USP_GP_XCB_PrepaidMatchingProcess 0

	SET @Counter = @Counter + 1
END

SELECT	COUNT(*) AS Counter
FROM	GP_XCB_Prepaid
WHERE	SWSManifestDate IS Null

171282
*/