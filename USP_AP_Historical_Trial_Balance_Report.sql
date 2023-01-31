/*
EXECUTE USP_AP_Historical_Trial_Balance_Report 'AIS', '10/29/2022', '426', 1, Null, 1, 0
EXECUTE USP_AP_Historical_Trial_Balance_Report 'AIS', '11/22/2022', 'ALL', 1, '', 1, 0
EXECUTE USP_AP_Historical_Trial_Balance_Report 'AIS', '10/29/2022', Null, 1, 'MSC', 1, 1
*/
ALTER PROCEDURE USP_AP_Historical_Trial_Balance_Report
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

SET @Query = N'SELECT	pmTrans.vendorid, 
        vendMaster.vendname, 
		RTRIM(VNDCLSID) AS VNDCLSID,
        pmTrans.vchrnmbr, 
        CAST(pmTrans.docdate AS Date) AS docdate, 
        CASE pmTrans.doctype 
			WHEN 1 THEN ''Invoice'' 
			WHEN 2 THEN ''Finance Charge'' 
			WHEN 3 THEN ''Misc Charge'' 
			END AS docType, 
        pmTrans.docamnt AS docamnt, 
        pmTrans.docnumbr, 
        ISNULL(apply.appldamt, 0) AS appldamt, 
        CASE WHEN DATEDIFF(dd, DOCDATE, ''' + CONVERT(Char(10), @CutoffDate, 101) + ''') BETWEEN 0 AND 30 THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [0_to_30_Days], 
        CASE WHEN DATEDIFF(dd, DOCDATE, ''' + CONVERT(Char(10), @CutoffDate, 101) + ''') BETWEEN 31 AND 60 THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [31_to_60_Days], 
        CASE WHEN DATEDIFF(dd, DOCDATE, ''' + CONVERT(Char(10), @CutoffDate, 101) + ''') BETWEEN 61 AND 90 THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [61_to_90_Days], 
        CASE WHEN DATEDIFF(dd, DOCDATE, ''' + CONVERT(Char(10), @CutoffDate, 101) + ''') > 90 THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [91_and_Over]
FROM	' + @Company + '.dbo.PM20000 pmTrans 
        LEFT JOIN ' + @Company + '.dbo.PM00200 vendMaster ON vendMaster.vendorid = pmTrans.vendorid 
        LEFT JOIN (SELECT	VENDORID AS VENDOR, APTODCNM, SUM(appldamt) AS appldamt 
					FROM	' + @Company + '.dbo.PM20100 
					WHERE  docdate <= ''' + CAST(@CutoffDate AS Varchar) + ''' 
					GROUP BY VENDORID, APTODCNM
					UNION
					SELECT	VENDORID AS VENDOR, APTODCNM, SUM(appldamt) AS appldamt 
					FROM	' + @Company + '.dbo.PM30300 
					WHERE  docdate <= ''' + CAST(@CutoffDate AS Varchar) + ''' 
					GROUP BY VENDORID, APTODCNM
				   ) apply ON pmTrans.VendorId = apply.Vendor AND pmTrans.docnumbr = apply.APTODCNM
WHERE	pstgdate <= ''' + CAST(@CutoffDate AS Varchar) + ''' 
		AND pmTrans.docamnt - ISNULL(apply.appldamt, 0) - DISTKNAM <> 0 
		AND pmTrans.doctype <= 3 
		AND voided = 0  '

IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND pmTrans.VENDORID = ''' + @VendorId + ''' '

