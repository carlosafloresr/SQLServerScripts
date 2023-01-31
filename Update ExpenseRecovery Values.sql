SELECT	*
FROM	ExpenseRecovery
WHERE	DocNumber = '235993'

/*
UPDATE	ExpenseRecovery
SET		Expense = ABS(Recovery),
		Recovery = 0,
		Closed = 0,
		Status = 'Open',
		StatusText = 'Open'
WHERE	DocNumber = '235993'
*/