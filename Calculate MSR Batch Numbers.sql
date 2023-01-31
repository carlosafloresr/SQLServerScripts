SELECT	SUM(CASE WHEN Intercompany = 1 THEN Credit ELSE 0 END * CASE WHEN DocType = 'C' THEN -1 ELSE 1 END) AS Intercompany,
		SUM(CASE WHEN Intercompany = 0 THEN Credit ELSE 0 END * CASE WHEN DocType = 'C' THEN -1 ELSE 1 END) AS Sales
FROM	MSR_ReceviedTransactions
WHERE	BatchId = 'AR_FI_120706'