IF @VendorClass IS NOT Null
	SET @Query = @Query + 'AND vendMaster.VNDCLSID IN (''' + REPLACE(@VendorClass, ',', ''',''') + ''') '

SET @Query = @Query + N'UNION 
SELECT	pmTrans.vendorid, 
        vendMaster.vendname, 
		RTRIM(VNDCLSID) AS VNDCLSID,
        pmTrans.vchrnmbr, 
        CAST(pmTrans.docdate AS Date) AS docdate, 
        CASE pmTrans.doctype 
			WHEN 4 THEN ''Return'' 
			WHEN 5 THEN ''Credit'' 
			WHEN 6 THEN ''Payment'' 
			ELSE CONVERT(VARCHAR(2), pmTrans.doctype) 
			END AS docType, 
        -pmTrans.docamnt AS docamnt, 
        pmTrans.docnumbr, 
        ISNULL(apply.appldamt, 0) AS appldamt, 
        -pmTrans.docamnt + ISNULL(apply.appldamt, 0) AS [0_to_30_Days], 
        0 AS [31_to_60_Days], 
        0 AS [61_to_90_Days], 
        0 AS [91_and_Over] 
FROM	' + @Company + '.dbo.PM20000 pmTrans 
        LEFT JOIN ' + @Company + '.dbo.PM00200 vendMaster ON vendMaster.vendorid = pmTrans.vendorid 
        LEFT JOIN (SELECT vchrnmbr, doctype, SUM(appldamt) AS appldamt 
					FROM   ' + @Company + '.dbo.PM20100 
					WHERE  docdate <= ''' + CAST(@CutoffDate AS Varchar) + ''' 
					GROUP BY vchrnmbr, doctype
					) apply ON pmTrans.vchrnmbr = apply.vchrnmbr AND pmTrans.doctype = apply.doctype 
WHERE  pstgdate <= ''' + CAST(@CutoffDate AS Varchar) + ''' 
        AND pmTrans.docamnt - ISNULL(apply.appldamt, 0) - DISTKNAM <> 0 
        AND pmTrans.doctype >= 4 
        AND voided = 0 '

IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND pmTrans.VENDORID = ''' + @VendorId + ''' '

IF @VendorClass IS NOT Null
	SET @Query = @Query + 'AND vendMaster.VNDCLSID IN (''' + REPLACE(@VendorClass, ',', ''',''') + ''') '

SET @Query = @Query + N'UNION 
SELECT	pmTrans.vendorid, 
        vendMaster.vendname, 
		RTRIM(VNDCLSID) AS VNDCLSID,
        pmTrans.vchrnmbr, 
        CAST(pmTrans.docdate AS Date) AS docdate, 
        CASE pmTrans.doctype 
			WHEN 1 THEN ''Invoice'' 
			WHEN 2 THEN ''Finance Charge'' 
			WHEN 3 THEN ''Misc Charge'' 
			END AS docType, 
        pmTrans.docamnt AS docamnt, 
        pmTrans.docnumbr, 
        ISNULL(apply.appldamt, 0) AS appldamt, 
        CASE WHEN DATEDIFF(dd, DOCDATE, ''' + CONVERT(Char(10), @CutoffDate, 101) + ''') BETWEEN 0 AND 30 THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [0_to_30_Days], 
        CASE WHEN DATEDIFF(dd, DOCDATE, ''' + CONVERT(Char(10), @CutoffDate, 101) + ''') BETWEEN 31 AND 60 THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [31_to_60_Days], 
        CASE WHEN DATEDIFF(dd, DOCDATE, ''' + CONVERT(Char(10), @CutoffDate, 101) + ''') BETWEEN 61 AND 90 THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [61_to_90_Days], 
        CASE WHEN DATEDIFF(dd, DOCDATE, ''' + CONVERT(Char(10), @CutoffDate, 101) + ''') > 90 THEN pmTrans.docamnt - ISNULL(apply.appldamt, 0) ELSE 0 END AS [91_and_Over]
FROM	' + @Company + '.dbo.PM30200 pmTrans 
        LEFT JOIN ' + @Company + '.dbo.PM00200 vendMaster ON vendMaster.vendorid = pmTrans.vendorid 
        LEFT JOIN (SELECT aptvchnm, aptodcty, SUM(appldamt) AS appldamt 
					FROM   ' + @Company + '.dbo.PM30300 
					WHERE  glpostdt <= ''' + CAST(@CutoffDate AS Varchar) + ''' 
					GROUP BY aptvchnm, aptodcty
					) apply ON apply.aptvchnm = pmTrans.vchrnmbr AND pmTrans.doctype = apply.aptodcty 
WHERE	pstgdate <= ''' + CAST(@CutoffDate AS Varchar) + ''' 
        AND pmTrans.docamnt - ISNULL(apply.appldamt, 0) - DISTKNAM <> 0 
        AND pmTrans.doctype <= 3 
        AND (voided = 0 OR (voided = 1 AND voidpdate > ''' + CAST(@CutoffDate AS Varchar) + ''')) '

IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND pmTrans.VENDORID = ''' + @VendorId + ''' '

IF @VendorClass IS NOT Null
	SET @Query = @Query + 'AND vendMaster.VNDCLSID IN (''' + REPLACE(@VendorClass, ',', ''',''') + ''') '

SET @Query = @Query + N'UNION 
SELECT	pmTrans.vendorid, 
        vendMaster.vendname, 
		RTRIM(VNDCLSID) AS VNDCLSID,
        pmTrans.vchrnmbr, 
        CAST(pmTrans.docdate AS Date) AS docdate, 
        CASE pmTrans.doctype 
			WHEN 4 THEN ''Return'' 
			WHEN 5 THEN ''Credit'' 
			WHEN 6 THEN ''Payment'' 
			ELSE CONVERT(VARCHAR(2), pmTrans.doctype) 
			END AS docType, 
        -pmTrans.docamnt AS docamnt, 
        pmTrans.docnumbr, 
        ISNULL(apply.appldamt, 0) AS appldamt, 
        -pmTrans.docamnt + ISNULL(apply.appldamt, 0) AS [0_to_30_Days], 
        0 AS [31_to_60_Days], 
        0 AS [61_to_90_Days], 
        0 AS [91_and_Over]  
FROM   ' + @Company + '.dbo.PM30200 pmTrans 
        LEFT JOIN ' + @Company + '.dbo.PM00200 vendMaster ON vendMaster.vendorid = pmTrans.vendorid 
        LEFT JOIN (SELECT vchrnmbr, doctype, SUM(appldamt) AS appldamt 
					FROM   ' + @Company + '.dbo.PM30300 
					WHERE  glpostdt <= ''' + CAST(@CutoffDate AS Varchar) + ''' 
					GROUP BY vchrnmbr, doctype
					) apply ON pmTrans.vchrnmbr = apply.vchrnmbr AND pmTrans.doctype = apply.doctype 
WHERE  pstgdate <= ''' + CAST(@CutoffDate AS Varchar) + ''' 
        AND pmTrans.docamnt - ISNULL(apply.appldamt, 0) - DISTKNAM <> 0 
        AND pmTrans.doctype >= 4 
        AND (voided = 0 OR (voided = 1 AND voidpdate > ''' + CAST(@CutoffDate AS Varchar) + ''')) '

IF @VendorId IS NOT Null
	SET @Query = @Query + 'AND pmTrans.VENDORID = ''' + @VendorId + ''' '

IF @VendorClass IS NOT Null
	SET @Query = @Query + 'AND vendMaster.VNDCLSID IN (''' + REPLACE(@VendorClass, ',', ''',''') + ''')'
print @Query
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
				SUM([91_and_Over]) AS [181_and_Over],
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
					SUM([91_and_Over]) AS [181_and_Over],
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
					SUM([91_and_Over]) AS [91_to_180_Days],
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
					SUM([91_and_Over]) AS [181_and_Over],
					SUM([0_to_30_Days] + [31_to_60_Days] + [61_to_90_Days] + [91_and_Over]) AS Balance,
					1 AS DataCounter,
					@Summary AS Summary
			FROM	@tblTrialData
			ORDER BY VENDNAME, DOCDATE, DOCNUMBR
		END
END