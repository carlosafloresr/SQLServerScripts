/*
SELECT	*
FROM	FSI_ReceivedDetails
WHERE	BatchId = '1FSI20150522_1321_SUM'
*/
-- OPTION 1
DECLARE @BatchId	Varchar(25) = '9FSI20150522_1321_SUM',
		@NewBatchId	Varchar(25) = '9FSI20150522_1321_SUM'

--UPDATE	FSI_ReceivedDetails
--SET		Processed = 0,
--		Division = '95',
--		BatchId = @NewBatchId
--WHERE	BatchId = @BatchId

--IF NOT EXISTS(SELECT BatchId FROM FSI_ReceivedHeader WHERE BatchId = @NewBatchId AND Company = 'GLSO')
--BEGIN
--	UPDATE	FSI_ReceivedHeader
--	SET		Company = 'GLSO',
--			Status = 0,
--			BatchId = @NewBatchId
--	WHERE	BatchId = @BatchId
--END

--UPDATE	FSI_ReceivedDetails
--SET		Processed = 0
--WHERE	BatchId = @NewBatchId

--UPDATE	FSI_ReceivedHeader
--SET		Status = 0
--WHERE	BatchId = @NewBatchId

-- OPTION 2
UPDATE	FSI_ReceivedDetails
SET		Processed = 0,
		Division = '95'
WHERE	BatchId = @BatchId

UPDATE	FSI_ReceivedHeader
SET		Company = 'GLSO',
		Status = 0
WHERE	BatchId = @BatchId

EXECUTE USP_ReceivedIntegrations 'FSI', 'GLSO', @BatchId, 0