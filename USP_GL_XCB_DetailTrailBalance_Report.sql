USE GPCustom 
GO 
/*
EXECUTE USP_GL_XCB_DetailTrailBalance_Report 'GLSO', '0-88-1866', 'DEC-22'
EXECUTE USP_GL_XCB_DetailTrailBalance_Report 'GLSO', '0-00-2105', 'DEC-22'
EXECUTE USP_GL_XCB_DetailTrailBalance_Report 'GLSO', '0-88-1866', '01/21/2023'
EXECUTE USP_GL_XCB_DetailTrailBalance_Report 'GLSO', '0-00-2105', '01/21/2023'
*/
ALTER PROCEDURE USP_GL_XCB_DetailTrailBalance_Report
		@Company		Varchar(5),
		@GLAccount		Varchar(15),
		@GP_Period		Varchar(10)
AS
/*
========================================================================================================================
VERSION		MODIFIED	USER				MODIFICATION
========================================================================================================================
1.0			01/16/2023	Carlos A. Flores	Created for the selection of XCB transactions to generate the Trial Balance
											report.
========================================================================================================================
*/
SET NOCOUNT ON

DECLARE	@AcctIndex		Int,
		@FiscalPeriod	Char(7),
		@StartDate		Date,
		@UptoDate		Date,
		@ReportTotal	Numeric(12,2) = 0,
		@Counter		Int = 0,
		@Query			Varchar(MAX)

DECLARE @tblAccount		Table (AcctIndex Int)

