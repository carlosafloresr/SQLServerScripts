DECLARE	@BatchId	Varchar(25)

SET NOCOUNT ON

DECLARE curBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT BatchId
FROM	FSI_ReceivedHeader
WHERE	ReceivedOn < '01/01/2020'
--BatchId NOT IN (SELECT BatchId FROM ReceivedIntegrations WHERE ReceivedOn < '01/01/2020')

OPEN curBatches 
FETCH FROM curBatches INTO @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE FSI_ReceivedSubDetails WHERE BatchId IN (SELECT BatchId FROM ReceivedIntegrations WHERE ReceivedOn < '01/01/2020')
	DELETE FSI_ReceivedDetails WHERE BatchId IN (SELECT BatchId FROM ReceivedIntegrations WHERE ReceivedOn < '01/01/2020')
	DELETE FSI_ReceivedHeader WHERE BatchId IN (SELECT BatchId FROM ReceivedIntegrations WHERE ReceivedOn < '01/01/2020')
	DELETE ReceivedIntegrations WHERE BatchId IN (SELECT BatchId FROM ReceivedIntegrations WHERE ReceivedOn < '01/01/2020')

	FETCH FROM curBatches INTO @BatchId
END

CLOSE curBatches
DEALLOCATE curBatches

