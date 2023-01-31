DECLARE	@Company	Varchar(5),
		@PayPeriod	Date

DECLARE PayPeriods CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT Company, PayDate
FROM	SafetyBonus
WHERE	Company = 'GIS'
		AND PayDate >= '05/20/2022'
ORDER BY PayDate
 
OPEN PayPeriods 
FETCH FROM PayPeriods INTO @Company, @PayPeriod

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @PayPeriod

	BEGIN TRY
		DELETE	SafetyBonus 
		WHERE	Company = @Company 
				AND PayDate = @PayPeriod

		EXECUTE USP_CalculateSafetyBonusTable @Company, @PayPeriod
	END TRY
	BEGIN CATCH  
		PRINT ERROR_MESSAGE()
	END CATCH

	FETCH FROM PayPeriods INTO @Company, @PayPeriod
END

CLOSE PayPeriods
DEALLOCATE PayPeriods

SELECT	DISTINCT Company, PayDate
FROM	SafetyBonus
WHERE	Company = 'GIS'
		AND PayDate >= '05/20/2022'
ORDER BY PayDate

/*
EXECUTE USP_CalculateSafetyBonusTable 'GIS', '05/19/2022'

UPDATE	SafetyBonus
SET		ToPay = MILES * 0.02, PeriodPay = MILES * 0.02, Percentage = 0.02, DrayageBonus = Drayage * 0.02
WHERE	Company = 'GIS'
		AND Paid = 0

SELECT	GrandfatherDate
	FROM	SafetyBonusParameters
	WHERE	Company = 'GIS'
*/