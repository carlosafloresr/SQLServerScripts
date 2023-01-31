
/*
NOTE:	If a problem is present during the OOS batch integration, some of the transaction will be missing in Great Plains. 
		By executing this script under the GP Company database and passing the OOS batch id GP will reactive only the missing 
		transactions to reprocess the OOS batch integration.
*/
SET NOCOUNT OFF

DECLARE	@Integration	Char(3) = 'OOS',
		@BatchId		Varchar(20) = 'OOSIMC_022516',
		@Company		Varchar(5) = DB_NAME()

UPDATE	GPCustom.dbo.OOS_Transactions
SET		OOS_Transactions.Processed = CASE WHEN RECS.DOCNUMBR IS NULL THEN 0 ELSE 1 END
FROM	(
			SELECT	OOS.TransactionId,
					OOS.Vendorid,
					OOS.Invoice,
					OOS.DedAmount,
					APO.DOCNUMBR
			FROM	GPCustom.dbo.View_OOS_Transactions OOS
					LEFT JOIN PM00400 APO ON OOS.Vendorid = APO.VendorId AND OOS.Invoice = APO.DOCNUMBR
			WHERE	BATCHID = @BatchId
					AND OOS.DedAmount <> 0
		) RECS
WHERE	OOS_Transactions.OOS_TransactionId = RECS.TransactionId

IF @@ROWCOUNT > 0
BEGIN
	IF EXISTS(SELECT BatchId FROM ILSINT02.Integrations.dbo.ReceivedIntegrations WHERE Integration = @Integration AND BatchId = @BatchId)
		UPDATE ILSINT02.Integrations.dbo.ReceivedIntegrations SET Status = 0 WHERE Integration = @Integration AND BatchId = @BatchId
	ELSE
		INSERT INTO ILSINT02.Integrations.dbo.ReceivedIntegrations (Integration, Company, BatchId) VALUES (@Integration, @Company, @BatchId)
END