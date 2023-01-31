UPDATE	CashReceiptBatches
SET		BatchStatus = 0
WHERE	BatchId = 'AIS_CSH_060619'

UPDATE	CashReceipt
SET		Status = 0
WHERE	BatchId = 'AIS_CSH_060619'

UPDATE	CashReceiptRCCL
SET		Processed = 0
WHERE	BatchId = 'AIS_CSH_060619'

SELECT	*
FROM	CashReceipt
WHERE	BatchId = 'AIS_CSH_060619'

SELECT	*
FROM	CashReceiptRCCL
WHERE	BatchId = 'AIS_CSH_060619'