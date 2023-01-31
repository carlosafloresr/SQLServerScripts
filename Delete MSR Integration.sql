USE [Integrations]
GO

DECLARE	@BatchId Varchar(20) = 'AR_FI_171229'

UPDATE	MSR_ReceviedTransactions
SET		Processed = 0
WHERE	BatchId = @BatchId

UPDATE	ReceivedIntegrations
SET		[Status] = 0
WHERE	BatchId = @BatchId

SELECT	*
FROM	MSR_ReceviedTransactions
WHERE	BatchId = @BatchId

--DELETE MSR_ReceviedTransactions WHERE BatchId = @BatchId
--DELETE MSR_IntercompanyBatch WHERE BatchId = @BatchId
--DELETE MSR_Intercompany WHERE BatchId = @BatchId
--DELETE ReceivedIntegrations WHERE BatchId = @BatchId

/*
select * from MSR_ReceviedTransactions WHERE BatchId = 'AR_FI_120224' and DocNumber = 'B73361    '

UPDATE	MSR_ReceviedTransactions
SET		Processed = 0
WHERE	BatchId = 'AR_FI_120810'
*/

--SELECT	*
--FROM	MSR_Intercompany
--WHERE	BatchId = 'AR_FI_120810'
--		AND (Account1 = '1-23-6629'
--		OR Account2 = '1-23-6629'
--		OR Account3 = '1-23-6629')
		--AND Amount2 <> 0
		--and Customer in (select Customer from MSR_Accounts where Company = 'FI' and Intercompany = 'IMC')

/*
UPDATE	MSR_Intercompany
SET		Processed = 0
WHERE	BatchId = 'AR_FI_120928'

UPDATE	MSR_Intercompany
SET		Account1 = '1-09-6629'
WHERE	BatchId = 'AR_FI_120810'
		AND (Account1 = '1-23-6629'
		OR Account2 = '1-23-6629'
		OR Account3 = '1-23-6629')
*/