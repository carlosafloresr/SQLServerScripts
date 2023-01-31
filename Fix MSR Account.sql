SELECT * FROM MSR_ReceviedTransactions WHERE Company = 'RCMR' AND BatchId = 'AR_RCMR_100512' AND DocNumber = '30881'

UPDATE MSR_ReceviedTransactions SET Account = '3-00-2110' WHERE Company = 'RCMR' AND BatchId = 'AR_RCMR_100526' AND Account = '3-03-2110'

EXECUTE USP_Identify_IntercompanyRecords 'AR_RCMR_100519', 'MSR'

-- TRUNCATE TABLE MSR_Intercompany

SELECT	DISTINCT Account
FROM	MSR_ReceviedTransactions 
WHERE	Company = 'RCMR' 
		AND BatchId = 'AR_RCMR_100526'
		AND Account NOT IN (SELECT	ActNumSt
FROM	ILSGP01.RCMR.dbo.GL00105)

SELECT * FROM MSR_ReceviedTransactions WHERE BatchId = 'AR_RCMR_100526' --AND DocNumber = '30957'
SELECT * FROM View_MSR_Intercompany WHERE BatchId = 'AR_RCMR_100526' AND InvoiceTotal <> Amount1 + Amount2 + Amount3