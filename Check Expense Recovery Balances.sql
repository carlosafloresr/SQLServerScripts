SELECT	Company,
		GLAccount,
		SUM(Expense) AS Total
FROM	ExpenseRecovery
GROUP BY
		Company,
		GLAccount
ORDER BY
		Company,
		GLAccount