SELECT	*
FROM	View_ExpenseRecovery
WHERE	ExpenseRecoveryId IN (
								SELECT	ExpenseRecoveryId
								FROM	(
										SELECT	Company, Vendor, Description, Amount, DocNumber, EffDate, COUNT(ExpenseRecoveryId) AS Counter, MIN(ExpenseRecoveryId) AS ExpenseRecoveryId
										FROM	View_ExpenseRecovery
										WHERE	Closed = 0
												AND EffDate = '09/28/2012'
										GROUP BY Company, Vendor, Description, Amount, DocNumber, EffDate
										HAVING COUNT(ExpenseRecoveryId) > 1
										) RECS
							)

/*
DELETE	ExpenseRecovery
WHERE	ExpenseRecoveryId IN (
								SELECT	ExpenseRecoveryId
								FROM	(
										SELECT	Company, Vendor, Description, Amount, DocNumber, EffDate, COUNT(ExpenseRecoveryId) AS Counter, MIN(ExpenseRecoveryId) AS ExpenseRecoveryId
										FROM	View_ExpenseRecovery
										WHERE	Closed = 0
												AND EffDate = '09/28/2012'
										GROUP BY Company, Vendor, Description, Amount, DocNumber, EffDate
										HAVING COUNT(ExpenseRecoveryId) > 1
										) RECS
							)
*/