/*
EXECUTE OOS_Integrations_Balance_All 'IMC','06/10/2021'
*/
ALTER PROCEDURE [dbo].[OOS_Integrations_Balance_All]
		@Company	Varchar(5),
		@PayDate	Datetime
AS
DECLARE	@DateIni	Datetime,
		@DateEnd	Datetime,
		@BatchId	Varchar(13),
		@Query		Varchar(2000)

DECLARE	@tblFuel	Table (VendorId Varchar(15), Amount Numeric(10,2), WeekEndDate Date)

SET		@DateIni	= GPCUSTOM.dbo.DayFwdBack(@PayDate, 'P', 'Saturday')

IF DATENAME(Weekday, @PayDate) = 'Thursday'
	SET @DateEnd = @PayDate
ELSE
	SET @DateEnd = GPCUSTOM.dbo.DayFwdBack(@PayDate, 'N', 'Thursday')

SET	@BatchId = 'OOS' + RTRIM(@Company) + '_' + GPCustom.dbo.PADL(RTRIM(CAST(MONTH(@DateEnd) AS Char(2))), 2, '0') + GPCustom.dbo.PADL(RTRIM(CAST(DAY(@DateEnd) AS Char(2))), 2, '0') + RIGHT(CAST(YEAR(@DateEnd) AS Char(4)), 2)

SET @Query = N'SELECT VendorId, DocAmnt, DocDate FROM ' + RTRIM(@Company) + '.dbo.PM20000 WHERE BACHNUMB LIKE ''FPT_%'' AND DOCDATE = ''' + CAST(CAST(@DateIni AS Date) AS Varchar) + ''''
PRINT @Query
INSERT INTO @tblFuel
EXECUTE(@Query)

DELETE GPCustom.dbo.OOS_Transactions_Extras WHERE BatchId = @BatchId

INSERT INTO GPCustom.dbo.OOS_Transactions_Extras
SELECT	VendorId
		,@BatchId AS BatchId
		,@DateEnd AS WeekEndDate
		,SUM(CASE WHEN Type = 'FPT' THEN Amount ELSE 0 END) AS FPT
		,SUM(CASE WHEN Type = 'FEE' THEN Amount ELSE 0 END) AS FEE
		,SUM(CASE WHEN Type = 'DPY' THEN Amount ELSE 0 END) AS DPY
		,SUM(CASE WHEN Type = 'GPS' THEN Amount ELSE 0 END) AS GPS
FROM	(
SELECT	'FPT' AS Type
		,VendorId
		,ISNULL(Amount * -1, 0) AS Amount
		,WeekEndDate
FROM	@tblFuel
UNION
SELECT	'FEE' AS Type
		,VendorId
		,ISNULL((Cash + CashFee) * -1, 0) AS Amount
		,WeekEndDate
FROM	GPCUSTOM.dbo.View_Integration_FPT_Summary
WHERE	Company = @Company
		AND WeekEndDate BETWEEN @DateIni - 7 AND @DateEnd - 7
UNION
SELECT	'DPY' AS Type
		,VendorId
		,ISNULL(Drayage + DriverFuelRebate, 0) AS Amount
		,WeekEndDate
FROM	GPCUSTOM.dbo.View_Integration_AP
WHERE	Company = @Company
		AND WeekEndDate BETWEEN @DateIni AND @DateEnd
UNION
SELECT	'GPS' AS Type
		,VendorId
		,ISNULL(SUM(DocAmnt) * -1, 0) AS Amount
		,MIN(DocDate)
FROM	dbo.PM20000
WHERE	LEFT(VchrNmbr, 3) NOT IN ('DPY','FPT','OOS')
		AND DocDate BETWEEN @DateIni AND @DateEnd
GROUP BY VendorId) RECS
GROUP BY VendorId