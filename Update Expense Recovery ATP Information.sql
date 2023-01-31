SELECT	*
FROM	ExpenseRecovery
WHERE	DocNumber = '7906670'

/*
UPDATE	ExpenseRecovery
SET		ATPApproved = 1,
		ATPDate = StartingDate
WHERE	ATPAmount > 0
		AND (Closed = 1
		OR StatusText = 'Pending')
*/