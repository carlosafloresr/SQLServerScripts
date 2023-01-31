CREATE PROCEDURE USP_SalesInvoices
	@SalesInvoiceId		Int, 
	@InvoiceNumber		Char(15), 
	@CustomerId		Char(10), 
	@InvoiceDate		Smalldatetime,
	@ItemLine		Int,
	@ItemCode		Char(15), 
	@ProNumber		Char(15) = Null,
	@VendorId		Char(10) = Null,
	@ChassisNumber		Char(20) = Null, 
	@TrailerNumber		Char(20) = Null, 
	@AuthorizationNumber	Char(20) = Null, 
	@Description		Varchar(1500) = Null, 
	@UserId			Varchar(25)
AS
DECLARE	@ReturnValue		Int

BEGIN TRANSACTION

IF EXISTS(SELECT SalesInvoiceId FROM SalesInvoices WHERE SalesInvoiceId = @SalesInvoiceId)
BEGIN
	UPDATE	SalesInvoices
	SET	CustomerId		= @CustomerId,
		InvoiceDate		= @InvoiceDate, 
		ItemCode		= @ItemCode,
		ProNumber		= @ProNumber,
		VendorId		= @VendorId,
		ChassisNumber		= @ChassisNumber, 
		TrailerNumber		= @TrailerNumber, 
		AuthorizationNumber	= @AuthorizationNumber, 
		Description		= @Description, 
		CreatedBy		= @UserId
	WHERE	SalesInvoiceId 		= @SalesInvoiceId

	SET	@ReturnValue 		= @SalesInvoiceId
END
ELSE
BEGIN
	INSERT INTO SalesInvoices
	       (InvoiceNumber, 
		CustomerId, 
		InvoiceDate,
		ItemLine,
		ItemCode, 
		ProNumber,
		VendorId,
		ChassisNumber, 
		TrailerNumber, 
		AuthorizationNumber, 
		Description, 
		CreatedBy)
	VALUES (@InvoiceNumber,
		@CustomerId, 
		@InvoiceDate,
		@ItemLine,
		@ItemCode, 
		@ProNumber,
		@VendorId,
		@ChassisNumber, 
		@TrailerNumber, 
		@AuthorizationNumber, 
		@Description, 
		@UserId)

	SET	@ReturnValue = @@IDENTITY
END

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
	RETURN @ReturnValue
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	RETURN -1
END

GO