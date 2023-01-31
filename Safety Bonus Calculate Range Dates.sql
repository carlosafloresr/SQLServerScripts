DECLARE	@Company	Varchar(5) = 'DNJ', 
		@DriverId	Varchar(12) = 'D50479',
		@PayDate	Date

DECLARE curDates CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	IndividualDate 
FROM	dbo.DateRangeTable('d', '01/04/2018', '12/29/2019', 7)

OPEN curDates 
FETCH FROM curDates INTO @PayDate

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT CONVERT(Char(10), @PayDate, 101)

	EXECUTE USP_CalculateSafetyBonusTable @Company, @PayDate, @DriverId

	FETCH FROM curDates INTO @PayDate
END

CLOSE curDates
DEALLOCATE curDates