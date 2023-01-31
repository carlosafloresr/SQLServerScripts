DECLARE @Company				Varchar(5) = 'OIS',
		@CustomerId				Varchar(30),
		@CustomerNumber			Varchar(30),
		@EnterpriseId			Int

DECLARE	@tblStatementTemp		Table (
		DocNumber				Varchar(30),
		DocDate					Date,
		DueDate					Date,
		Code					Varchar(10),
		Invoice					Varchar(30),
		InvoiceRemaining		Varchar(30),
		Balance					Varchar(30),
		EquipmentNo				Varchar(20),
		PurchaseOrderNum		Varchar(30),
		TransactionDescription	Varchar(50))

DECLARE	@tblStatementData		Table (
		Company					Varchar(5),
		CustomerId				Varchar(30),
		DocNumber				Varchar(30),
		DocDate					Date,
		DueDate					Date,
		Code					Varchar(10),
		Invoice					Varchar(30),
		InvoiceRemaining		Varchar(30),
		Balance					Varchar(30),
		EquipmentNo				Varchar(20),
		PurchaseOrderNum		Varchar(30),
		TransactionDescription	Varchar(50))

SET @EnterpriseId = (SELECT EnterpriseId FROM CollectIT.dbo.CS_Enterprise WHERE EnterpriseNumber = @Company)

DECLARE curGPCustomers CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT CustomerId, CustomerNumber
FROM	CollectIT.dbo.CS_Invoice
		LEFT JOIN CollectIT.dbo.UF_Invoice ON UF_Invoice.InvoiceId = CS_Invoice.InvoiceId
WHERE	EnterpriseId = @EnterpriseId
		AND PaymentStatus = 2

OPEN curGPCustomers 
FETCH FROM curGPCustomers INTO @CustomerId, @CustomerNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	INSERT INTO @tblStatementTemp
	EXECUTE CollectIT.dbo.GetCustomerStatementDetailsByNumber @CustomerId

	INSERT INTO @tblStatementData
	SELECT	@Company,
			@CustomerNumber,
			DocNumber,
			DocDate,
			DueDate,
			Code,
			Invoice,
			InvoiceRemaining,
			Balance,
			ISNULL(EquipmentNo, ''),
			PurchaseOrderNum,
			TransactionDescription
	FROM	@tblStatementTemp

	DELETE @tblStatementTemp

	FETCH FROM curGPCustomers INTO @CustomerId, @CustomerNumber
END

CLOSE curGPCustomers
DEALLOCATE curGPCustomers

SELECT	*
FROM	@tblStatementData
ORDER BY Company, CustomerId, DueDate, DocNumber