ALTER PROCEDURE [dbo].[USP_CashReceipt]
		@CashReceiptId		Int,
		@InvoiceNumber		Varchar(15),
		@Amount				Varchar(25),
		@InvoiceDate		Varchar(25),
		@Equipment			Varchar(20) = Null,
		@WorkOrder			Varchar(20) = Null,
		@NationalAccount	Varchar(12) = Null,
		@BatchId			Varchar(16),
		@Company			Varchar(5),
		@FromFile			Varchar(50) = Null,
		@Payment			Varchar(20) = Null,
		@MatchedRecord		Bit = 0,
		@Processed			Int = 0,
		@Fk_CheckId			Int = Null,
		@CheckNumber		Varchar(35) = Null
AS

DECLARE	@RealInvoiceDate	Datetime,
		@RealAmount			Numeric(18,2),
		@RealStatus			Int

-- *** New Date Conversion Proces ***
BEGIN TRY
	SET @RealInvoiceDate = CAST(@InvoiceDate AS Datetime)
END TRY
BEGIN CATCH
	SET @RealInvoiceDate = NULL
END CATCH

-- *** New Amount Conversion Proces ***
BEGIN TRY
	SET @RealAmount = CAST(@Amount AS Numeric(18,2))
END TRY
BEGIN CATCH
	SET @RealAmount = NULL
END CATCH

IF @RealInvoiceDate IS NULL OR @RealAmount IS NULL
BEGIN
	SET @RealStatus = 9
END

IF @CashReceiptId IS Null OR @CashReceiptId = 0
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
			,FromFile
			,Payment
			,MatchedRecord
			,Processed
			,Orig_InvoiceNumber
			,Orig_Amount
			,Orig_InvoiceDate
			,Orig_Equipment
			,Orig_WorkOrder
			,Orig_NationalAccount
			,Fk_CheckId
			,CheckNumber
			,TextDate
			,TextAmount)
     VALUES
			(@InvoiceNumber
			,@Amount
			,@RealInvoiceDate
			,@Equipment
			,@WorkOrder
			,@NationalAccount
			,@BatchId
			,@Company
			,@FromFile
			,@Payment
			,@MatchedRecord
			,@Processed
			,@InvoiceNumber
			,@RealAmount
			,@InvoiceDate
			,@Equipment
			,@WorkOrder
			,@NationalAccount
			,@Fk_CheckId
			,@CheckNumber
			,@InvoiceDate
			,@Amount)

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
			Payment			= @Payment,
			MatchedRecord	= @MatchedRecord,
			Processed		= @Processed,
			CheckNumber		= @CheckNumber
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