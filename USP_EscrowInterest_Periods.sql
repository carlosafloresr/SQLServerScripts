USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_EscrowInterest_Periods]    Script Date: 2/3/2021 5:06:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_EscrowInterest_Periods 'AIS', '0-02-2790', 'DRV', '201904', 1
EXECUTE USP_EscrowInterest_Periods 'AIS', '0-02-2790', 'DRV', '202101', 0
*/
ALTER PROCEDURE [dbo].[USP_EscrowInterest_Periods]
		@CompanyId		Varchar(5),
		@AccountNumber	Varchar(20),
		@DriverClass	Varchar(10),
		@Period			Char(6),
		@Validate		Bit = 0
AS
SET NOCOUNT ON

DECLARE	@PeriodNum		Int = CAST(RIGHT(@Period, 2) AS Int),
		@Counter		Int = 1,
		@NewPeriod		Char(7),
		@DateIni		Date,
		@DateEnd		Date,
		@Query			Varchar(Max)

DECLARE	@tblRates TABLE (
	Period		Char(7),
	DateIni		Date,
	DateEnd		Date,
	IntRate		Money,
	NextDate	Date)

DECLARE	@tblFiscalDate TABLE (Period Char(7), DateIni Date, DateEnd Date, AllRates Bit Null)

WHILE @Counter < 5
BEGIN
	SET	@Query	= 'SELECT RTRIM(Year1) + ''-'' + ''' + dbo.PADL(@Counter, 2, '0') + ''',
		DATEADD(dd, -1, MIN(CAST(DateStart AS Date))),
		MAX(DateEnd) AS DateEnd,
		Null
FROM	' + @CompanyId + '.dbo.View_FiscalPeriods
WHERE	Year1 = ''' + LEFT(@Period, 4) + ''' 
		AND PeriodId IN ' + CASE @Counter WHEN 1 THEN '(1,2,3)' WHEN 2 THEN '(4,5,6)' WHEN 3 THEN '(7,8,9)' ELSE '(10,11,12)' END + ' GROUP BY Year1'

IF MONTH(GETDATE()) IN (1,2) AND @Counter = 1
	SET	@Query = @Query + ' UNION SELECT RTRIM(Year1) + ''-'' + ''' + dbo.PADL(4, 2, '0') + ''',
		MIN(DateStart) AS DateIni,
		MAX(DateEnd) AS DateEnd,
		Null
FROM	' + @CompanyId + '.dbo.View_FiscalPeriods
WHERE	Year1 = ''' + CAST(CAST(LEFT(@Period, 4) AS Int) - 1 AS Varchar) + '''' +
		' AND PeriodId IN (10,11,12) GROUP BY Year1'

	INSERT INTO @tblFiscalDate
	EXECUTE(@Query)
	PRINT @Query

	SET @Counter = @Counter + 1
END

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Period, DateIni, DateEnd
FROM	@tblFiscalDate

OPEN curData 
FETCH FROM curData INTO @NewPeriod, @DateIni, @DateEnd

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @NewPeriod

	INSERT INTO @tblRates
	SELECT	@NewPeriod,
			ER.IniDate,
			ER.EndDate,
			ER.InterestRate,
			NextDate = (SELECT TOP 1 DATEADD(d, -1, E2.IniDate) FROM EscrowRates E2 WHERE E2.CompanyId = ER.CompanyId AND E2.AccountNumber = ER.AccountNumber AND E2.DriverClass = ER.DriverClass AND ER.EndDate = DATEADD(d, -1, E2.IniDate))
	FROM	EscrowRates ER
	WHERE	ER.CompanyId = @CompanyId
			AND ER.AccountNumber = @AccountNumber
			AND ER.DriverClass = @DriverClass
			AND ER.IniDate BETWEEN @DateIni AND @DateEnd
	ORDER BY ER.IniDate

	IF @@ROWCOUNT > 1
	BEGIN
		IF EXISTS(SELECT TOP 1 NextDate FROM @tblRates WHERE Period = @NewPeriod AND IntRate <> 0 AND NextDate IS Null)
			UPDATE @tblFiscalDate SET AllRates = 0 WHERE Period = @NewPeriod
		ELSE
			UPDATE @tblFiscalDate SET AllRates = 1 WHERE Period = @NewPeriod
	END
	ELSE
		UPDATE @tblFiscalDate SET AllRates = 0 WHERE Period = @NewPeriod

	FETCH FROM curData INTO @NewPeriod, @DateIni, @DateEnd
END

CLOSE curData
DEALLOCATE curData

IF @Validate = 0
	SELECT	*
	FROM	@tblFiscalDate
	ORDER BY 1
ELSE
BEGIN
	--SELECT	*
	--FROM	@tblRates

	SELECT	*
	FROM	@tblFiscalDate
	WHERE	REPLACE(Period, '-', '') = @Period
	ORDER BY 1
END