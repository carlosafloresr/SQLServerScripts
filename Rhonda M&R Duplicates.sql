SELECT	Company + DocNumber + FailureReason AS KeyField,
		COUNT(DocNumber) AS Counter
INTO	#tmpData
FROM	ExpenseRecovery
WHERE	Closed = 0
GROUP BY Company, DocNumber, FailureReason
HAVING COUNT(DocNumber) > 1

SELECT	KeyField,
		MAX(ExpenseRecoveryId) AS ExpenseRecoveryId
INTO	#tmpDups
FROM	(
		SELECT	*, 
				Company + DocNumber + FailureReason AS KeyField
		FROM	ExpenseRecovery
		) RECS
WHERE	KeyField IN (
				SELECT	KeyField
				FROM	#tmpData
				)
		AND Closed = 0
GROUP BY KeyField

UPDATE	ExpenseRecovery
SET		Closed = 1,
		Status = 'Close',
		StatusText = 'Closed'
FROM	#tmpDups
WHERE	Company + DocNumber + FailureReason = KeyField
		AND ExpenseRecovery.ExpenseRecoveryId < #tmpDups.ExpenseRecoveryId

DROP TABLE #tmpDups
DROP TABLE #tmpData