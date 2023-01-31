/*
SELECT * FROM View_ExpenseRecovery WHERE EffDate IS NOT Null AND Company = 'AIS'
SELECT * FROM ExpenseRecovery WHERE EffDate IS NOT Null AND Company = 'AIS'
*/
DECLARE	@Company			Varchar(5),
		@ExpenseRecoveryId	Int
		
DECLARE Transactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company,
		ExpenseRecoveryId
FROM	ExpenseRecovery 
WHERE	StatusText IS Null

OPEN Transactions 
FETCH FROM Transactions INTO @Company, @ExpenseRecoveryId

BEGIN TRANSACTION

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_ExpenseRecovery_Update @Company, @ExpenseRecoveryId
	
	FETCH FROM Transactions INTO @Company, @ExpenseRecoveryId
END

CLOSE Transactions
DEALLOCATE Transactions

IF @@ERROR = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION