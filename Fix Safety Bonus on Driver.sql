DECLARE	@Company	Varchar(5) = 'DNJ',
		@VendorId	Varchar(15) = 'D50479'

DECLARE Drivers CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT VendorId
FROM	SafetyBonus
WHERE	Company = @Company
		AND SortColumn = 1
		AND Paid = 0
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VendorId = @VendorId))

OPEN Drivers
FETCH FROM Drivers INTO @VendorId

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @VendorId
	EXECUTE dbo.USP_RecalculateSafetyBonusByDriver @Company, @VendorId

	FETCH FROM Drivers INTO @VendorId
END

CLOSE Drivers
DEALLOCATE Drivers

SELECT	*
FROM	SafetyBonus
WHERE	VendorId = @VendorId
		AND Paid = 0
		--AND SortColumn = 0
ORDER BY Period DESC, PayDate DESC, SortColumn