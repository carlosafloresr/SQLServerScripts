ALTER TRIGGER TRG_ProcessCashBatch ON CashReceiptBatches AFTER INSERT, UPDATE
AS
DECLARE	@Company	Varchar(5),
		@BatchId	Varchar(20),
		@Status		Int

SELECT	@Company = Inserted.Company,
		@BatchId = Inserted.BatchId, 
		@Status = Inserted.BatchStatus 
FROM	Inserted

IF @Status = 0
BEGIN
	EXECUTE USP_CashReceiptBatch @Company, @BatchId
END