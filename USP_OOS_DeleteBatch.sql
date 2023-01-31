ALTER PROCEDURE USP_OOS_DeleteBatch (@BatchId Varchar(25))
AS
DELETE EscrowTransactions WHERE EscrowTransactionId  IN (SELECT Fk_EscrowTransactionId FROM OOS_Transactions WHERE BatchId = @BatchId AND Fk_EscrowTransactionId > 0)
DELETE OOS_Transactions WHERE BatchId = @BatchId
EXECUTE USP_OOS_RestoreHistory
GO

execute USP_OOS_DeleteBatch 'OOSAIS_100407'