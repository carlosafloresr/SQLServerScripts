DECLARE	@Integration	Varchar(6) = 'PDINV',
		@BatchId		Varchar(25) = 'PD221110130818R',
		@Company		Varchar(5)

SET @Company = (SELECT TOP 1 Company FROM Integrations_SOP WHERE Integration = @Integration AND BACHNUMB = @BatchId)

IF @Company IS NOT Null
	EXECUTE USP_ReceivedIntegrations @Integration, @Company, @BatchId, @Status=0, @GPServer='PRISQL01P'

UPDATE	Integrations_SOP
SET		Processed = 0
WHERE	Company = @Company
		AND BACHNUMB = @BatchId

SELECT	* 
FROM	Integrations_SOP 
WHERE	BACHNUMB = @BatchId

/*
SELECT * FROM Integrations_SOP WHERE BACHNUMB = 'PD180823124604R'

UPDATE	Integrations_SOP
SET		ACTNUMST = '1-12-6594'
WHERE	Integration='PDINV'
		AND BACHNUMB = 'PD180830154547R'
		AND ACTNUMST = '1-39-6594'

UPDATE	Integrations_SOP
SET		ACTNUMST = '1-57-6594'
WHERE	Integration='PDINV'
		AND BACHNUMB = 'PD180830154547R'
		AND ACTNUMST = '1-0*-6594'
*/