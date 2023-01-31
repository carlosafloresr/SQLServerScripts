update ReceivedIntegrations set GPServer = 'PRISQL01P' WHERE GPServer = 'LENSASQL001'
update ReceivedIntegrations set GPServer = 'PRISQL01P' WHERE GPServer = 'ILSGP01'
update ReceivedIntegrations set GPServer = 'PRISQL01P' WHERE GPServer = 'ILSGPPROD'

select * from ReceivedIntegrations order by receivedon desc

/*
update ReceivedIntegrations set GPServer = 'PRISQL01P' WHERE GPServer = 'LENSASQL001'
update ReceivedIntegrations set GPServer = 'PRISQL01P' WHERE GPServer = 'ILSGP01'
update ReceivedIntegrations set GPServer = 'PRISQL01P' WHERE GPServer = 'ILSGPPROD'
update ReceivedIntegrations set GPServer = 'PRISQL01P' WHERE GPServer in ('PRI','ILS')

select * from ReceivedIntegrations where GPServer <> 'PRISQL01P'
select * from integrations_ap where BatchId = 'EFSMC_102218' and company = 'GIS'

UPDATE integrations_ap 
SET		ACTNUMST = '1-02-6000'
where BatchId = 'EFSMC_102218' and company = 'GIS' AND ACTNUMST = '1/2/6000'
*/