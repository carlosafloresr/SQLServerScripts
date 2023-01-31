DELETE	ExpenseRecovery
WHERE	ExpenseRecoveryId IN (SELECT ExpenseRecoveryId FROM (
								SELECT	DocNumber
										,Reference
										,COUNT(Reference) AS Counter
										,MAX(ExpenseRecoveryId) AS ExpenseRecoveryId
								FROM	ExpenseRecovery
								WHERE	Company = 'IMC'
										--AND Vendor = '11959 - Rivercity Maintenance'
								GROUP BY DocNumber, Reference
								HAVING COUNT(Reference) > 1) RECS
							 )