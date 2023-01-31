/*
SELECT * FROM CashReceiptBatches
*/

UPDATE	CashReceiptBatches 
SET		BatchStatus = 0 
WHERE	BatchId IN ('45425')

UPDATE CashReceiptBatches SET BatchStatus = 0 WHERE BatchId = @BatchId