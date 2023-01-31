DECLARE	@MSR_IntercompanyBatchId	Int,
		@BatchId					Varchar(20)

DECLARE Invoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	MSR_IntercompanyBatchId,
		BatchId
FROM	MSR_IntercompanyBatch
WHERE	LEFT(BatchId, 5) = 'AR_FI'
		AND Processed = 2
		
OPEN Invoices 
FETCH FROM Invoices INTO @MSR_IntercompanyBatchId, @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	BEGIN TRANSACTION
	
	EXECUTE USP_Update_FI_Invoices @BatchId
	
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		UPDATE	MSR_IntercompanyBatch
		SET		Processed = 3
		WHERE	MSR_IntercompanyBatchId = @MSR_IntercompanyBatchId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		UPDATE	MSR_IntercompanyBatch
		SET		Processed = 99
		WHERE	MSR_IntercompanyBatchId = @MSR_IntercompanyBatchId
	END
	
	FETCH FROM Invoices INTO @MSR_IntercompanyBatchId, @BatchId
END

CLOSE Invoices
DEALLOCATE Invoices