ALTER PROCEDURE USP_SalesInvoices_PD
	@SalesInvoiceId		Int,
	@CompanyId		Char(6),
	@InvoiceNumber		Char(15), 
	@CustomerId		Char(10), 
	@InvoiceDate		Smalldatetime,
	@ItemLine		Int,
	@ItemCode		Char(15), 
	@TrailerNumber		Char(15) = Null,
	@VendorId		Char(10) = Null,
	@APInvoice		Char(15) = Null, 
	@FromDate		SmallDateTime = Null,
	@ToDate			SmallDateTime = Null,
	@FreeDays		Int = Null,
	@BillDays1		Int = Null,
	@BillAt1		Money = Null,
	@BillDays2		Int = Null,
	@BillAt2		Money = Null,
	@BillDays3		Int = Null,
	@BillAt3		Money = Null,
	@OwnerName		Varchar(25) = Null,
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
		TrailerNumber		= @TrailerNumber, 
		VendorId		= @VendorId,
		APInvoice		= @APInvoice,
		FromDate		= @FromDate,
		ToDate			= @ToDate,
		FreeDays		= @FreeDays,
		BillDays1		= @BillDays1,
		BillAt1			= @BillAt1,
		BillDays2		= @BillDays2,
		BillAt2			= @BillAt2,
		BillDays3		= @BillDays3,
		BillAt3			= @BillAt3,
		OwnerName		= @OwnerName,
		CreatedBy		= @UserId
	WHERE	SalesInvoiceId 		= @SalesInvoiceId

	SET	@ReturnValue 		= @SalesInvoiceId
END
ELSE
BEGIN
	INSERT INTO SalesInvoices
	       (CompanyId,
		InvoiceNumber, 
		CustomerId, 
		InvoiceDate,
		RecordType,
		ItemLine,
		ItemCode, 
		TrailerNumber,
		VendorId,
		APInvoice,
		FromDate,
		ToDate,
		FreeDays,
		BillDays1,
		BillAt1,
		BillDays2,
		BillAt2,
		BillDays3,
		BillAt3,
		OwnerName,
		CreatedBy)
	VALUES (@CompanyId,
		@InvoiceNumber,
		@CustomerId, 
		@InvoiceDate,
		'P',
		@ItemLine,
		@ItemCode, 
		@TrailerNumber,
		@VendorId,
		@APInvoice,
		@FromDate,
		@ToDate,
		@FreeDays,
		@BillDays1,
		@BillAt1,
		@BillDays2,
		@BillAt2,
		@BillDays3,
		@BillAt3,
		@OwnerName,
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