SET @Query = N'SELECT ACTINDX FROM ' + @Company + '.dbo.GL00105 WHERE ACTNUMST = ''' + @GLAccount + ''''

INSERT INTO @tblAccount
EXECUTE(@Query)

SET @AcctIndex = (SELECT AcctIndex FROM @tblAccount)

IF ISDATE(@GP_Period) = 1
BEGIN
	SELECT	@StartDate	= StartDate
	FROM	DYNAMICS.dbo.View_Fiscalperiod 
	WHERE	CAST(@GP_Period AS Date) BETWEEN StartDate AND EndDate

	SET @UptoDate = CAST(@GP_Period AS Date)
END
ELSE
BEGIN
	SET @FiscalPeriod = CASE LEFT(@GP_Period, 3) -- Assemble the GP Fiscal Period
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

	-- Pulls the Fiscal Period dates
	SELECT	@StartDate	= StartDate,
			@UptoDate	= EndDate
	FROM	DYNAMICS.dbo.View_Fiscalperiod 
	WHERE	GP_Period = @FiscalPeriod
END

-- Selects all transactions for the fiscal month executed plus all previous months (unmatched and voided)
SELECT	*
INTO	#tmpReport
FROM	(
		SELECT	XCB.RecordId,
				XCB.TrxDate, -- PREVIOUS MONTHS VOIDED
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
				'*' AS Matched,
				XCB.FP_StartDate,
				CAST(XCB.MatchFrom AS Date) AS MatchFrom ,
				'PREV_MONTH_VOIDED' AS DataType,
				XCB.SWSDeliveryDate,
				MAT.MatchedOn AS MatchDate
		FROM	GP_XCB_Prepaid XCB
				LEFT JOIN GP_XCB_Prepaid_Matched MAT ON XCB.RecordId = MAT.RecordId
		WHERE	XCB.Company = @Company
				AND XCB.GLAccount = @GLAccount
				AND XCB.FP_StartDate < @StartDate
				AND XCB.Voided = 1
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
				IIF(XCB.Matched = 1, 'Y', 'N') AS Matched,
				XCB.FP_StartDate,
				XCB.MatchFrom,
				'PREV_MONTH_UNMATCHED' AS DataType,
				XCB.SWSDeliveryDate,
				MAT.MatchedOn AS MatchDate
		FROM	GP_XCB_Prepaid XCB
				LEFT JOIN GP_XCB_Prepaid_Matched MAT ON XCB.RecordId = MAT.RecordId
		WHERE	XCB.Company = @Company
				AND XCB.GLAccount = @GLAccount
				AND XCB.FP_StartDate < @StartDate
				AND (XCB.Matched = 0 OR (XCB.Matched = 1 AND XCB.MatchFrom >= @StartDate))
				AND XCB.Voided = 0
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
				IIF(XCB.Voided = 1, '*', IIF(XCB.Matched = 1, 'Y', 'N')) AS Matched,
				XCB.FP_StartDate,
				XCB.MatchFrom,
				'REPORTING_MONTH' AS DataType,
				XCB.SWSDeliveryDate,
				MAT.MatchedOn AS MatchDate
		FROM	GP_XCB_Prepaid XCB
				LEFT JOIN GP_XCB_Prepaid_Matched MAT ON XCB.RecordId = MAT.RecordId
		WHERE	XCB.Company = @Company
				AND XCB.GLAccount = @GLAccount
				AND XCB.FP_StartDate <= @UptoDate
				AND XCB.TrxDate BETWEEN @StartDate AND @UptoDate
		) DATA

-- Update the SWS data if the Manifest Date is grather than the running period date
UPDATE	#tmpReport
SET		[Manifested Y/N] = 'No'
FROM	(
		SELECT	RecordId AS RowId
		FROM	#tmpReport
		WHERE	CAST(Manifested AS Date) > @UptoDate
				AND DataType <> 'PREV_MONTH_MATCHED'
		) DATA
WHERE	RecordId = DATA.RowId

-- Update the Matched field with "N" if matched with a transaction in a grather period
UPDATE	#tmpReport
SET		Matched = 'N'
WHERE	Matched = 'Y'
		AND DataType = 'REPORTING_MONTH'
		AND MatchDate > @UptoDate

SELECT	RecordId,
		TrxDate,
		JournalNo,
		Audit_Trial,
		[Distribution Reference],
		DocumentNo,
		Vendor,
		Amount,
		ProNumber,
		REPLACE([AP Period], '-', '_') AS [AP Period],
		FP_StartDate AS PeriodStartDate,
		[Initials of SWS Validation],
		[Date Validated],
		[Payout in SWS],
		Manifested,
		[VP Cost],
		[Manifested Y/N],
		SWSStatus,
		ISNULL(CONVERT(Char(10), SWSDeliveryDate, 101), '') AS SWSDeliveryDate,
		IIF([Matched] = '*', 'V', [Matched]) AS [Matched],
		ISNULL(CONVERT(Char(10), MatchDate, 101), '') AS MatchDate
FROM	#tmpReport
ORDER BY DataType, ProNumber, ABS(Amount), FP_StartDate, Amount

SELECT	@ReportTotal = SUM(Amount),
		@Counter = COUNT(*) 
FROM	#tmpReport

PRINT '     FP Start Date: ' + CONVERT(Char(10), @StartDate, 101)
PRINT 'Total Transactions: ' + FORMAT(@Counter, 'N', 'en-us')
PRINT 'Period End Balance: ' + FORMAT(@ReportTotal, 'C', 'en-us')

DROP TABLE #tmpReport

/*
DROP TABLE tmpXCBNovember
SELECT * FROM DYNAMICS.dbo.View_Fiscalperiod FP WHERE YEAR1 = 2022 ORDER BY PERIODID

DECLARE @Counter Int = 0

WHILE @Counter <= 10
BEGIN
	EXECUTE USP_GP_XCB_PrepaidMatchingProcess 'GLSO', '0-88-1866', 1

	SET @Counter = @Counter + 1
END

SELECT	COUNT(*) AS Counter
FROM	GP_XCB_Prepaid
WHERE	SWSManifestDate IS Null

declare @query varchar(max)

SET @Query = N'SELECT DISTINCT CAST(a.div_code||''-''||a.pro AS STRING) AS pronumber, a.status, a.invdt 
	FROM	TRK.Order a
	WHERE	a.cmpy_no = 9
			AND CAST(a.div_code||''-''||a.pro AS STRING) IN (''94-119353'')'

EXECUTE USP_QuerySWS_ReportData @Query

PRINT 46952357.47 - 46950631.89
*/