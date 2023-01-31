DECLARE	@Company		Varchar(5), 
		@VendorId		Varchar(12), 
		@PayDate		Date,
		@SafetyBonusId	Int

DECLARE Drivers CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT SAF.Company, 
		SAF.VendorId, 
		SAF.PayDate, 
		MIN(SAF.SafetyBonusId) AS SafetyBonusId
FROM	SafetyBonus SAF
		INNER JOIN (
					SELECT	Company, VendorId, PayDate, COUNT(PayDate) AS Counter
					FROM	SafetyBonus
					WHERE	SortColumn = 1
							AND PayDate > '01/01/2014'
					GROUP BY Company, VendorId, PayDate
					HAVING COUNT(PayDate) > 1
					) DAT ON SAF.Company = DAT.Company AND SAF.VendorId = DAT.VendorId AND SAF.PayDate = DAT.PayDate
GROUP BY
		SAF.Company, 
		SAF.VendorId, 
		SAF.PayDate

OPEN Drivers
FETCH FROM Drivers INTO @Company, @VendorId, @PayDate, @SafetyBonusId

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @VendorId
	
	DELETE	SafetyBonus
	WHERE	Company = @Company
			AND VendorId = @VendorId
			AND PayDate = @Paydate
			AND SafetyBonusId > @SafetyBonusId

	EXECUTE dbo.USP_RecalculateSafetyBonusByDriver @Company, @VendorId

	FETCH FROM Drivers INTO @Company, @VendorId, @PayDate, @SafetyBonusId
END

CLOSE Drivers
DEALLOCATE Drivers
