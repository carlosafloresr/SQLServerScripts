DECLARE	@BatchId		Varchar(25) = 'PD221011165443P',
		@Integration	Varchar(6) = 'PDM',
		@Company		Varchar(5) = 'IMC'

IF @Company IS Null
	SET @Company = (SELECT TOP 1 Company FROM Integrations_AP WHERE Integration = @Integration AND BatchId = @BatchId)

IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WHERE Integration = @Integration AND BatchId = @BatchId)
	UPDATE ReceivedIntegrations SET Status = 0, GPServer = 'PRISQL01P' WHERE Integration = @Integration AND BatchId = @BatchId
ELSE
	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer, Status) VALUES (@Integration, @Company, @BatchId, 'PRISQL01P', 0)

--IF @Company = 'HMIS' AND @Integration = 'OOPAY'
--BEGIN
--	UPDATE	Integrations_AP
--	SET		VendorId = 'H50006'
--	WHERE	BatchId = @BatchId
--			AND Company = @Company
--			AND VendorId = '90998'
/*
	UPDATE	Integrations_GL
	SET		ACTNUMST = '1-35-6144'
	WHERE	BatchId = 'SBA_20181005'
			AND Company = 'DNJ'
			AND ACTNUMST = '1-66-6144'
--END
*/
UPDATE	Integrations_AP
SET		AP_Processed = 0
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
FROM	Integrations_AP
WHERE	BatchId = @BatchId
		AND Integration = @Integration
		AND Company = @Company

/*
UPDATE	Integrations_AP
SET		DOCAMNT = 1545.50,
		CHRGAMNT = 1545.50,
		TEN99AMNT = 1545.50,
		PRCHAMNT = 1545.50,
		DEBITAMT = CASE WHEN DEBITAMT > 0 THEN 1545.50 ELSE 0 END,
		CRDTAMNT = CASE WHEN CRDTAMNT > 0 THEN 1545.50 ELSE 0 END
WHERE	IntegrationsAPId IN (1000138,1000139)

DELETE	Integrations_AP
WHERE	IntegrationsAPId IN (1000140,1000141)

UPDATE	Integrations_AP
SET		VendorId = '1556E'
WHERE	BatchId = 'OOPAY121_042818'
		AND Company = 'HMIS'
		AND VendorId = '1556'

UPDATE	Integrations_AP
SET		VendorId = '1698C'
WHERE	BatchId = 'PTSPY-021718'
		AND Company = 'PTS'
		AND VendorId = '1698'

UPDATE	Integrations_gl
SET		ACTNUMST = '1-35-6144'
WHERE	BatchId = 'SBA_20181012'
		AND Company = 'DNJ'
		AND ACTNUMST = '1-66-6144'

UPDATE	Integrations_gl
SET		PROCESSED = 0
WHERE	BatchId = 'SBA_20181012'
		AND Company = 'DNJ'
		AND ACTNUMST = '1-66-6144'
*/