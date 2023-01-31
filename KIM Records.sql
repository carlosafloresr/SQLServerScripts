SELECT	*
FROM	KarmakIntegration
WHERE	KIMBatchId = 'KM1108050958'

/*
UPDATE	KarmakIntegration
SET		AcctApproved = 1, Processed = 5, Account1 = REPLACE(Account1, '-DD-', '-09-'), Description1 = CASE WHEN Description1 IS Null THEN 'Temporal Description' ELSE Description1 END
WHERE	BatchId = 'KM1108050958'
		--AND Processed = 2
		AND CustomerNumber NOT IN ('AIS','GIS','RCMR')
		AND InvoiceTotal > 0
*/