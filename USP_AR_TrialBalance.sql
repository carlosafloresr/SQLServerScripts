/*
EXECUTE USP_AR_TrialBalance 'GIS', Null, 1
EXECUTE USP_AR_TrialBalance 'GIS', Null, 0
EXECUTE USP_AR_TrialBalance 'DNJ', '95000', 1
EXECUTE USP_AR_TrialBalance 'GIS', '552H', 0, '02/01/2020'
EXECUTE USP_AR_TrialBalance 'DNJ', '91000', 0, '02/01/2020', 'P', 1
*/
ALTER PROCEDURE USP_AR_TrialBalance
		@Company	Varchar(5),
		@CustomerId	Varchar(15) = Null,
		@Summary	Bit = 0,
		@CutoffDate	Date = Null,
		@DateType	Char(1) = 'P',
		@ForExport	Bit = 0
AS
SET NOCOUNT ON

DECLARE	@RunDate	Date

IF @DateType IS Null
	SET @DateType = 'P'

IF @CustomerId = ''
	SET @CustomerId = Null

IF @CutoffDate < '01/01/2000'
BEGIN
	SET @CutoffDate = Null
	SET @RunDate = GETDATE()
END
ELSE
	SET @RunDate = @CutoffDate

DECLARE	@Query		Varchar(MAX) = '',
		@DateField	Varchar(10) = IIF(@DateType = 'P', 'GLPOSTDT', 'DOCDATE'),
		@AppEndDate	Date = ISNULL(@CutoffDate, GETDATE())

DECLARE	@tblResult	Table (
		Customer_ID			Varchar(15) Null,
		Customer_Name		Varchar(100) Null,
		Customer			Varchar(150) Null,
		NationalId			Varchar(15),
		NationalAccount		Varchar(150),
		Customer_Terms		varchar(30) Null,
		Customer_Class		Varchar(10) Null,
		Price_Level			Varchar(20) Null,
		Document_Type		Varchar(15) Null,
		Document_Number		Varchar(30) Null,
		Document_Date		Date Null,
		Due_Date			Date Null,
		Last_Payment_Date	Date Null,
		Document_Amount		Numeric(10,2),
		Unapplied_Amount	Numeric(10,2),
		[Current]			Numeric(10,2),
		[0_to_30_Days]		Numeric(10,2),
		[31_to_60_Days]		Numeric(10,2),
		[61_to_90_Days]		Numeric(10,2),
		[91_to_180_Days]	Numeric(10,2),
		[180_and_Over]		Numeric(10,2),
		Balance				Numeric(10,2),
		SummaryRow			Smallint)

IF @Summary = 1
	SET @Query = @Query + N'SELECT Customer_ID,
		Customer_Name,
		Customer,
		NationalId,
		NationalAccount,
		Customer_Terms,
		Customer_Class,
		Price_Level,
		''SUM'' AS Document_Type,
		''SUMMARY'' AS Document_Number,
		MAX(Document_Date) AS Document_Date,
		MAX(Due_Date) AS Due_Date,
		Null AS Last_Payment_Date,
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

