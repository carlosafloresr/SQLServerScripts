DECLARE @BatchId Varchar(25)
SET @BatchId = '10_FPT_12_20100327'

DELETE ReceivedIntegrations WHERE BatchId = @BatchId
DELETE FPT_ReceivedHeader WHERE BatchId = @BatchId
DELETE FPT_ReceivedDetails WHERE BatchId = @BatchId

--SELECT * FROM FPT_ReceivedHeader WHERE BatchId = @BatchId
--SELECT * FROM FPT_ReceivedDetails WHERE BatchId = @BatchiD

--UPDATE	FPT_ReceivedDetails 
--SET		VendorId = 'N1' + SUBSTRING(VendorId, 2, 5)
--WHERE	BatchId = @BatchiD