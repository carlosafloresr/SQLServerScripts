/*
EXECUTE USP_AP_HistoricalTrialBalance_Report 'AIS', '10/29/2022', '426', 1, Null, 1, 1
EXECUTE USP_AP_HistoricalTrialBalance_Report 'AIS', '10/29/2022', 'ALL', 1, '', 1, 0
EXECUTE USP_AP_HistoricalTrialBalance_Report 'AIS', '10/29/2022', Null, 1, 'MSC', 1, 1
*/
ALTER PROCEDURE USP_AP_HistoricalTrialBalance_Report
	@Company			Varchar(5),
	@CutoffDate			Date,
	@VendorId			Varchar(15) = Null,
	@Summary			Bit = 0,
	@VendorClass		Varchar(200) = Null,
	@SortByName			Bit = 1,
	@ForReporting		Bit = 0
AS
SET NOCOUNT ON

DECLARE @Query			Varchar(MAX),
		@CompanyName	Varchar(100) = (SELECT CompanyName FROM GPCustom.dbo.Companies WHERE CompanyId = @Company)

IF @VendorId IN ('','ALL')
	SET @VendorId = Null

IF @VendorClass IN ('','ALL')
	SET @VendorClass = Null

DECLARE @tblTrialData	Table (
		VENDORID		Varchar(15),
		VENDNAME		Varchar(100),
		VNDCLASS		Varchar(15),
		VCHRNMBR		Varchar(20),
		DOCDATE			Date, 
		DOCTYPE			Varchar(20),
		DOCAMNT			Numeric(12,2),
		DOCNUMBR		Varchar(30),
		Applied			Numeric(12,2),
		[0_to_30_Days]	Numeric(12,2),
		[31_to_60_Days]	Numeric(12,2),
		[61_to_90_Days]	Numeric(12,2),
		[91_and_Over]	Numeric(12,2))

