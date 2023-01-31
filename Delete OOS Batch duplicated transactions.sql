USE [GPCustom]
GO

DECLARE	@BatchId Varchar(25)
SET @BatchId = 'OOSGIS_122216'

DELETE	OOS_Transactions
FROM	(
		SELECT	Invoice,
				MAX(OOS_TransactionId) AS OOS_TransactionId
		FROM	OOS_Transactions 
		WHERE	BatchId = @BatchId
				AND Invoice IN (SELECT	Invoice
								FROM	(
										SELECT	Invoice, 
												COUNT(Invoice) AS Counter 
										FROM	OOS_Transactions 
										WHERE	BatchId = @BatchId
										GROUP BY Invoice 
										HAVING	COUNT(Invoice) > 1
										) DATA
								)
		GROUP BY Invoice
		) DATA
WHERE	OOS_Transactions.OOS_TransactionId = DATA.OOS_TransactionId

UPDATE	OOS_Transactions
SET		OOS_Transactions.Processed = 2
FROM	View_OOS_Transactions
WHERE	OOS_Transactions.OOS_TransactionId = View_OOS_Transactions.TransactionId
		AND OOS_Transactions.BatchId = @BatchId

UPDATE	ILSINT02.Integrations.dbo.ReceivedIntegrations
SET		Status = 2
WHERE	Integration = 'OOS'
		AND BatchId = @BatchId