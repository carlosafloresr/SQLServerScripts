SET NOCOUNT ON

DECLARE	@Company	Varchar(5) = 'DNJ',
		@PayDate	Date,
		@DriverId	Varchar(12) = 'D50479'

IF (SELECT TerminationDate FROM GPCustom.dbo.VendorMaster WHERE Company = @Company AND VendorId = @DriverId) IS Null
BEGIN
	SET @PayDate = dbo.DayFwdBack(GETDATE(), 'P', 'Thursday')
	EXECUTE USP_CalculateSafetyBonusTable @Company, @PayDate, @DriverId, 0
END