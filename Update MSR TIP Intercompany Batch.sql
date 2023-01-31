SELECT	*
FROM	View_MSR_Intercompany
WHERE	Company = 'FI'
		AND BatchId = 'AR_FI_110711'
		AND Intercompany = 'GIS'

/*
UPDATE	MSR_Intercompany
SET		Processed = 0
FROM	(
		SELECT	MSR_IntercompanyId
		FROM	View_MSR_Intercompany
		WHERE	Company = 'FI'
				AND BatchId = 'AR_FI_110711'
				AND Intercompany = 'GIS') RECS
WHERE	MSR_Intercompany.MSR_IntercompanyId = RECS.MSR_IntercompanyId
		
UPDATE	MSR_ReceviedTransactions
SET		Processed = 0
WHERE	Company = 'rcmr'
		AND BatchId = 'AR_RCMR_110622'
		
DELETE SELECT * FROM MSR_Intercompany WHERE BatchId = 'AR_RCMR_110622'

SELECT * FROM MSR_Intercompany WHERE BatchId = 'AR_RCMR_110622'
*/