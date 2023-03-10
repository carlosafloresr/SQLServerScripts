ALTER PROCEDURE USP_CashReceipt
		@CashReceiptId		Int,
		@InvoiceNumber		Varchar(15),
		@Amount				Numeric(18,2),
		@InvoiceDate		Datetime,
		@Equipment			Varchar(20),
		@WorkOrder			Varchar(20),
		@NationalAccount	Varchar(12),
		@BatchId			Varchar(16),
		@Company			Varchar(5),
		@MatchedRecord		Bit = 0,
		@Processed			Int = 0
AS
IF @CashReceiptId IS Null
BEGIN
	BEGIN TRANSACTION

	INSERT INTO CashReceipt
			(InvoiceNumber
			,Amount
			,InvoiceDate
			,Equipment
			,WorkOrder
			,NationalAccount
			,BatchId
			,Company
			,MatchedRecord
			,Processed)
     VALUES
			(@InvoiceNumber
			,@Amount
			,@InvoiceDate
			,@Equipment
			,@WorkOrder
			,@NationalAccount
			,@BatchId
			,@Company
			,@MatchedRecord
			,@Processed)

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @@IDENTITY
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END
ELSE
BEGIN
	BEGIN TRANSACTION

	UPDATE	CashReceipt
	SET		InvoiceNumber	= @InvoiceNumber,
			Amount			= @Amount,
			InvoiceDate		= @InvoiceDate,
			Equipment		= @Equipment,
			WorkOrder		= @WorkOrder,
			NationalAccount	= @NationalAccount,
			BatchId			= @BatchId,
			Company			= @Company,
			MatchedRecord	= @MatchedRecord,
			Processed		= @Processed
     WHERE	CashReceiptId	= @CashReceiptId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @CashReceiptId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END