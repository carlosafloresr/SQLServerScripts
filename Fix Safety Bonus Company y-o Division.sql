SET NOCOUNT ON

DECLARE	@Company	Varchar(5) = 'AIS',
		@VendorId	Varchar(15)

DECLARE curRecords CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT VendorId
FROM	SafetyBonus
WHERE	VendorId IN (
					SELECT	VendorId
					FROM	VendorMaster
					WHERE	Company = @Company
							AND Division = '65')

OPEN curRecords 
FETCH FROM curRecords INTO @VendorId

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Driver Id: ' + @VendorId

	EXECUTE USP_RecalculateSafetyBonusByDriver @Company, @VendorId
							    
	FETCH FROM curRecords INTO @VendorId
END

CLOSE curRecords
DEALLOCATE curRecords

/*
EXECUTE USP_RecalculateSafetyBonusByDriver 'AIS', 'A51016'
*/