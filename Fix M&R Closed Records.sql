SELECT	*
FROM	ExpenseRecovery
WHERE	Expense > 0
		AND Company = 'IMC'
		AND MONTH(EffDate) = 1
		AND Closed = 0
		
UPDATE	ExpenseRecovery
SET		Status = 'Open', StatusText = 'Open'
WHERE	Expense > 0
		AND MONTH(EffDate) = 1
		AND Closed = 0
		
UPDATE	ExpenseRecovery
SET		Status = 'Open', StatusText = 'Open'
WHERE	StatusText = 'Pendin'
		AND ExpenseRecoveryId NOT IN (SELECT Fk_expenserecoveryId FROM ExpenseRecoveryEmails)
		AND Closed = 0