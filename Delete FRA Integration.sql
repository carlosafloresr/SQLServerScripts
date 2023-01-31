DECLARE	@BatchId Varchar(30) = 'FRA201502260918'

UPDATE	Integrations_AP
SET		AP_Processed = 0,
		DOCDATE = CAST(DATEADD(dd, -1, GETDATE()) AS Date),
		PSTGDATE = CAST(GETDATE() AS Date),
		GPPostingDate = CAST(GETDATE() AS Date)
WHERE	BATCHID = @BatchId

UPDATE	ReceivedIntegrations
SET		STATUS = 0
WHERE	BATCHID = @BatchId

SELECT	*
FROM	Integrations_AP
WHERE	BATCHID = @BatchId