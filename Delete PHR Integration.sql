USE [Integrations]
GO

DECLARE	@BatchId Varchar(22)
SET @BatchId = 'PHRRCCL_141129'

DELETE PHR_ReceivedTransactions WHERE BatchId = @BatchId
DELETE ReceivedIntegrations WHERE Integration = 'PHR' AND BatchId = @BatchId

SELECT * FROM PHR_ReceivedTransactions WHERE BatchId = @BatchId

--UPDATE PHR_ReceivedTransactions SET Processed = 0 WHERE BatchId = @BatchId
--UPDATE ReceivedIntegrations SET Status = 0 WHERE Integration = 'PHR' AND BatchId = @BatchId
