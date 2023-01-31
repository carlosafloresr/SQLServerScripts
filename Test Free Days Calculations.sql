DECLARE	@Freeweekends	Int,
		@Freeholidays	Int,
		@StartDate		Datetime,
		@LastDate		Datetime,
		@LastFreeDay	Datetime,
		@Freedays		Int,
		@Holidays		Int,
		@Weekends		Int

SET @Freeweekends	= 0
SET @Freeholidays	= 0
SET @StartDate		= '12/22/2011'
SET @LastDate		= '01/30/2012'
SET @Freedays		= 10

SELECT	DAT.Date,
		CASE WHEN DAT.WeekDay IN (0,1) THEN 'W' 
				WHEN HOL.Date IS NOT Null THEN 'H' 
				ELSE 'R' 
		END AS Type,
		CASE WHEN @Freeweekends = 0 AND DAT.WeekDay IN (0,1) THEN 0 
				WHEN @Freeholidays = 0 AND HOL.Date IS NOT Null THEN 0
				ELSE 1
		END AS Value
INTO	#tmpDates			
FROM	dbo.Dates (@StartDate, DATEADD(dd, @Freedays, @LastDate)) DAT
		LEFT JOIN Holidays HOL ON DAT.Date = HOL.Date

SELECT	@LastFreeDay	= RECS.Date,
		@Holidays		= RECS.Holidays,
		@Weekends		= RECS.Weekends
FROM	(
		SELECT	TMP1.Date,
				FreeDays = CASE WHEN TMP1.Value = 0 THEN 0 ELSE (SELECT SUM(TMP2.Value) FROM #tmpDates TMP2 WHERE TMP2.Date <= TMP1.Date) END,
				Holidays = (SELECT COUNT(TMP2.Type) FROM #tmpDates TMP2 WHERE TMP2.Date <= TMP1.Date AND TMP2.Type = 'H'),
				Weekends = (SELECT COUNT(TMP2.Type) FROM #tmpDates TMP2 WHERE TMP2.Date <= TMP1.Date AND TMP2.Type = 'W')
		FROM	#tmpDates TMP1
		) RECS
WHERE	FreeDays = @Freedays

DROP TABLE #tmpDates

print @LastFreeDay
PRINT @Holidays
PRINT @Weekends
