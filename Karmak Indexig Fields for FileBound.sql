-- SELECT * FROM View_SalesOrders WHERE InvoiceNumber = 49635 -- InvoicedDate > '12/01/2021' AND VoidInvoiceDate IS Null

DECLARE @tblKarmak		Table (
	InvoiceNumber		Int,
	RepairOrderNumber	Int,
	InvoicedDate		Date,
	CustomerNumber		Varchar(25),
	CustPO				Varchar(30),
	UnitNumber			Varchar(15),
	VinNumber			Varchar(30),
	Year				Int,
	IsClaim				Bit,
	InvoiceServices		Varchar(50),
	NumberOfServices	Smallint,
	TaxStatus			Varchar(15),
	OrderTax			Numeric(10,2),
	TaxRate				Numeric(6,2),
	InvoiceTotal		Numeric(10,2))

SELECT	InvoiceNumber,
		RepairOrderNumber,
		CAST(InvoicedDate AS Date) AS InvoicedDate,
		CustomerNumber,
		CustPO,
		UnitNumber,
		VinNumber,
		Year,
		IsClaim,
		InvoiceServices,
		NumberOfServices,
		TaxStatus,
		OrderTax,
		TaxRate,
		InvoiceTotal
FROM	View_SalesOrders 
WHERE	InvoicedDate > '12/01/2021' 
		AND VoidInvoiceDate IS Null