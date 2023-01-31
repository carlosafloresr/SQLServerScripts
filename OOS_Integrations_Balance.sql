/*
EXECUTE OOS_Integrations_Balance 'IMC','4465','04/08/2009'

select * from ILSINT01.Integrations.dbo.View_Integration_FPT_Summary where Company = 'IMC' AND WeekEndDate = '4/4/2009' order by vendorid AND ltrim(VendorId) = '8732'
*/
ALTER PROCEDURE OOS_Integrations_Balance
		@Company	Varchar(5),
		@VendorId	Varchar(12),
		@PayDate	Datetime
AS
DECLARE	@DateIni	Datetime,
		@DateEnd	Datetime

SET		@DateIni	= GPCUSTOM.dbo.DayFwdBack(@PayDate, 'P', 'Saturday')
print @DateIni
IF DATENAME(Weekday, @PayDate) = 'Thursday'
	SET @DateEnd = @PayDate
ELSE
	SET @DateEnd = GPCUSTOM.dbo.DayFwdBack(@PayDate, 'N', 'Thursday')

SELECT	'FPT' AS Type
		,ISNULL(TotalFuel * -1, 0) AS Amount
		,WeekEndDate
FROM	ILSINT01.Integrations.dbo.View_Integration_FPT_Summary
WHERE	Company = @Company
		AND VendorId = @VendorId
		AND WeekEndDate = @DateIni
UNION
SELECT	'FEE' AS Type
		,ISNULL((Cash + CashFee) * -1, 0) AS Amount
		,WeekEndDate
FROM	GPCUSTOM.dbo.View_Integration_FPT_Summary
WHERE	Company = @Company
		AND VendorId = @VendorId
		AND WeekEndDate BETWEEN @DateIni - 7 AND @DateEnd - 7
UNION
SELECT	'DPY' AS Type
		,ISNULL(Drayage + DriverFuelRebate, 0) AS Amount
		,WeekEndDate
FROM	GPCUSTOM.dbo.View_Integration_AP
WHERE	Company = @Company
		AND VendorId = @VendorId
		AND WeekEndDate BETWEEN @DateIni AND @DateEnd
UNION
SELECT	'GPS' AS Type
		,ISNULL(SUM(DocAmnt) * -1, 0) AS Amount
		,MIN(DocDate)
FROM	dbo.PM20000 
WHERE	VendorId = @VendorId
		AND LEFT(VchrNmbr, 3) NOT IN ('DPY','FPT','OOS')
		AND DocDate BETWEEN @DateIni AND @DateEnd