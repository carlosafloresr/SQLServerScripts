ALTER PROCEDURE USP_CashReceiptTrucking
		@CashReceiptTruckingId	Int,
		@Company				Varchar(5),
		@BatchId				Varchar(20),
		@InvoiceNumber			Varchar(12),
		@Payment				Numeric(18,2),
		@NationalAccount		Varchar(10),
		@CustomerNumber			Varchar(10)
AS
IF @CashReceiptTruckingId IS Null
BEGIN
	INSERT INTO CashReceiptTrucking
			(Company
			,BatchId
			,InvoiceNumber
			,Payment
			,NationalAccount
			,CustomerNumber)
	VALUES (@Company
			,@BatchId
			,@InvoiceNumber
			,@Payment
			,@NationalAccount
			,@CustomerNumber)
END
ELSE
BEGIN
	UPDATE	CashReceiptTrucking
	SET		Payment					= @Payment,
			NationalAccount			= @NationalAccount,
			CustomerNumber			= @CustomerNumber
	WHERE	CashReceiptTruckingId	= @CashReceiptTruckingId
END


