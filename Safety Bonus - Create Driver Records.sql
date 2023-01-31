SET NOCOUNT ON

DECLARE	@Company		Varchar(5) = 'AIS',
		@VendorId		Varchar(15) = 'A50742',
		@WeekEndDate	Date

DECLARE curPayPeriods CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT WeekEndDate
FROM	(
		SELECT	WeekEndDate
		FROM	View_OOS_Transactions
		WHERE	Company = @Company
				AND VendorId = @VendorId
				AND WeekEndDate NOT IN (SELECT PayDate FROM SafetyBonus WHERE VendorId = @VendorId)
		UNION
		SELECT	DATEADD(dd, 5, WeekEndDate) AS WeekEndDate
		FROM	View_DPYTransactions
		WHERE	Company = @Company
				AND (VendorId = @VendorId
				OR DriverId = @VendorId)
		) DATA

OPEN curPayPeriods 
FETCH FROM curPayPeriods INTO @WeekEndDate

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT CAST(@WeekEndDate AS Date)

	EXECUTE USP_CalculateSafetyBonusTable @Company, @WeekEndDate, @VendorId

	FETCH FROM curPayPeriods INTO @WeekEndDate
END

CLOSE curPayPeriods
DEALLOCATE curPayPeriods

SELECT	*
FROM	VendorMaster
WHERE	VendorId = @VendorId

SELECT	*
FROM	SafetyBonus
WHERE	VendorId = @VendorId