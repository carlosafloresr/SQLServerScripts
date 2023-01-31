/*
EXECUTE USP_PaperlessInvoicing_Schedule
*/
ALTER PROCEDURE USP_PaperlessInvoicing_Schedule
AS
DECLARE	@DateIni	Date,
		@DateEnd	Date,
		@RunDate	Date = GETDATE()

IF DATENAME(weekday, @RunDate) = 'Monday'
	SET @DateIni = DATEADD(Day, -1, @RunDate)
ELSE
BEGIN
	IF DATENAME(weekday, @RunDate) = 'Tuesday'
		SET @DateIni = DATEADD(Day, -2, @RunDate)
	ELSE
	BEGIN
		IF DATENAME(weekday, @RunDate) = 'Wednesday'
			SET @DateIni = DATEADD(Day, -3, @RunDate)
		ELSE
		BEGIN
			IF DATENAME(weekday, @RunDate) = 'Thursday'
				SET @DateIni = DATEADD(Day, -4, @RunDate)
			ELSE
			BEGIN
				IF DATENAME(weekday, @RunDate) = 'Friday'
					SET @DateIni = DATEADD(Day, -5, @RunDate)
				ELSE
				BEGIN
					IF DATENAME(weekday, @RunDate) = 'Saturday'
						SET @DateIni = DATEADD(Day, -6, @RunDate)
					ELSE
					BEGIN
						IF DATENAME(weekday, @RunDate) = 'Sunday'
							SET @DateIni = @RunDate
					END
				END
			END
		END
	END
END

SET	@DateEnd = DATEADD(dd, 6, @DateIni)
SET @DateIni = DATEADD(dd, 1,@DateIni)

SELECT	PAP.PaperlessInvoicingRunId,
		DAT.Date,
		DAT.DayOfWeek,
		PAP.Daily,
		PAP.Weekly
FROM	dbo.Dates(@DateIni,@DateEnd) DAT
		INNER JOIN PaperlessInvoicingRun PAP ON DAT.DayOfWeek = PAP.WeekDay
WHERE	DAT.Date >= CAST(GETDATE() AS Date)
