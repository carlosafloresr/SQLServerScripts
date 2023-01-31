DECLARE	@BatchId		Varchar(25) = 'PPD20230120',
		@Integration	Varchar(6) = 'PPD',
		@Company		Varchar(5) = 'PDS',
		@IsProduction	Bit = 1,
		@GPServer		Varchar(20)

SET @GPServer = IIF(@IsProduction = 1, 'PRISQL01P', 'SECSQL01T')

IF @Company IS Null
	SET @Company = (SELECT TOP 1 Company FROM Integrations_AP WHERE Integration = @Integration AND BatchId = @BatchId)

IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WHERE Integration = @Integration AND Company = @Company AND BatchId = @BatchId)
	UPDATE ReceivedIntegrations SET Status = 0, GPServer = @GPServer, Validated = 0 WHERE Integration = @Integration AND Company = @Company AND BatchId = @BatchId
ELSE
	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer) VALUES (@Integration, @Company, @BatchId, @GPServer)

UPDATE	Integrations_AP
SET		AP_Processed = 0 --		PSTGDATE = CAST(PSTGDATE AS Date)
WHERE	BatchId = @BatchId
		AND Integration = @Integration
		AND Company = @Company

SELECT	*
FROM	ReceivedIntegrations
WHERE	BatchId = @BatchId
		AND Integration = @Integration
		AND Company = @Company

SELECT	*
FROM	Integrations_AP
WHERE	BatchId = @BatchId
		AND Integration = @Integration
		AND Company = @Company

/*
UPDATE	Integrations_AP
SET		VendorId = '1556E'
WHERE	BatchId = 'PTSPY-021718'
		AND Company = 'PTS'
		AND VendorId = '1556'

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

UPDATE	Integrations_AP
SET		ACTNUMST = '1-36-6591'
WHERE	BatchId = 'PD190122152801P'
		AND Company = 'DNJ'
		AND ACTNUMST = '1-34-6591'
*/