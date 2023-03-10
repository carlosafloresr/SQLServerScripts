USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AgingReport]    Script Date: 3/3/2020 11:32:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_AgingReport @Company = 'AIS', @Customer = '24445', @RunDate = '01/01/2020'
EXECUTE USP_AgingReport @Company = 'GSA', @RunDate = '05/01/2018', @Summary = 0, @Customer = '19979', @SortBy = 'N'
EXECUTE USP_AgingReport @Company = 'IMC', @RunDate = '02/29/2020', @Summary = 0 --, @Customer = '24024'
*/
ALTER PROCEDURE [dbo].[USP_AgingReport]
	@Company	Varchar(5),
	@Customer	Varchar(20) = Null,
	@RunDate	Date,
	@Summary	Bit = 0,
	@SortBy		Char(1) = 'N'
AS
SET NOCOUNT ON

DECLARE @DateType	Char(1) = 'P',
		@CustName	Varchar(100)

IF @Customer = ''
	SET @Customer = Null

IF @Customer IS NOT Null
	SET @CustName = (SELECT RTRIM(LTRIM(CustName)) FROM CustomerMaster WHERE CompanyId = @Company AND CustNmbr = @Customer)

IF @RunDate < '01/01/2000'
	SET @RunDate = Null

DECLARE	@Query		Varchar(MAX) = '',
		@DateField	Varchar(10) = IIF(@DateType = 'P', 'GLPOSTDT', 'DOCDATE'),
		@AppEndDate	Date = ISNULL(@RunDate, GETDATE())

DECLARE	@tblResult	Table (
		Customer_ID			Varchar(15) Null,
		Customer_Name		Varchar(200) Null,
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
		Document_Amount		Numeric(18,3),
		Unapplied_Amount	Numeric(18,3),
		[Current]			Numeric(18,3),
		[0_to_30_Days]		Numeric(18,3),
		[31_to_60_Days]		Numeric(18,3),
		[61_to_90_Days]		Numeric(18,3),
		[91_to_180_Days]	Numeric(18,3),
		[180_and_Over]		Numeric(18,3),
		Balance				Numeric(18,3),
		SummaryRow			Smallint,
		DataCounter			Int Null)

IF @Summary = 1
BEGIN
	SET @Query = @Query + N'SELECT Customer_ID,
		Customer_Name,
		Customer, '

IF @Customer IS Null
	SET @Query = @Query + N''''' AS NationalId, '''' AS NationalAccount,'
ELSE
	SET @Query = @Query + N'NationalId, NationalAccount,'

