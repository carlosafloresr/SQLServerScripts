SELECT	*
FROM	Integrations_ApplyTo
WHERE	Integration = 'TIPAP'
		--AND ApplyFrom = 'TIP0919181138D'
		AND BatchId = 'TIPAP0919181138'

SELECT	*
FROM	ReceivedIntegrations
WHERE	BatchId = 'TIPAP0919180946'

UPDATE	ReceivedIntegrations
SET		[Status] = 10
WHERE	BatchId = 'TIPAP0919181138'

UPDATE	Integrations_ApplyTo
SET		Processed = 1
WHERE	Integration = 'TIPAP'
		AND ApplyFrom = 'TIP0919181138C'
		AND ApplyTo = '97-105091'