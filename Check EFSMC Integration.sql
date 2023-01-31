SELECT	*
FROM	Integrations_AP
WHERE	INTEGRATION = 'EFSMC'
		AND DOCNUMBR = '112454488'
ORDER BY DOCNUMBR
		--AND ACTNUMST = '0-00-8040'

		SELECT DISTINCT VchNumWk, DocNumbr FROM Integrations_AP WHERE BatchId = 'EFSMC_04032017' AND Company = 'GIS' AND Integration = 'EFSMC' AND AP_Processed = 0 ORDER BY DocNumbr

SELECT	*
FROM	ReceivedIntegrations
WHERE	INTEGRATION = 'EFSMC'

DELETE	Integrations_AP
WHERE	INTEGRATION = 'EFSMC'