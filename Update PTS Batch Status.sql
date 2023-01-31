DECLARE	@BatchId Varchar(25) = 'PTSPY-102916'

UPDATE	Integrations_AP
SET		AP_Processed = 0
WHERE	BatchId = @BatchId
		AND Company = 'PTS'

UPDATE	ReceivedIntegrations
SET		Status = 0
WHERE	BatchId = @BatchId
		AND Company = 'PTS'