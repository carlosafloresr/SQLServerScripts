/*
EXECUTE USP_FindFiscalPeriod 'AIS','04/18/2018'
*/
ALTER PROCEDURE USP_FindFiscalPeriod
		@Company		Varchar(5),
		@DateToCheck	Date
AS
DECLARE @Query		Varchar(MAX)

DECLARE @tblPeriods Table (
		Year1		Int,
		Closed		Bit,
		PeriodId	Int,
		DateStart	Date,
		DateEnd		Date)

SET @Query = N'SELECT Year1, Closed, PeriodId, DateStart, DateEnd FROM ' + RTRIM(@Company) + '.dbo.View_FiscalPeriods 
			   WHERE ''' + CAST(@DateToCheck AS Varchar) + ''' BETWEEN DATESTART AND DATEEND'

INSERT INTO @tblPeriods
EXECUTE(@Query)

SELECT	CASE WHEN PeriodId = 1 THEN 'ENE'
			 WHEN PeriodId = 2 THEN 'FEB'
			 WHEN PeriodId = 3 THEN 'MAR'
			 WHEN PeriodId = 4 THEN 'APR'
			 WHEN PeriodId = 5 THEN 'MAY'
			 WHEN PeriodId = 6 THEN 'JUN'
			 WHEN PeriodId = 7 THEN 'JUL'
			 WHEN PeriodId = 8 THEN 'AGU'
			 WHEN PeriodId = 9 THEN 'SEP'
			 WHEN PeriodId = 10 THEN 'OCT'
			 WHEN PeriodId = 11 THEN 'NOV'
		ELSE 'DEC' END + '-' + CAST(Year1 AS Varchar) AS FiscalPeriod,
		Closed,
		DateStart AS FromDate,
		DateEnd AS ToDate
FROM	@tblPeriods