USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AP_TrialBalance]    Script Date: 10/23/2020 10:24:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- FIXED BY FUNCTION
10153,101,10115
EXECUTE USP_AP_TrialBalance 'AIS', '10153', 1, '10/27/2020'
EXECUTE USP_AP_TrialBalance 'AIS', Null, 1, '10/27/2020'
EXECUTE USP_AP_TrialBalance 'DNJ', '95000', 1
EXECUTE USP_AP_TrialBalance 'GIS', '552H', 0, '02/01/2020'
EXECUTE USP_AP_TrialBalance 'DNJ', '91000', 0, '02/01/2020', 'P', 1
*/
ALTER PROCEDURE [dbo].[USP_AP_TrialBalance]
		@Company	Varchar(5),
		@VendorId	Varchar(15) = Null,
		@Summary	Bit = 0,
		@CutoffDate	Date = Null,
		@DateType	Char(1) = 'P',
		@ForExport	Bit = 0
AS
SET NOCOUNT ON

DECLARE	@RunDate	Date,
		@TxtDate	Char(10)

IF @DateType IS Null
	SET @DateType = 'P'

IF @VendorId = ''
	SET @VendorId = Null

IF @CutoffDate < '01/01/2000'
BEGIN
	SET @CutoffDate = Null
	SET @RunDate = GETDATE()
END
ELSE
	SET @RunDate = @CutoffDate

--PRINT 'Cutoff Date: ' + CONVERT(Char(10), @RunDate, 101)

DECLARE	@Query		Varchar(MAX) = '',
		@DateField	Varchar(10) = IIF(@DateType = 'P', 'PSTGDATE', 'DOCDATE'),
		@AppEndDate	Date = ISNULL(@CutoffDate, GETDATE())

SET @TxtDate = CAST(@RunDate AS Char(10))

DECLARE	@tblResult	Table (
		Vendor_ID			Varchar(15) Null,
		Vendor_Name			Varchar(100) Null,
		Vendor				Varchar(150) Null,
		Vendor_Terms		varchar(30) Null,
		Vendor_Class		Varchar(10) Null,
		Document_Type		Varchar(15) Null,
		Document_Number		Varchar(30) Null,
		Document_Date		Date Null,
		Due_Date			Date Null,
		Document_Amount		Numeric(12,2),
		Unapplied_Amount	Numeric(12,2),
		[Current]			Numeric(12,2),
		[0_to_30_Days]		Numeric(12,2),
		[31_to_60_Days]		Numeric(12,2),
		[61_to_90_Days]		Numeric(12,2),
		[91_to_180_Days]	Numeric(12,2),
		[180_and_Over]		Numeric(12,2),
		Balance				Numeric(12,2),
		SummaryRow			Smallint)

IF @Summary = 1
	SET @Query = @Query + N'SELECT Vendor_ID,
		Vendor_Name,
		Vendor,
		Vendor_Terms,
		Vendor_Class,
		''SUM'' AS Document_Type,
		''SUMMARY'' AS Document_Number,
		MAX(Document_Date) AS Document_Date,
		MAX(Due_Date) AS Due_Date,
		SUM(Document_Amount) AS Document_Amount,
		SUM(Unapplied_Amount) AS Unapplied_Amount,
		SUM([Current]) AS [Current],
		SUM([0_to_30_Days]) AS [0_to_30_Days],
		SUM([31_to_60_Days]) AS [31_to_60_Days],
		SUM([61_to_90_Days]) AS [61_to_90_Days],
		SUM([91_to_180_Days]) AS [91_to_180_Days],
		SUM([180_and_Over]) AS [180_and_Over],
		SUM(Balance) AS Balance,
		0 AS SummaryRow
	FROM ('

SET @Query = @Query + N'SELECT RTRIM(CM.VENDORID) Vendor_ID,
		RTRIM(CM.VENDNAME) Vendor_Name,
		RTRIM(CM.VENDORID) + '' - '' + RTRIM(CM.VENDORID) AS Vendor,
		RTRIM(CM.PYMTRMID) Vendor_Terms,
		RTRIM(CM.VNDCLSID) Vendor_Class,
		CASE RM.DOCTYPE
		  WHEN 1 THEN ''Invoice''
		  WHEN 4 THEN ''Debit Memo''
		  WHEN 5 THEN ''Credit Memo''
		  WHEN 6 THEN ''Payment''
		  ELSE ''Other''
		  END Document_Type,
		RTRIM(RM.DOCNUMBR) Document_Number,
		CAST(RM.DOCDATE AS Date) Document_Date,
		CAST(RM.DUEDATE AS Date) Due_Date,
		RM.DOCAMNT * IIF(RM.DOCTYPE > 4, -1, 1) AS Document_Amount,
		RM.CURTRXAM * IIF(RM.DOCTYPE > 4, -1, 1) AS Unapplied_Amount,
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + @TxtDate + ''') <= 30 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 4, -1, 1)
			ELSE 0 END [Current],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + @TxtDate + ''') <= 30 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 4, -1, 1)
			ELSE 0 END [0_to_30_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + @TxtDate + ''') BETWEEN 31 AND 60 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 4, -1, 1)
			ELSE 0 END [31_to_60_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + @TxtDate + ''') BETWEEN 61 AND 90 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 4, -1, 1)
			ELSE 0 END [61_to_90_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + @TxtDate + ''') BETWEEN 91 AND 180 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 4, -1, 1)
			ELSE 0 END [91_to_180_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + @TxtDate + ''') > 180 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 4, -1, 1)
			ELSE 0 END [180_and_Over],
		RM.CURTRXAM * IIF(RM.DOCTYPE > 4, -1, 1) AS Balance,
		0 AS SummaryRow
