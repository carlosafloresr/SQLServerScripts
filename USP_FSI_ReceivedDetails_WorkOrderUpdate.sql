/*
EXECUTE USP_FSI_ReceivedDetails_WorkOrderUpdate '9FSI20210609_0933'
*/
ALTER PROCEDURE USP_FSI_ReceivedDetails_WorkOrderUpdate
		@BatchId	Varchar(30)
AS
SET NOCOUNT ON

DECLARE	@CompanyNumber	Int,
		@InvoiceNumber	Varchar(30),
		@RecordId		Int,
		@Result			Int

DECLARE	@tblOrder		Table (OrderNumber Int)

DECLARE curGPTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	LEFT(BatchId, 1) AS CompanyNumber,
		InvoiceNumber,
		FSI_ReceivedDetailId
FROM	FSI_ReceivedDetails
WHERE	BatchId = @BatchId
		AND ISNULL(WorkOrder,0) = 0

OPEN curGPTransactions 
FETCH FROM curGPTransactions INTO @CompanyNumber, @InvoiceNumber, @RecordId

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblOrder
		
	INSERT INTO @tblOrder
	EXECUTE dbo.USP_PullOrderNumber @CompanyNumber, @InvoiceNumber

	SET @Result = (SELECT OrderNumber FROM @tblOrder)

	BEGIN TRY
		UPDATE	FSI_ReceivedDetails
		SET		WorkOrder = ISNULL(@Result, 0)
		WHERE	FSI_ReceivedDetailId = @RecordId
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE() + ' on Invoice:' + @InvoiceNumber
	END CATCH

	FETCH FROM curGPTransactions INTO @CompanyNumber, @InvoiceNumber, @RecordId
END

CLOSE curGPTransactions
DEALLOCATE curGPTransactions