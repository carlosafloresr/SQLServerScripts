-- SELECT * FROM FPT_ReceivedDetails WHERE BatchId = '10_FPT_20_20100612'

DECLARE @BatchId Varchar(20)
SET @BatchId = '10_FPT_15_20101127'

UPDATE	FPT_ReceivedDetails 
SET		VendorId = RTRIM('N' + SUBSTRING(VendorId, 2, 8)) 
WHERE	BatchId = @BatchId

SELECT * FROM dbo.ReceivedIntegrations WHERE BatchId = @BatchId
SELECT * FROM dbo.FPT_ReceivedHeader	WHERE BatchId = @BatchId
SELECT * FROM dbo.FPT_ReceivedDetails	WHERE BatchId = @BatchId


--DELETE dbo.ReceivedIntegrations WHERE BatchId = @BatchId AND ReceivedIntegrationId = 16393
--DELETE dbo.FPT_ReceivedHeader	WHERE BatchId = @BatchId AND FPT_ReceivedHeaderId > 1069
--DELETE dbo.FPT_ReceivedDetails	WHERE BatchId = @BatchId AND FPT_ReceivedDetailId > 180333


/*
UPDATE	FPT_ReceivedDetails 
SET		VendorId = 'N15015'
WHERE	BatchId = '10_FPT_15_20100717'
		AND VendorId = 'N15050'
		
SELECT * FROM FPT_ReceivedDetails WHERE	BatchId = '10_FPT_15_20100717' ORDER BY VendorId, FuelAmount --AND FPT_ReceivedDetailId > 145380


*/