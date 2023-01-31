DECLARE	@BatchId		Varchar(22) = REPLACE('LB102521IREC', 'LCKBX', 'LB'),
		@Company		Varchar(15) = 'HMIS',
		@Integration	Varchar(10) = 'APPLYAR',
		@GPServer		Varchar(15) = 'PRISQL01P',
		@Status			Smallint = 10

IF EXISTS(SELECT TOP 1 BatchId FROM Integrations_ApplyTo WHERE Company = @Company AND BatchId = @BatchId)
BEGIN
	SET NOCOUNT ON

	IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WHERE Integration = @Integration AND Company = @Company AND BatchId = @BatchId)
			UPDATE	ReceivedIntegrations 
			SET		Status = @Status, GPServer = @GPServer, Integration = UPPER(Integration)
			WHERE	Integration = @Integration
					AND Company = @Company
					AND BatchId = @BatchId
		ELSE
			INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer, Status) VALUES (@Integration, @Company, @BatchId, @GPServer, @Status)

	UPDATE	Integrations_ApplyTo
	SET		Processed = 0,
			Integration = @Integration
	WHERE	BatchId = @BatchId
			AND Company = @Company

	SELECT	*
	FROM	ReceivedIntegrations
	WHERE	BatchId = @BatchId
			AND Company = @Company
			AND Integration = @Integration

	SELECT	*
	FROM	Integrations_ApplyTo
	WHERE	BatchId = @BatchId
			AND Company = @Company

	PRINT 'UPDATE ReceivedIntegrations SET Status = 7 WHERE Company = ''' + @Company + ''' AND BatchId = ''' + @BatchId + ''''
END
ELSE
	PRINT 'No Apply To Records on this Batch'

/*
UPDATE	ReceivedIntegrations 
SET		Status = 7 
WHERE	Integration = 'APPLYAR' 
		AND Status <> 7
*/