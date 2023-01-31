
SELECT	InvoiceNumber, AcctApproved
FROM	KarmakIntegration 
WHERE	BatchId = 'SLSWE100210'
		AND InvoiceNumber IN ('8367','8368')
/*
UPDATE	KarmakIntegration 
SET		Processed = 0 --Account1 = REPLACE(Account1, 'DD', '09')
WHERE	BatchId = 'SLSWE150124'
		--AND PATINDEX('%-DD-%', Account1) > 0
		
USP_Karmak_KimIntegration 1, 1, 'CFLORES'

USP_KarmakIntegrationGrid
*/