SET @Query = @Query + N'SELECT RTRIM(CM.CUSTNMBR) Customer_ID,
		RTRIM(CM.CUSTNAME) Customer_Name,
		RTRIM(CM.CUSTNMBR) + '' - '' + RTRIM(CM.CUSTNAME) AS Customer,
		RTRIM(RM.CPRCSTNM) AS NationalId,
		ISNULL(RTRIM(CN.CUSTNMBR) + '' - '' + RTRIM(CN.CUSTNAME), '''') AS NationalAccount,
		RTRIM(CM.PYMTRMID) Customer_Terms,
		RTRIM(CM.CUSTCLAS) Customer_Class,
		CM.PRCLEVEL Price_Level,
		CASE RM.RMDTYPAL
		  WHEN 1 THEN ''Invoice''
		  WHEN 3 THEN ''Debit Memo''
		  WHEN 4 THEN ''Finance Charge''
		  WHEN 5 THEN ''Service Repair''
		  WHEN 6 THEN ''Warranty''
		  WHEN 7 THEN ''Credit Memo''
		  WHEN 8 THEN ''Return''
		  WHEN 9 THEN ''Payment''
		  ELSE ''Other''
		  END Document_Type,
		RTRIM(RM.DOCNUMBR) Document_Number,
		CAST(RM.DOCDATE AS Date) Document_Date,
		CAST(RM.DUEDATE AS Date) Due_Date,
		Null AS Last_Payment_Date,
		RM.ORTRXAMT * IIF(RM.RMDTYPAL > 6, -1, 1) AS Document_Amount,
		RM.CURTRXAM * IIF(RM.RMDTYPAL > 6, -1, 1) AS Unapplied_Amount,
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') <= 30 THEN RM.CURTRXAM * IIF(RM.RMDTYPAL > 6, -1, 1)
			ELSE 0 END [Current],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') <= 30 THEN RM.CURTRXAM * IIF(RM.RMDTYPAL > 6, -1, 1)
			ELSE 0 END [0_to_30_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') BETWEEN 31 AND 60 THEN RM.CURTRXAM * IIF(RM.RMDTYPAL > 6, -1, 1)
			ELSE 0 END [31_to_60_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') BETWEEN 61 AND 90 THEN RM.CURTRXAM * IIF(RM.RMDTYPAL > 6, -1, 1)
			ELSE 0 END [61_to_90_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') BETWEEN 91 AND 180 THEN RM.CURTRXAM * IIF(RM.RMDTYPAL > 6, -1, 1)
			ELSE 0 END [91_to_180_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') > 180 THEN RM.CURTRXAM * IIF(RM.RMDTYPAL > 6, -1, 1)
			ELSE 0 END [180_and_Over],
		RM.CURTRXAM * IIF(RM.RMDTYPAL > 6, -1, 1) AS Balance,
		0 AS SummaryRow
FROM	(SELECT CUSTNMBR,
		CPRCSTNM,
		RMDTYPAL,
		DOCNUMBR,
		DOCDATE,
		DUEDATE,
		ORTRXAMT,
		CURTRXAM = ((ORTRXAMT + IIF(RMDTYPAL > 6, WROFAMNT, 0)) - ISNULL((SELECT SUM(RMA.APPTOAMT + RMA.WROFAMNT) AS SUMMARY FROM ' + @Company + '.dbo.RM20201 RMA WHERE RMA.CUSTNMBR = RM20101.CUSTNMBR AND IIF(RM20101.RMDTYPAL < 7, RMA.APTODCNM, RMA.APFRDCNM) = RM20101.DOCNUMBR AND RMA.Date1 <= ''' + CAST(@AppEndDate AS Char(10)) + '''),0))
FROM	' + @Company + '.dbo.RM20101
WHERE	(CUSTNMBR = ''' + RTRIM(@CustomerId) + ''' OR CPRCSTNM = ''' + RTRIM(@CustomerId) + ''')
		AND VOIDSTTS = 0 '

IF @CutoffDate IS NOT Null
BEGIN
	SET @Query =  @Query + 'AND ' + @DateField + ' <= ''' + CAST(@CutoffDate AS Char(10)) + '''
	UNION
	SELECT	CUSTNMBR,
			CPRCSTNM,
			RMDTYPAL,
			DOCNUMBR,
			DOCDATE,
			DUEDATE,
			ORTRXAMT,
			CURTRXAM = ((ORTRXAMT + IIF(RMDTYPAL > 6, WROFAMNT, 0)) - ISNULL((SELECT SUM(RMA.APPTOAMT + RMA.WROFAMNT) AS SUMMARY FROM ' + @Company + '.dbo.RM30201 RMA WHERE RMA.CUSTNMBR = RM30101.CUSTNMBR AND IIF(RM30101.RMDTYPAL < 7, RMA.APTODCNM, RMA.APFRDCNM) = RM30101.DOCNUMBR AND RMA.Date1 <= ''' + CAST(@AppEndDate AS Char(10)) + '''), 0))
	FROM	' + @Company + '.dbo.RM30101
	WHERE	(CUSTNMBR = ''' + RTRIM(@CustomerId) + ''' OR CPRCSTNM = ''' + RTRIM(@CustomerId) + ''')
			AND VOIDSTTS = 0 
			AND ' + @DateField + ' <= ''' + CAST(@CutoffDate AS Char(10)) + ''''
END

SET @Query =  @Query + ') RM
		INNER JOIN ' + @Company + '.dbo.RM00101 CM ON RM.CUSTNMBR = CM.CUSTNMBR 
		LEFT JOIN ' + @Company + '.dbo.RM00101 CN ON RM.CPRCSTNM = CN.CUSTNMBR 
WHERE	RM.CURTRXAM <> 0 '

IF @Summary = 1
	SET @Query = @Query + ') DATA 
	GROUP BY Customer_ID,
		Customer_Name,
		Customer,
		NationalId,
		NationalAccount,
		Customer_Terms,
		Customer_Class,
		Price_Level '

SET @Query = @Query + 'ORDER BY Customer, Document_Date DESC'
PRINT @Query
INSERT INTO @tblResult
EXECUTE(@Query)

IF @Summary = 0
BEGIN
	INSERT INTO @tblResult
	SELECT	Customer_ID,
			Customer_Name,
			Customer,
			NationalId,
			NationalAccount,
			Customer_Terms,
			Null AS Customer_Class,
			Null AS Price_Level,
			Null AS Document_Type,
			Null AS Document_Number,
			Null AS Document_Date,
			Null AS Due_Date,
			Null AS Last_Payment_Date,
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
	GROUP BY Customer_ID,
			Customer_Name,
			Customer,
			NationalId,
			NationalAccount,
			Customer_Terms,
			Customer_Class,
			Price_Level
END

IF (SELECT COUNT(*) FROM (SELECT DISTINCT Customer_ID FROM @tblResult) DATA) > 1
BEGIN
	INSERT INTO @tblResult
	SELECT	'ZZZZZZZZZZZZZZZ' AS Customer_ID,
			Null AS Customer_Name,
			'z) S U M M A R Y' AS Customer,
			NationalId,
			NationalAccount,
			Null AS Customer_Terms,
			Null AS Customer_Class,
			Null AS Price_Level,
			Null AS Document_Type,
			Null AS Document_Number,
			Null AS Document_Date,
			Null AS Due_Date,
			Null AS Last_Payment_Date,
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
	GROUP BY NationalId,
			NationalAccount
END

IF @ForExport = 0
	SELECT	*
	FROM	@tblResult
	ORDER BY Customer_ID, SummaryRow, Document_Number DESC
ELSE
	SELECT	Customer_ID,
			Customer_Name,
			NationalId,
			Customer_Terms,
			Customer_Class,
			Document_Type,
			Document_Number,
			Document_Date,
			Due_Date,
			Last_Payment_Date,
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
	ORDER BY Customer_ID, SummaryRow, Document_Number DESC

	-- CAST((SELECT MAX(S.LASTPYDT) FROM ' + @Company + '.dbo.RM00103 S WHERE S.CUSTNMBR = RM.CUSTNMBR) AS Date) AS Last_Payment_Date,