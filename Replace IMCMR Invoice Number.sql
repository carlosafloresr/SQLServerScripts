SELECT	*
FROM	Integrations_AR
WHERE	BatchId = 'REPAR_090419'
		AND Company = 'IMCMR'
		AND DOCNUMBR = 'B208891'

UPDATE	Integrations_AR
SET		Processed = 0
WHERE	BatchId = 'REPAR_090419'
		AND Company = 'IMCMR'
		AND DOCNUMBR = 'I1760016'

UPDATE	ReceivedIntegrations
SET		Status = 0
WHERE	BatchId = 'REPAR_090419'
		AND Company = 'IMCMR'