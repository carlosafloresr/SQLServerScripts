SELECT	*
FROM	Integrations_AP
WHERE	BatchId = 'IA170628044008'

SELECT	*
FROM	Integrations_AR
WHERE	BatchId = 'IA170628044008'

UPDATE	Integrations_AP
SET		AP_Processed = 0
WHERE	BatchId = 'IA170628044008'

UPDATE	Integrations_AR
SET		Processed = 0
WHERE	BatchId = 'IA170628044008'

UPDATE	ReceivedIntegrations
SET		Status = 0
WHERE	BatchId = 'IA170628044008'