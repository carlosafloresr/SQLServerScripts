DECLARE	@BatchId		Varchar(25) = 'REPAR_122122',
		@Integration	Varchar(6) = 'REPAR',
		@Company		Varchar(5) = 'IMCMR',
		@RunType		Char(1) = 'U',
		@ServerName		Varchar(20) = 'PRISQL01P'

IF @RunType = 'U'
BEGIN
	IF @Company IS Null
		SET @Company = (SELECT TOP 1 Company FROM Integrations_AR WHERE Integration = @Integration AND BatchId = @BatchId)

	IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WHERE Integration = @Integration AND BatchId = @BatchId AND Company = @Company)
		UPDATE ReceivedIntegrations SET Status = 0, GPServer = @ServerName WHERE Integration = @Integration AND BatchId = @BatchId AND Company = @Company
	ELSE
		INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer) VALUES (@Integration, @Company, @BatchId, @ServerName)

	UPDATE	Integrations_AR
	SET		Processed = 0
	WHERE	BatchId = @BatchId
			AND Integration = @Integration
			AND Company = @Company

	UPDATE	ReceivedIntegrations
	SET		[Status] = 0
	WHERE	BatchId = @BatchId
			AND Integration = @Integration
			AND Company = @Company

	SELECT	*
	FROM	ReceivedIntegrations
	WHERE	BatchId = @BatchId
			AND Integration = @Integration
			AND Company = @Company

	SELECT	*
	FROM	Integrations_AR
	WHERE	BatchId = @BatchId
			AND Integration = @Integration
			AND Company = @Company
END
ELSE
BEGIN
	IF @RunType = 'D'
	BEGIN
		DELETE	Integrations_AR
		WHERE	BatchId = @BatchId
				AND Integration = @Integration
				AND Company = @Company

		DELETE	ReceivedIntegrations
		WHERE	BatchId = @BatchId
				AND Integration = @Integration
				AND Company = @Company
	END
END

/*
UPDATE	Integrations_AR
SET		DOCNUMBR = 'B209085'
WHERE	BatchId = 'REPAR_100919'
		AND Integration = 'REPAR'
		AND Company = 'IMCMR'
		AND DOCNUMBR = 'B209024'
*/