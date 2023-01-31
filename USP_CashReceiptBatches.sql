CREATE PROCEDURE USP_CashReceiptBatches (@BatchId Varchar(20), @UserId Varchar(25))
AS
IF EXISTS(SELECT BatchId FROM CashReceiptBatches WHERE BatchId = @BatchId)
	UPDATE CashReceiptBatches SET BatchStatus = 0 WHERE BatchId = @BatchId
ELSE
	INSERT INTO CashReceiptBatches (BatchId, UserId) VALUES (@BatchId, @UserId)