CREATE FUNCTION[dbo].[WeekDate]  (@dDate Datetime, @iWeekDay Int)
RETURNS Datetime
AS
BEGIN
	DECLARE @dReturnDate Datetime

	IF @dDate IS Null OR @iWeekDay < 1 OR @iWeekDay > 7
		SET	@dReturnDate = Null
	ELSE
    BEGIN
		IF @iWeekDay = 1 -- Sunady
		BEGIN
			SET @dReturnDate = CASE	WHEN DATENAME(Weekday, @dDate) = 'Sunday' THEN @dDate
									WHEN DATENAME(Weekday, @dDate) = 'Sunday' THEN @dDate
		END
		
	END

	RETURN @dReturnDate
END