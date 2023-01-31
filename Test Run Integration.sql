CREATE PROCEDURE USP_FindIntegrations
AS
DECLARE	@Integration	Varchar(6),
		@Company		Varchar(6),
		@BatchId		Varchar(30)

DECLARE Integrations CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Integration, Company, BatchId
FROM	ReceivedIntegrations
WHERE	Status = 0

OPEN Integrations 
FETCH FROM Integrations INTO @Integration, @Company, @BatchId

BEGIN TRANSACTION

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_RunBatch @Integration, @Company, @BatchId
	
	FETCH FROM Integrations INTO @Integration, @Company, @BatchId
END

CLOSE Integrations
DEALLOCATE Integrations