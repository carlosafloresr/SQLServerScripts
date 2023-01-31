USE [GPCustom]
GO

DECLARE	@batchId Varchar(25)
SET @batchId = 'AISIMC_090618'

UPDATE	OOS_Transactions
SET		OOS_Transactions.Processed = 0
FROM	View_OOS_Transactions
WHERE	OOS_Transactions.OOS_TransactionId = View_OOS_Transactions.TransactionId
		AND OOS_Transactions.BatchId = @batchId

INSERT INTO IntegrationsDB.Integrations.dbo.ReceivedIntegrations 
		(Integration, Company, BatchId, GPServer)
VALUES
		('OOS', 'IMC', @batchId, 'SECSQL001T')


--SELECT	*
--FROM	View_OOS_Transactions
--WHERE	BatchId = @batchId
--		AND VENDORID = 'I50185'
--ORDER BY DeductionCode

-- DELETE OOS_Transactions WHERE OOS_TransactionId = 2763640
-- SELECT * FROM OOS_Transactions WHERE OOS_TransactionId = 22628
/*
DELETE PM10300 WHERE Company = 'nds' AND BachNUMB = 'DSDRV081210CK'
DELETE PM10201 WHERE Company = 'nds' AND BachNUMB = 'DSDRV081210CK'
*/
