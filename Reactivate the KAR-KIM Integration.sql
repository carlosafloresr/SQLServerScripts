/*
select	*
from	KarmakIntegration
where	BatchId = 'SLS WE123017'
		and AcctApproved = 1
		AND KIMBatchId IS not Null

SELECT	*
FROM	View_KarmakIntegration
WHERE	InvoiceNumber = 38299  

select	top 100 *
from	KarmakIntegration
where	KIMBatchId like 'KM1812131140%'
		AND InvoiceNumber in (38267,38299,38258,38289,38276)

UPDATE	KarmakIntegration
SET		KIMBatchId = 'KM1809201455b'
WHERE	InvoiceNumber in (38267,38299,38258,38289,38276)
		AND Account1 = '0-00-6315 '

UPDATE	KarmakIntegration
SET		Processed = 0
WHERE	BatchId = 'SLSWE031718'
*/

DECLARE	@BatchId	Varchar(25) = 'KM1812131141'

UPDATE	KarmakIntegration
SET		Processed = 5
WHERE	KIMBatchId = @BatchId
		AND AcctApproved = 1
		--AND InvoiceNumber in (38267,38299,38258,38289,38276)

UPDATE	IntegrationsDB.Integrations.dbo.ReceivedIntegrations
SET		Status = 0
WHERE	batchid = @BatchId

/*		
UPDATE	KarmakIntegration
SET		Account1 = '2-08-6160'
WHERE	KIMBatchId = 'KM1105251332'
		AND InvoiceNumber = '9983'
*/