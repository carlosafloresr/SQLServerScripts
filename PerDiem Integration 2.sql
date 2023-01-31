SELECT	*
FROM	Integrations_SOP
WHERE	BACHNUMB = 'PD180712141825R' --'PD180710151508R'

UPDATE	ReceivedIntegrations
SET		Status = 0
WHERE	BatchId = 'PD180712141825R'

insert into ReceivedIntegrations (Integration, Company, BatchId) values ('PDINV', 'IMC', 'PD180710151508R')
