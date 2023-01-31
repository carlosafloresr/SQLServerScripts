/*
EXECUTE USP_DeleteDuplicatedExpenseRecovery
*/
ALTER PROCEDURE USP_DeleteDuplicatedExpenseRecovery
AS
SELECT	PopUpId,
		COUNT(PopUpId) AS Counter
INTO	##tmpRecords1
FROM	ExpenseRecovery
GROUP BY PopUpId
HAVING	COUNT(PopUpId) > 1

SELECT	PopUpId,
		MIN(ExpenseRecoveryId) AS ExpenseRecoveryId
INTO	##tmpRecords2
FROM	ExpenseRecovery
WHERE	PopUpId IN (SELECT PopUpId FROM ##tmpRecords1)
GROUP BY PopUpId

DELETE	ExpenseRecovery
WHERE	ExpenseRecoveryId IN (
								SELECT	ER.ExpenseRecoveryId
								FROM	ExpenseRecovery ER
										INNER JOIN ##tmpRecords2 RE ON ER.PopUpId = RE.PopUpId
								WHERE	ER.ExpenseRecoveryId > Re.ExpenseRecoveryId
										AND ER.PopUpId = RE.PopUpId
							 )

DROP TABLE ##tmpRecords1
DROP TABLE ##tmpRecords2