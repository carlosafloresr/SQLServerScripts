SELECT	*
FROM	ReceivedIntegrations
WHERE	Integration IN ('LCKBX') --('LCKBX','CASHAR')

/*
UPDATE	ReceivedIntegrations
SET		Status = 10
WHERE	BatchId = 'CH081720120000'

SELECT	*
FROM	Integrations_ApplyTo
WHERE	BatchId = 'LB081720120000'
		AND ApplyFrom = '184791'

UPDATE	Integrations_ApplyTo
SET		Processed = 0
WHERE	BatchId = 'LB081720120000'
		AND ApplyFrom = '184791'
*/

-- SELECT COUNT(*) AS Counter FROM Integrations_AR WHERE Company = 'AIS' AND BatchId = 'LB070920120000'

/*
UPDATE	ReceivedIntegrations
SET		STATUS = 10
WHERE	BatchId in ('CH071020120000')

UPDATE	Integrations_Cash 
SET		Processed = 0
WHERE	BACHNUMB = 'CH070620120000'

UPDATE	Integrations_ApplyTo
SET		Processed = 0
WHERE	BatchId = 'LB070620120000'
*/