SET @Query = @Query + N'Null AS Customer_Terms,
		Null AS Customer_Class,
		Null AS Price_Level,
		Null AS Document_Type,
		Null AS Document_Number,
		Null AS Document_Date,
		Null AS Due_Date,
		Null AS Last_Payment_Date,
		0 AS Document_Amount,
		0 AS Unapplied_Amount,
		SUM([Current]) AS [Current],
		0 AS [0_to_30_Days],
		SUM([31_to_60_Days]) AS [31_to_60_Days],
		SUM([61_to_90_Days]) AS [61_to_90_Days],
		SUM([91_to_180_Days]) AS [91_to_180_Days],
		SUM([180_and_Over]) AS [180_and_Over],
		SUM(Balance) AS Balance,
		1 AS SummaryRow,
		COUNT(*) AS DataCounter
	FROM ('
END

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
		0 AS SummaryRow,
		2 AS DataCounter
FROM	(
SELECT	*
FROM	(SELECT CUSTNMBR,
		CPRCSTNM,
		RMDTYPAL,
		DOCNUMBR,
		DOCDATE,
		DUEDATE,
		ORTRXAMT,
		CURTRXAM = ((ORTRXAMT + IIF(RMDTYPAL > 6, WROFAMNT, 0)) - ISNULL((SELECT SUM(RMA.APPTOAMT + RMA.WROFAMNT) AS SUMMARY FROM ' + @Company + '.dbo.RM20201 RMA WHERE RMA.CUSTNMBR = RM20101.CUSTNMBR AND IIF(RM20101.RMDTYPAL < 7, RMA.APTODCNM, RMA.APFRDCNM) = RM20101.DOCNUMBR AND RMA.Date1 <= ''' + CAST(@AppEndDate AS Char(10)) + '''),0))
FROM	' + @Company + '.dbo.RM20101
WHERE	VOIDSTTS = 0 
		'

IF @Customer IS NOT Null
	SET @Query =  @Query + 'AND (CUSTNMBR = ''' + RTRIM(@Customer) + ''' OR CPRCSTNM = ''' + RTRIM(@Customer) + ''')'

IF @RunDate IS NOT Null
BEGIN
	SET @Query =  @Query + 'AND ' + @DateField + ' <= ''' + CAST(@RunDate AS Char(10)) + '''
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
	WHERE	VOIDSTTS = 0 
			AND ' + @DateField + ' <= ''' + CAST(@RunDate AS Char(10)) + ''' '

	IF @Customer IS NOT Null
		SET @Query =  @Query + 'AND (CUSTNMBR = ''' + RTRIM(@Customer) + ''' OR CPRCSTNM = ''' + RTRIM(@Customer) + ''') '
END

SET @Query =  @Query + ') DATA WHERE CURTRXAM <> 0 '

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
		NationalAccount'

SET @Query = @Query + ' ORDER BY Customer, Document_Date DESC'
PRINT 'Running String Query'
PRINT @Query
INSERT INTO @tblResult
EXECUTE(@Query)

IF @Summary = 0
BEGIN
	PRINT 'Calculating Customer Summaries'

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
			0 AS Document_Amount,
			0 AS Unapplied_Amount,
			SUM([Current]) AS [Current],
			0 AS [0_to_30_Days],
			SUM([31_to_60_Days]) AS [31_to_60_Days],
			SUM([61_to_90_Days]) AS [61_to_90_Days],
			SUM([91_to_180_Days]) AS [91_to_180_Days],
			SUM([180_and_Over]) AS [180_and_Over],
			SUM(Balance) AS Balance,
			1 AS SummaryRow,
			COUNT(*) AS DataCounter
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
	PRINT 'Calculating Report Summary'

	INSERT INTO @tblResult
	SELECT	'ZZZZZZ' AS Customer_ID,
			'ZZZZZZ' AS Customer_Name,
			'S U M M A R Y' AS Customer,
			'' AS NationalId,
			'' AS NationalAccount,
			Null AS Customer_Terms,
			Null AS Customer_Class,
			Null AS Price_Level,
			Null AS Document_Type,
			Null AS Document_Number,
			Null AS Document_Date,
			Null AS Due_Date,
			Null AS Last_Payment_Date,
			0 AS Document_Amount,
			0 AS Unapplied_Amount,
			SUM([Current]) AS [Current],
			0 AS [0_to_30_Days],
			SUM([31_to_60_Days]) AS [31_to_60_Days],
			SUM([61_to_90_Days]) AS [61_to_90_Days],
			SUM([91_to_180_Days]) AS [91_to_180_Days],
			SUM([180_and_Over]) AS [180_and_Over],
			SUM(Balance) AS Balance,
			-1 AS SummaryRow,
			0 AS DataCounter
	FROM	@tblResult
	WHERE	SummaryRow = 1 --IIF(@Summary = 1, 0, 1)
END

IF (SELECT COUNT(*) FROM @tblResult) = 0
BEGIN
	INSERT INTO @tblResult
			(Customer_ID,
			Customer_Name,
			[Current],
			Balance,
			SummaryRow)
	VALUES
			(IIF(@Customer IS Null, '', @Customer),
			ISNULL(@CustName,''),
			0,
			0,
			1)
END

SELECT	Customer_ID AS Customer,
		IIF(@SortBy = 'N', Customer_Name + ' [' + Customer_ID + ']', Customer_ID + ' - ' + Customer_Name) AS CustomerName,
		Document_Number AS DocNumber,
		Document_Date AS DocDate,
		Due_Date AS DueDate,
		Document_Amount AS DocAmount,
		[Current],
		[31_to_60_Days] AS Days31_60,
		[61_to_90_Days] AS Days61_90,
		[91_to_180_Days] AS Days91_180,
		[180_and_Over] AS Days180More,
		Balance,
		CompanyName,
		SummaryRow AS IsSummary,
		DataCounter,
		Null AS PortDischargeDate,
		(SELECT COUNT(*) FROM (SELECT DISTINCT Customer_ID FROM @tblResult) DATA) AS CountCustomers
FROM	@tblResult DATA
		INNER JOIN GPCustom.dbo.Companies CPY ON CPY.CompanyId = @Company
ORDER BY
		2,
		IsSummary DESC,
		Due_Date,
		Document_Date,
		Document_Number