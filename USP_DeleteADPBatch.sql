/*
EXECUTE USP_DeleteADPBatch 'DNJ', 'ADP1511121153'
*/
ALTER PROCEDURE USP_DeleteADPBatch
		@Company	Varchar(5),
		@BatchId	Varchar(25)
AS
IF (SELECT Status FROM ReceivedIntegrations WHERE Company = @Company AND BatchId = @BatchId) < 2 OR NOT EXISTS(SELECT Status FROM ReceivedIntegrations WHERE Company = @Company AND BatchId = @BatchId)
BEGIN
	DELETE	INTEGRATIONS_GL
	WHERE	COMPANY = @Company
			AND BATCHID = @BatchId

	DELETE	ReceivedIntegrations
	WHERE	COMPANY = @Company
			AND BATCHID = @BatchId

	SELECT 0 AS [Status]
END
ELSE
BEGIN
	SELECT 1 AS [Status]
END
GO