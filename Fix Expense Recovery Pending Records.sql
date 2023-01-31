UPDATE	ExpenseRecovery
SET		Status = 'Open', StatusText = 'Open'
WHERE	ExpenseRecoveryId IN (	SELECT ExpenseRecoveryId
								FROM	View_ExpenseRecovery
								WHERE	Closed = 0
										AND Attachments = 0
										AND Status = 'Pending')