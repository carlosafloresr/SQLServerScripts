/*
EXECUTE USP_FiscalPeriod_AR_Status 'AIS', '08/08/2022', 'ar'
*/
CREATE PROCEDURE USP_FiscalPeriod_AR_Status
		@Company	Varchar(5),
		@Date		Date,
		@Series		Char(2) = 'GL'
AS
DECLARE	@Query		Varchar(Max),
		@ModType	Int

SET @ModType	= CASE WHEN @Series = 'AP' THEN 4 WHEN @Series = 'AR' THEN 3 ELSE 2 END
SET @Query		= 'SELECT TOP 1 PeriodId AS Month, CAST(PeriodDt AS Date) AS PeriodStart, CAST(PerdEndt AS Date) AS PeriodEnd, CAST(CASE WHEN Closed = 0 THEN 1 ELSE 0 END AS Bit) AS PeriodOpen FROM ' + RTRIM(@Company) + '.dbo.SY40100 WHERE Series = ' + CAST(@ModType AS Varchar) + ' AND PeriodId > 0 AND '
SET @Query		= @Query + '''' + CONVERT(Char(10), @Date, 101) + ''' BETWEEN PeriodDt AND PerdEndt'
PRINT @Query
EXECUTE(@Query)