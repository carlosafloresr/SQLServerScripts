/*
EXECUTE USP_FindKarmakSalesBatch '10/21/2009'
*/

ALTER PROCEDURE USP_FindKarmakSalesBatch (@WeekEndDate DateTime)
AS
DECLARE	@WEndDate		DateTime

IF DATENAME(weekday, @WeekEndDate) = 'Saturday'
	SET @WEndDate = @WeekEndDate
ELSE
BEGIN
	IF DATENAME(weekday, @WeekEndDate) = 'Monday'
		SET @WEndDate = DATEADD(Day, 5, @WeekEndDate)
	ELSE
	BEGIN
		IF DATENAME(weekday, @WeekEndDate) = 'Tuesday'
			SET @WEndDate = DATEADD(Day, 4, @WeekEndDate)
		ELSE
		BEGIN
			IF DATENAME(weekday, @WeekEndDate) = 'Wednesday'
				SET @WEndDate = DATEADD(Day, 3, @WeekEndDate)
			ELSE
			BEGIN
				IF DATENAME(weekday, @WeekEndDate) = 'Thursday'
					SET @WEndDate = DATEADD(Day, 2, @WeekEndDate)
				ELSE
				BEGIN
					IF DATENAME(weekday, @WeekEndDate) = 'Friday'
						SET @WEndDate = DATEADD(Day, 1, @WeekEndDate)
					ELSE
					BEGIN
						IF DATENAME(weekday, @WeekEndDate) = 'Sunday'
							SET @WEndDate = DATEADD(Day, 6, @WeekEndDate)
					END
				END
			END
		END
	END
END

SELECT TOP 1 BatchId, Processed FROM KarmakIntegration WHERE WeekEndDate = @WEndDate