FROM	(SELECT VENDORID,
		DOCTYPE,
		DOCNUMBR,
		DOCDATE,
		DUEDATE,
		DOCAMNT,
		CURTRXAM = ((DOCAMNT + IIF(DOCTYPE > 4, WROFAMNT, 0)) - ISNULL((SELECT SUM(RMA.APPLDAMT + RMA.WROFAMNT) FROM ' + @Company + '.dbo.PM10200 RMA WHERE RMA.VENDORID = PM20000.VENDORID AND IIF(PM20000.DOCTYPE < 5, RMA.APTODCNM, RMA.VCHRNMBR) = IIF(PM20000.DOCTYPE < 5, PM20000.DOCNUMBR, PM20000.VCHRNMBR) AND RMA.Date1 <= ''' + CAST(@AppEndDate AS Char(10)) + '''),0))
FROM	' + @Company + '.dbo.PM20000
WHERE	VOIDED = 0 '

-- CURTRXAM = IIF(DOCAMNT = CURTRXAM, DOCAMNT, ((DOCAMNT + IIF(DOCTYPE > 4, WROFAMNT, 0)) - GPCustom.dbo.FindApplyAmount(''' + @Company + ''',VENDORID,DOCNUMBR,DOCTYPE,''' + CAST(@AppEndDate AS Char(10)) + ''')))

IF @VendorId IS NOT Null
		SET @Query =  @Query + 'AND VENDORID = ''' + RTRIM(@VendorId) + ''' '

IF @CutoffDate IS NOT Null
BEGIN
	SET @Query =  @Query + 'AND ' + @DateField + ' <= ''' + CAST(@CutoffDate AS Char(10)) + '''
	UNION
	SELECT	VENDORID,
			DOCTYPE,
			DOCNUMBR,
			DOCDATE,
			DUEDATE,
			DOCAMNT,
			CURTRXAM = ((DOCAMNT + IIF(DOCTYPE > 4, WROFAMNT, 0)) - ISNULL((SELECT SUM(RMA.APPLDAMT + RMA.WROFAMNT) FROM ' + @Company + '.dbo.PM30300 RMA WHERE RMA.VENDORID = PM30200.VENDORID AND IIF(PM30200.DOCTYPE < 5, RMA.APTODCNM, RMA.VCHRNMBR) = IIF(PM30200.DOCTYPE < 5, PM30200.DOCNUMBR, PM30200.VCHRNMBR) AND RMA.Date1 <= ''' + CAST(@AppEndDate AS Char(10)) + '''), 0))
	FROM	' + @Company + '.dbo.PM30200
	WHERE	VOIDED = 0 
			AND ' + @DateField + ' <= ''' + CAST(@CutoffDate AS Char(10)) + ''''

-- CURTRXAM = IIF(DOCAMNT = CURTRXAM, DOCAMNT, ((DOCAMNT + IIF(DOCTYPE > 4, WROFAMNT, 0)) - GPCustom.dbo.FindApplyAmount(''' + @Company + ''',VENDORID,DOCNUMBR,DOCTYPE,''' + CAST(@AppEndDate AS Char(10)) + ''')))

	IF @VendorId IS NOT Null
		SET @Query =  @Query + 'AND VENDORID = ''' + RTRIM(@VendorId) + ''' '
END

SET @Query =  @Query + ') RM
		INNER JOIN ' + @Company + '.dbo.PM00200 CM ON RM.VENDORID = CM.VENDORID 
WHERE	RM.CURTRXAM <> 0 '

IF @Summary = 1
	SET @Query = @Query + ') DATA 
	GROUP BY Vendor_ID,
		Vendor_Name,
		Vendor,
		Vendor_Terms,
		Vendor_Class 
	'

SET @Query = @Query + 'ORDER BY Vendor, Document_Date DESC'
PRINT @Query
INSERT INTO @tblResult
EXECUTE(@Query)

IF @Summary = 0
BEGIN
	INSERT INTO @tblResult
	SELECT	Vendor_ID,
			Vendor_Name,
			Vendor,
			Vendor_Terms,
			Null AS Vendor_Class,
			Null AS Document_Type,
			Null AS Document_Number,
			Null AS Document_Date,
			Null AS Due_Date,
			SUM(Document_Amount) AS Document_Amount,
			SUM(Unapplied_Amount) AS Unapplied_Amount,
			SUM([Current]) AS [Current],
			SUM([0_to_30_Days]) AS [0_to_30_Days],
			SUM([31_to_60_Days]) AS [31_to_60_Days],
			SUM([61_to_90_Days]) AS [61_to_90_Days],
			SUM([91_to_180_Days]) AS [91_to_180_Days],
			SUM([180_and_Over]) AS [180_and_Over],
			SUM(Balance) AS Balance,
			1 AS SummaryRow
	FROM	@tblResult
	GROUP BY Vendor_ID,
			Vendor_Name,
			Vendor,
			Vendor_Terms,
			Vendor_Class
END

IF (SELECT COUNT(*) FROM (SELECT DISTINCT Vendor_ID FROM @tblResult) DATA) > 1
BEGIN
	INSERT INTO @tblResult
	SELECT	'ZZZZZZZZZZZZZZZ' AS Vendor_ID,
			Null AS Vendor_Name,
			'z) S U M M A R Y' AS Customer,
			Null AS Vendor_Terms,
			Null AS Vendor_Class,
			Null AS Document_Type,
			Null AS Document_Number,
			Null AS Document_Date,
			Null AS Due_Date,
			SUM(Document_Amount) AS Document_Amount,
			SUM(Unapplied_Amount) AS Unapplied_Amount,
			SUM([Current]) AS [Current],
			SUM([0_to_30_Days]) AS [0_to_30_Days],
			SUM([31_to_60_Days]) AS [31_to_60_Days],
			SUM([61_to_90_Days]) AS [61_to_90_Days],
			SUM([91_to_180_Days]) AS [91_to_180_Days],
			SUM([180_and_Over]) AS [180_and_Over],
			SUM(Balance) AS Balance,
			2 AS SummaryRow
	FROM	@tblResult
	WHERE	SummaryRow = IIF(@Summary = 1, 0, 1)
END

IF @ForExport = 0
	SELECT	*
	FROM	@tblResult
	WHERE	Balance >= 0
	ORDER BY Vendor_ID, SummaryRow, Document_Number DESC
ELSE
	SELECT	Vendor_ID,
			Vendor_Name,
			Vendor_Terms,
			Vendor_Class,
			Document_Type,
			Document_Number,
			Document_Date,
			Due_Date,
			Document_Amount,
			Unapplied_Amount,
			[Current],
			[0_to_30_Days],
			[31_to_60_Days],
			[61_to_90_Days],
			[91_to_180_Days],
			[180_and_Over],
			Balance
	FROM	@tblResult
	WHERE	Balance >= 0
	ORDER BY Vendor_ID, SummaryRow, Document_Number DESC

	-- CAST((SELECT MAX(S.LASTPYDT) FROM ' + @Company + '.dbo.RM00103 S WHERE S.VENDORID = RM.VENDORID) AS Date) AS Last_Payment_Date,