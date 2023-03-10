USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AgingReport]    Script Date: 3/3/2020 11:32:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_AgingReport_AP @Company = 'AIS', @VendorId = '101', @RunDate = '01/10/2020'
EXECUTE USP_AgingReport_AP @Company = 'AIS', @RunDate = '01/01/2020'
EXECUTE USP_AgingReport_AP @Company = 'GSA', @RunDate = '05/01/2018', @Summary = 0, @VendorId = '19979', @SortBy = 'N'
EXECUTE USP_AgingReport_AP @Company = 'IMC', @RunDate = '02/01/2020', @Summary = 1, @VendorId = '24024'
*/
ALTER PROCEDURE [dbo].[USP_AgingReport_AP]
	@Company	Varchar(5),
	@VendorId	Varchar(20) = Null,
	@RunDate	Date,
	@Summary	Bit = 0,
	@SortBy		Char(1) = 'N'
AS
SET NOCOUNT ON

DECLARE @DateType	Char(1) = 'P',
		@VendName	Varchar(100)

IF @VendorId = ''
	SET @VendorId = Null

--IF @VendorId IS NOT Null
--	SET @VendName = (SELECT RTRIM(LTRIM(CustName)) FROM CustomerMaster WHERE CompanyId = @Company AND VendorId = @VendorId)

IF @RunDate < '01/01/2000'
	SET @RunDate = Null

DECLARE	@Query		Varchar(MAX) = '',
		@DateField	Varchar(10) = IIF(@DateType = 'P', 'PSTGDATE', 'DOCDATE'),
		@AppEndDate	Date = ISNULL(@RunDate, GETDATE())

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
		1 AS SummaryRow,
		COUNT(*) AS DataCounter
	FROM ('

SET @Query = @Query + N'SELECT RTRIM(CM.VENDORID) Vendor_ID,
		RTRIM(LTRIM(CM.VENDNAME)) Vendor_Name,
		RTRIM(CM.VENDORID) + '' - '' + RTRIM(CM.VENDORID) AS Vendor,
		RTRIM(CM.PYMTRMID) Vendor_Terms,
		RTRIM(CM.VNDCLSID) Vendor_Class,
		CASE RM.DOCTYPE
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
		RM.DOCAMNT * IIF(RM.DOCTYPE > 6, -1, 1) AS Document_Amount,
		RM.CURTRXAM * IIF(RM.DOCTYPE > 6, -1, 1) AS Unapplied_Amount,
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') <= 30 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 6, -1, 1)
			ELSE 0 END [Current],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') <= 30 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 6, -1, 1)
			ELSE 0 END [0_to_30_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') BETWEEN 31 AND 60 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 6, -1, 1)
			ELSE 0 END [31_to_60_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') BETWEEN 61 AND 90 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 6, -1, 1)
			ELSE 0 END [61_to_90_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') BETWEEN 91 AND 180 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 6, -1, 1)
			ELSE 0 END [91_to_180_Days],
		CASE WHEN DATEDIFF(d, RM.DOCDATE, ''' + CAST(@RunDate AS Char(10)) + ''') > 180 THEN RM.CURTRXAM * IIF(RM.DOCTYPE > 6, -1, 1)
			ELSE 0 END [180_and_Over],
		RM.CURTRXAM * IIF(RM.DOCTYPE > 6, -1, 1) AS Balance,
		0 AS SummaryRow,
		2 AS DataCounter
FROM	(SELECT VENDORID,
		DOCTYPE,
		DOCNUMBR,
		DOCDATE,
		DUEDATE,
		DOCAMNT,
		CURTRXAM = ((DOCAMNT + IIF(DOCTYPE > 6, WROFAMNT, 0)) - ISNULL((SELECT SUM(RMA.APPLDAMT + RMA.WROFAMNT) FROM ' + @Company + '.dbo.PM10200 RMA WHERE RMA.VENDORID = PM20000.VENDORID AND IIF(PM20000.DOCTYPE < 7, RMA.APTODCNM, RMA.APFRDCNM) = PM20000.DOCNUMBR AND RMA.Date1 <= ''' + CAST(@AppEndDate AS Char(10)) + '''),0))
FROM	' + @Company + '.dbo.PM20000
WHERE	VOIDED = 0 
		AND CURTRXAM <> 0 '

IF @VendorId IS NOT Null
		SET @Query =  @Query + 'AND VENDORID = ''' + RTRIM(@VendorId) + ''' '

IF @RunDate IS NOT Null
BEGIN
	SET @Query =  @Query + 'AND ' + @DateField + ' <= ''' + CAST(@RunDate AS Char(10)) + '''
	UNION
	SELECT	VENDORID,
			DOCTYPE,
			DOCNUMBR,
			DOCDATE,
			DUEDATE,
			DOCAMNT,
			CURTRXAM = ((DOCAMNT + IIF(DOCTYPE > 6, WROFAMNT, 0)) - ISNULL((SELECT SUM(RMA.APPLDAMT + RMA.WROFAMNT) FROM ' + @Company + '.dbo.PM30300 RMA WHERE RMA.VENDORID = PM30200.VENDORID AND IIF(PM30200.DOCTYPE < 7, RMA.APTODCNM, RMA.APFRDCNM) = PM30200.DOCNUMBR AND RMA.Date1 <= ''' + CAST(@AppEndDate AS Char(10)) + '''), 0))
	FROM	' + @Company + '.dbo.PM30200
	WHERE	VOIDED = 0 
			AND ' + @DateField + ' <= ''' + CAST(@RunDate AS Char(10)) + '''
			AND CURTRXAM <> 0 '

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
			1 AS SummaryRow,
			COUNT(*) AS DataCounter
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
			-1 AS SummaryRow,
			0 AS DataCounter
	FROM	@tblResult
	WHERE	SummaryRow = IIF(@Summary = 1, 0, 1)
END

IF (SELECT COUNT(*) FROM @tblResult) = 0
BEGIN
	INSERT INTO @tblResult
			(Vendor_ID,
			Vendor_Name,
			[Current],
			Balance,
			SummaryRow)
	VALUES
			(IIF(@VendorId IS Null, '', @VendorId),
			ISNULL(@VendName,''),
			0,
			0,
			1)
END

SELECT	Vendor_ID AS Customer,
		IIF(@SortBy = 'N', Vendor_Name + ' [' + Vendor_ID + ']', Vendor_ID + ' - ' + Vendor_Name) AS CustomerName,
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
		(SELECT COUNT(*) FROM (SELECT DISTINCT Vendor_ID FROM @tblResult) DATA) AS CountCustomers
FROM	@tblResult DATA
		INNER JOIN GPCustom.dbo.Companies CPY ON CPY.CompanyId = @Company
ORDER BY
		2,
		IsSummary DESC,
		Due_Date,
		Document_Date,
		Document_Number