SELECT	*
FROM	View_Integration_FSI_Full
WHERE	BatchId = '7FSI20190226_1806'
		--AND ICB_AP = 1

SELECT	*
FROM	FSI_ReceivedSubDetails
WHERE	BatchId = '7FSI20190226_1226'
		AND ICB = 1

SELECT	*
FROM	FSI_ReceivedDetails
WHERE	BatchId = '7FSI20190226_1226'
		--AND DetailId = 1

/*
SELECT	*
FROM	ReceivedIntegrations
WHERE	BatchId LIKE '%FSI%'
*/