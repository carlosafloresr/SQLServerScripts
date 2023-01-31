DECLARE	@PayDate Date = '06/23/2022'

DELETE	SafetyBonus 
WHERE	Company = 'GIS'
		AND PayDate = @PayDate
		--AND VendorId = 'G51415'

EXECUTE USP_CalculateSafetyBonusTable 'GIS', @PayDate--, 'G51415'