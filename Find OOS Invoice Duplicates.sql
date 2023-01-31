/*
select * from View_OOS_Transactions where invoice = 'OOTA9605030509A'

UPDATE dbo.OOS_Transactions SET Invoice = 'OOTA9605030509B' WHERE OOS_TransactionId = 122574
*/

SELECT	Invoice, 
		COUNT(Invoice) AS Counter 
FROM	OOS_Transactions 
WHERE	BatchId = 'OOSIMC_030509'
GROUP BY Invoice 
HAVING	COUNT(Invoice) > 0

DECLARE	@Integration	Varchar(6),
		@Company		Varchar(6),
		@BatchId		Varchar(30)

DECLARE Integrations CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Integration, Company, BatchId
FROM	ReceivedIntegrations
WHERE	Status = 0

OPEN Integrations 
FETCH FROM Integrations INTO @Integration, @Company, @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_RunBatch @Integration, @Company, @BatchId
	
	FETCH FROM Integrations INTO @Integration, @Company, @BatchId
END

CLOSE Integrations
DEALLOCATE Integrations