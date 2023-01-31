USE [Integrations]
GO

DECLARE @BatchId		Varchar(20) = '2_FPT_20210320',
		@CurrentValue	Varchar(15) = '',
		@NewValue		Varchar(15) = ''

DECLARE @Company Varchar(5) = (SELECT Company FROM FPT_ReceivedHeader WHERE BatchId = @BatchId)

--UPDATE	FPT_ReceivedDetails 
--SET		VendorId = @NewValue
--WHERE	BatchId = @BatchId
--		AND VendorId = @CurrentValue

UPDATE FPT_ReceivedHeader	SET Status = 0 WHERE BatchId = @BatchId
UPDATE FPT_ReceivedDetails  SET Processed = 0 WHERE BatchId = @BatchId

IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WHERE BatchId = @BatchId AND Company = @Company)
	UPDATE ReceivedIntegrations SET Status = 0, GPServer = 'PRISQL01P' WHERE BatchId = @BatchId AND Company = @Company
ELSE
	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer)
	SELECT	'FPT', Company, BatchId, 'PRISQL01P' AS GPServer
	FROM	FPT_ReceivedHeader
	WHERE	Company = @Company
			AND BatchId = @BatchId

--DELETE	FPT_ReceivedDetails 
--WHERE	BatchId = '6_FPT_20180210'
--		AND VendorId NOT IN (SELECT VendorId FROM LENSASQL001.GPCustom.dbo.VendorMaster WHERE Company = 'HMIS')

--SELECT * FROM ReceivedIntegrations  WHERE BatchId = @BatchId
--SELECT * FROM FPT_ReceivedHeader	WHERE BatchId = @BatchId
--SELECT * FROM FPT_ReceivedDetails	WHERE BatchId = @BatchId --and VendorId = 'A0859'

--SELECT * FROM View_Integration_FPT_Summary WHERE BatchId = @BatchId AND (TotalFuel + Cash) <> 0

/*
SELECT	*
FROM	FPT_ReceivedHeader
WHERE	Company IN ('AIS','IMC')
		AND ReceivedOn BETWEEN '09/01/2018' AND '09/05/2018'

SELECT	*
FROM	FPT_ReceivedHeader
WHERE	BatchId = '10_FPT_20130601'

UPDATE	FPT_ReceivedDetails
SET		Division = '00'
WHERE	BatchId = '10_FPT_20130601'

UPDATE	FPT_ReceivedDetails 
SET		TotalFuel = 75.36
WHERE	FPT_ReceivedDetailId = 466782

UPDATE	FPT_ReceivedDetails 
SET		VendorId = 'G50006'
WHERE	BatchId = '2_FPT_20161001'
		AND VendorId = 'G1283'

DELETE	FPT_ReceivedDetails 
WHERE	BatchId = '2_FPT_20210320'
		AND VendorId IN ('G51268','G51291','G51302','G51321','G51326','G51346','G51356')
*/
--UPDATE	FPT_ReceivedDetails	
--SET		CashFee = 2.0
--WHERE	BatchId = '7_FPT_20100828' AND Cash <> 0

--DELETE ReceivedIntegrations WHERE BatchId = @BatchId --AND ReceivedIntegrationId = 30174
--DELETE FPT_ReceivedHeader WHERE BatchId = @BatchId --AND FPT_ReceivedHeaderId IN (3209)
--DELETE FPT_ReceivedDetails WHERE BatchId = @BatchId --AND FPT_ReceivedDetailId >= 455778

-- DELETE FOR NDS
/*
-- THIS DELETE THE DETAILS TABLE
DELETE	FPT_ReceivedDetails
WHERE	Batchid IN (
					SELECT	BatchId
					FROM	ReceivedIntegrations
					WHERE	Integration = 'FPT'
							AND company = 'NDS'
							AND ReceivedOn > '11/05/2012'
					)
-- THIS DELETE THE HEADER TABLE
DELETE	ReceivedIntegrations
WHERE	Integration = 'FPT'
		AND company = 'NDS'
		AND ReceivedOn > '11/05/2012'
*/