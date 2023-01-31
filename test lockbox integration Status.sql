select * from ReceivedIntegrations where batchid like '%0526%'
SELECT * FROM Integrations_AR where BatchId = 'LB052620120000'

update Integrations_Cash set Processed = 0 where BACHNUMB = 'CH052620120000'
update ReceivedIntegrations set Status = 0 where BatchId = 'CH052620120000'

update Integrations_AR set Processed = 0 where BatchId = 'LB052620120000'
update ReceivedIntegrations set Status = 0 where BatchId = 'LB052620120000'
update [Integrations].[dbo].[Integrations_ApplyTo] set Processed = 0 where BatchId = 'LB052620120000'



