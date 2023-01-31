DECLARE	@BatchId		Varchar(25) = 'SBA_20221104',
		@Integration	Varchar(6) = 'SBA',
		@Company		Varchar(5) = 'GIS',
		@RunType		Char(1) = 'U'

IF @Company IS Null
	SET @Company = (SELECT TOP 1 Company FROM Integrations_GL WHERE Integration = @Integration AND BatchId = @BatchId)

IF @RunType = 'U'
BEGIN
	IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WHERE Integration = @Integration AND Company = @Company AND BatchId = @BatchId)
		UPDATE ReceivedIntegrations SET Status = 0, GPServer = 'PRISQL01P' WHERE Integration = @Integration AND Company = @Company AND BatchId = @BatchId
	ELSE
		INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer) VALUES (@Integration, @Company, @BatchId, 'PRISQL01P')

	UPDATE	Integrations_GL
	SET		Processed = 0
	WHERE	BatchId = @BatchId
			AND Integration = @Integration
			AND Company = @Company

	SELECT	*
	FROM	ReceivedIntegrations
	WHERE	BatchId = @BatchId
			AND Integration = @Integration
			AND Company = @Company

	SELECT	*
	FROM	Integrations_GL
	WHERE	BatchId = @BatchId
			AND Integration = @Integration
			AND Company = @Company
END
ELSE
IF @RunType = 'D'
BEGIN
	DELETE	ReceivedIntegrations 
	WHERE	Integration = @Integration 
			AND Company = @Company 
			AND BatchId = @BatchId

	DELETE	Integrations_GL
	WHERE	BatchId = @BatchId
			AND Integration = @Integration
			AND Company = @Company
END

/*
UPDATE	Integrations_GL
SET		ACTNUMST = '1-35-6144'
WHERE	BatchId = 'SBA_20181112'
		AND Integration = 'SBA'
		AND ACTNUMST = '1-35 -6144'

UPDATE	Integrations_AP
SET		VendorId = '1698C'
WHERE	BatchId = 'PTSPY-021718'
		AND Company = 'PTS'
		AND VendorId = '1698'

UPDATE	Integrations_AP
SET		VendorId = 'P50020'
WHERE	BatchId = 'PTSPY-021718'
		AND Company = 'PTS'
		AND VendorId = '5002'
*/