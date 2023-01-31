SELECT * FROM Integrations_AR WHERE Integration = 'TIPAR' --AND BatchId = 'TIPAR0410181034'
SELECT * FROM Integrations_ApplyTo WHERE Integration = 'TIPAR' --AND BatchId = 'TIPAR0410181034'
SELECT * FROM Integrations_AP WHERE Integration = 'TIPAP' --AND BatchId = 'TIPAR0410181034'
SELECT * FROM Integrations_ApplyTo WHERE Integration = 'TIPAP' --AND BatchId = 'TIPAR0410181034'
SELECT * FROM ReceivedIntegrations WHERE Integration IN ('TIPAR','TIPAP')

/*
--UPDATE Integrations_AR SET Processed = 0 WHERE Integration = 'TIPAR'
DELETE Integrations_AR WHERE Integration = 'TIPAR'
DELETE Integrations_ApplyTo WHERE Integration = 'TIPAR'
DELETE Integrations_AP WHERE Integration = 'TIPAP'
DELETE Integrations_ApplyTo WHERE Integration = 'TIPAP'
DELETE ReceivedIntegrations WHERE Integration IN ('TIPAR','TIPAP')
*/