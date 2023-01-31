--SELECT DISTINCT DocNumber, DocDate, Customer, DocType, Amount, Intercompany FROM MSR_ReceviedTransactions WHERE BatchId = 'AR_FI_170105' AND Credit + Debit <> 0 AND Intercompany = 0 ORDER BY Intercompany, Customer, DocNumber

SELECT	DISTINCT * 
FROM	MSR_ReceviedTransactions 
WHERE	BatchId = 'AR_FI_170105' 
		AND Credit + Debit <> 0 
		AND Intercompany = 0 
		AND Description = 'B0'
ORDER BY Intercompany, Customer, DocNumber