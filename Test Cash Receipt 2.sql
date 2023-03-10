/*
-- TRUNCATE TABLE Integrations_Cash
UPDATE Integrations_Cash SET Processed = 0
DELETE Integrations_AR WHERE Integration = 'CASHAR'
DELETE Integrations_ApplyTo WHERE Integration = 'CASHAR'
*/
SELECT	*
FROM	Integrations_Cash
WHERE	Integration = 'LCKBX'

SELECT	*
FROM	Integrations_ApplyTo
WHERE	Integration = 'CASHAR'

SELECT	*
FROM	Integrations_AR
WHERE	Integration = 'CASHAR'

SELECT	*
FROM	ReceivedIntegrations
WHERE	ReceivedOn > '02/12/2019'

EXECUTE Integrations.dbo.USP_ReceivedIntegrations 'CASHAR', 'AIS', 'LB010419034626', 10

/*
UPDATE	ReceivedIntegrations
SET		Status = 0
WHERE	Integration = 'LCKBX'

UPDATE	ReceivedIntegrations
SET		Status = 5
WHERE	Integration = 'CASHAR'

UPDATE Integrations_Cash SET Processed = 0
*/