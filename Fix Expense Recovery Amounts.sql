/*
SELECT * 
FROM	ExpenseRecovery 
WHERE	DocNumber = '45C10C0001'

-- PATINDEX('%ATP%', DocNumber) > 0
		--AND 
		Company = 'AIS'
		AND Status = 'Open'
		AND Expense <> 0
		
UPDATE	ExpenseRecovery 
SET		Closed = 1,
		Status = 'Closed',
		StatusText = 'Closed'
WHERE	Recovery < 0
		OR EffDate < GETDATE() - 40

UPDATE	ExpenseRecovery 
SET		Recovery = Expense * -1,
		Expense = 0
WHERE	PATINDEX('%ATP%', DocNumber) > 0
		AND Company = 'AIS'
		AND Expense <> 0
		
UPDATE	ExpenseRecovery 
SET		Recovery = Recovery * -1,
		Expense = 0
WHERE	PATINDEX('%ATP%', DocNumber) > 0
		AND Company = 'AIS'
		AND Recovery > 0

SELECT	*
FROM	ExpenseRecovery
WHERE	PATINDEX('%ATP%', DocNumber) > 0
		AND Company = 'AIS'
		AND DocNumber = 'A0331ATP12-17802 1/3'
		AND Expense <> 0

UPDATE	ExpenseRecovery 
SET		Recovery = -140.31,
		Expense = 0
WHERE	ExpenseRecoveryId = 5675
		
UPDATE	ExpenseRecovery 
SET		Recovery = Recovery * -1
WHERE	Recovery > 0
*/
SELECT	* 
FROM	View_ExpenseRecovery 
WHERE	Company = 'AIS' 
		--AND DocNumber = '853352'
		--AND WithEmails <> 0
		--AND Status = 'Pending'
		--AND DocNumber = 'A0198 ATP5-39170 1/5'
--ORDER BY Division, PATINDEX('%' + LEFT(RepairType, 1) + '%', 'TFMO'), EffDate DESC
ORDER BY EffDate DESC, VoucherNo