SET @Query = N'SELECT	VENDORID,
		VENDNAME,
		VNDCLASS,
		'''' AS VCHRNMBR,
		DOCDATE, 
		DOCTYPE,
		DOCAMNT,
		DOCNUMBR,
		0 AS Applied,
		[0_to_30_Days],
		[31_to_60_Days],
		[61_to_90_Days],
		[91_and_Over]
FROM	GPCustom.dbo.AP_HistoricalTrialData
WHERE	Company = ''' + @Company + ''' 
		AND AgingDate = ''' + CAST(@CutoffDate AS Varchar) + ''''

IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND VENDORID = ''' + @VendorId + ''' '

IF @VendorClass IS NOT Null
	SET @Query = @Query + 'AND VNDCLASS IN (''' + REPLACE(@VendorClass, ',', ''',''') + ''') '

INSERT INTO @tblTrialData
EXECUTE(@Query)

IF @Summary = 0
BEGIN
	IF @ForReporting = 0
	BEGIN
		PRINT 'Detailed and Not For Reporting'
		SELECT	@CompanyName AS CompanyName,
				VENDORID,
				RTRIM(UPPER(VENDNAME)) AS VENDNAME,
				VNDCLASS,
				VCHRNMBR,
				DOCDATE, 
				DOCTYPE,
				DOCNUMBR,
				DOCAMNT,
				Applied,
				[0_to_30_Days],
				[31_to_60_Days],
				[61_to_90_Days],
				[91_and_Over],
				[0_to_30_Days] + [31_to_60_Days] + [61_to_90_Days] + [91_and_Over] AS Balance,
				DataCounter = (SELECT COUNT(TMP.VENDORID) FROM @tblTrialData TMP WHERE TMP.VENDORID = DAT.VENDORID),
				@Summary AS Summary
		FROM	@tblTrialData DAT
		ORDER BY VENDNAME, DOCDATE, DOCNUMBR
	END
	ELSE
	BEGIN
		PRINT 'Detailed and For Reporting'
		SELECT	@CompanyName AS CompanyName,
				VENDORID,
				RTRIM(UPPER(VENDNAME)) AS VENDNAME,
				VNDCLASS,
				VCHRNMBR,
				DOCDATE, 
				DOCTYPE,
				DOCNUMBR,
				DOCAMNT,
				Applied,
				[0_to_30_Days],
				[31_to_60_Days],
				[61_to_90_Days],
				[91_and_Over],
				[0_to_30_Days] + [31_to_60_Days] + [61_to_90_Days] + [91_and_Over] AS Balance,
				DataCounter = (SELECT COUNT(TMP.VENDORID) FROM @tblTrialData TMP WHERE TMP.VENDORID = DAT.VENDORID),
				@Summary AS Summary
		FROM	@tblTrialData DAT
		UNION
		SELECT	@CompanyName AS CompanyName,
				'ZZZZZZZZ' AS VENDORID,
				'ZZZZZZZZ' AS VENDNAME,
				'ZZZZZZZZ' AS VNDCLASS,
				'' AS VCHRNMBR,
				Null AS DOCDATE, 
				'' AS DOCTYPE,
				'' AS DOCNUMBR,
				SUM(DOCAMNT) AS DOCAMNT,
				SUM(Applied) AS Applied,
				SUM([0_to_30_Days]) AS [0_to_30_Days],
				SUM([31_to_60_Days]) AS [31_to_60_Days],
				SUM([61_to_90_Days]) AS [61_to_90_Days],
				SUM([91_and_Over]) AS [91_and_Over],
				SUM([0_to_30_Days] + [31_to_60_Days] + [61_to_90_Days] + [91_and_Over]) AS Balance,
				1 AS DataCounter,
				@Summary AS Summary
		FROM	@tblTrialData
		ORDER BY VENDNAME, DOCDATE, DOCNUMBR
	END
END
ELSE
BEGIN
	IF @ForReporting = 0
		BEGIN
			PRINT 'Summary and Not For Reporting'
			SELECT	@CompanyName AS CompanyName,
					VENDORID,
					RTRIM(UPPER(VENDNAME)) AS VENDNAME,
					VNDCLASS,
					'' AS VCHRNMBR,
					MAX(DOCDATE) AS DOCDATE, 
					'' AS DOCTYPE,
					'' AS DOCNUMBR,
					SUM(DOCAMNT) AS DOCAMNT,
					SUM(Applied) AS Applied,
					SUM([0_to_30_Days]) AS [0_to_30_Days],
					SUM([31_to_60_Days]) AS [31_to_60_Days],
					SUM([61_to_90_Days]) AS [61_to_90_Days],
					SUM([91_and_Over]) AS [91_and_Over],
					SUM([0_to_30_Days] + [31_to_60_Days] + [61_to_90_Days] + [91_and_Over]) AS Balance,
					DataCounter = (SELECT COUNT(TMP.VENDORID) FROM @tblTrialData TMP WHERE TMP.VENDORID = DAT.VENDORID),
					@Summary AS Summary
			FROM	@tblTrialData DAT
			GROUP BY VENDORID, VENDNAME, VNDCLASS
			ORDER BY VENDNAME, DOCDATE, DOCNUMBR
		END
		ELSE
		BEGIN
			PRINT 'Summary and For Reporting'
			SELECT	@CompanyName AS CompanyName,
					VENDORID,
					RTRIM(UPPER(VENDNAME)) AS VENDNAME,
					VNDCLASS,
					'' AS VCHRNMBR,
					MAX(DOCDATE) AS DOCDATE, 
					'' AS DOCTYPE,
					'' AS DOCNUMBR,
					SUM(DOCAMNT) AS DOCAMNT,
					SUM(Applied) AS Applied,
					SUM([0_to_30_Days]) AS [0_to_30_Days],
					SUM([31_to_60_Days]) AS [31_to_60_Days],
					SUM([61_to_90_Days]) AS [61_to_90_Days],
					SUM([91_and_Over]) AS [91_and_Over],
					SUM([0_to_30_Days] + [31_to_60_Days] + [61_to_90_Days] + [91_and_Over]) AS Balance,
					DataCounter = (SELECT COUNT(TMP.VENDORID) FROM @tblTrialData TMP WHERE TMP.VENDORID = DAT.VENDORID),
					@Summary AS Summary
			FROM	@tblTrialData DAT
			GROUP BY VENDORID, VENDNAME, VNDCLASS
			HAVING	SUM([0_to_30_Days] + [31_to_60_Days] + [61_to_90_Days] + [91_and_Over]) <> 0
			UNION
			SELECT	@CompanyName AS CompanyName,
					'ZZZZZZZZ' AS VENDORID,
					'ZZZZZZZZ' AS VENDNAME,
					'ZZZZZZZZ' AS VNDCLASS,
					'' AS VCHRNMBR,
					Null AS DOCDATE, 
					'' AS DOCTYPE,
					'' AS DOCNUMBR,
					SUM(DOCAMNT) AS DOCAMNT,
					SUM(Applied) AS Applied,
					SUM([0_to_30_Days]) AS [0_to_30_Days],
					SUM([31_to_60_Days]) AS [31_to_60_Days],
					SUM([61_to_90_Days]) AS [61_to_90_Days],
					SUM([91_and_Over]) AS [91_and_Over],
					SUM([0_to_30_Days] + [31_to_60_Days] + [61_to_90_Days] + [91_and_Over]) AS Balance,
					1 AS DataCounter,
					@Summary AS Summary
			FROM	@tblTrialData
			ORDER BY VENDNAME, DOCDATE, DOCNUMBR
		END
END