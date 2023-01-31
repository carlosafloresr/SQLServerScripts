DECLARE	@ExpirationDays			Int,
		@Fk_ManifestTypeId		Int = 1,
		@ExpirationDate			Date

-- Retrieve the number of days to evaluate expired Open Estimates
SELECT	@ExpirationDays = VarN
FROM	Parameters
WHERE	Fk_ManifestTypeId = @Fk_ManifestTypeId
		AND Company = 'ALL'
		AND ParameterCode = 'EXPIRATION_DAYS'

DECLARE TableCursor CURSOR FOR
SELECT	DISTINCT DATEADD(dd, @ExpirationDays, EffectiveDate) AS ExpirationDate
FROM	Transactions
WHERE	Fk_TransactionTypeId = 2
		AND DATEDIFF(dd, EffectiveDate, GETDATE()) >= @ExpirationDays
		AND CurrentRecord = 1
		AND Amount > 0

OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @ExpirationDate

WHILE @@FETCH_STATUS = 0
BEGIN
	EXECUTE USP_InsertExpiredOpenEstimateCredits @ExpirationDate

	FETCH NEXT FROM TableCursor INTO @ExpirationDate
END

CLOSE TableCursor
DEALLOCATE TableCursor