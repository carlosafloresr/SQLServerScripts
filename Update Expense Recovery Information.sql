SELECT	*
FROM	ExpenseRecovery
WHERE	Company = 'gis'
		--AND Expense = 360
		--AND Recovery = -230.11
		--AND EffDate = '3/7/2013'
		AND ProNumber = '15-128358'

UPDATE	ExpenseRecovery
SET		EffDate = '3/3/2013',
		Validated = 1
WHERE	ExpenseRecoveryId in (35547)