DECLARE	@SalesInvoiceId	Int = 0,
		@CompanyId		Varchar(5),
		@InvoiceNumber	Varchar(15), 
		@CustomerId		Varchar(10), 
		@InvoiceDate	Smalldatetime,
		@ItemLine		Int,
		@ItemCode		Varchar(15), 
		@TrailerNumber	Varchar(15) = Null,
		@VendorId		Varchar(10) = Null,
		@APInvoice		Varchar(15) = Null, 
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
		@UserId			Varchar(25),
		@Notes1			Varchar(65) = Null,
		@Notes2			Varchar(65) = Null,
		@Notes3			Varchar(65) = Null,
		@Notes4			Varchar(65) = Null,
		@Notes5			Varchar(65) = Null,
		@ProNumber		Varchar(15) = Null,
		@ChassisNumber	Varchar(15) = Null

DECLARE curSOPData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	0,
		Company,
		SOPNumbe,
		CustNmbr,
		DocDate,
		16384,
		'DM',
		ProNumber,
		VendorId,
		InvoiceNumber,
		InDate,
		OutDate,
		Container,
		FreeTime,
		Null,
		Null,
		VendorName,
		'Pro Number: ' + ProNumber,
		'Reference Number: ' + DistRef,
		Chassis,
		'ILS_INTEGRATION'
FROM	ILSINT02.Integrations.dbo.Integrations_SOP
WHERE	SOPNUMBE IN ('DM-G5257','DM-G5439')
		AND PopUpId > 0

OPEN curSOPData 
FETCH FROM curSOPData INTO @SalesInvoiceId, @CompanyId, @InvoiceNumber, @CustomerId, @InvoiceDate, @ItemLine, @ItemCode, @ProNumber, @VendorId, @APInvoice,
							@FromDate, @ToDate, @TrailerNumber, @FreeDays, @BillDays1, @BillAt1, @OwnerName, @Notes1, @Notes2, @ChassisNumber, @UserId

WHILE @@FETCH_STATUS = 0 
BEGIN
	--EXECUTE USP_SalesInvoices_PD

	FETCH FROM curSOPData INTO @SalesInvoiceId, @CompanyId, @InvoiceNumber, @CustomerId, @InvoiceDate, @ItemLine, @ItemCode, @ProNumber, @VendorId, @APInvoice,
							@FromDate, @ToDate, @TrailerNumber, @FreeDays, @BillDays1, @BillAt1, @OwnerName, @Notes1, @Notes2, @ChassisNumber, @UserId
END

CLOSE curSOPData
DEALLOCATE curSOPData
