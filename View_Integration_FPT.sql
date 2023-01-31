ALTER VIEW View_Integration_FPT
AS
SELECT	Company, 
	RD.BatchId,
	FPT_ReceivedHeaderId, 
	WeekEndDate, 
	ReceivedOn, 
	TotalTransactions, 
	TotalInvoices, 
	Status
	FPT_ReceivedDetailId,
	TransDate,
	VendorId, 
	FuelAmount, 
	AdditiveAmount, 
	OilAmount, 
	SalesTax, 
	Fees, 
	Discount, 
	Cash, 
	InvoiceTotal, 
	Balance,
	TotalFuel,
	Verification,
	Processed
FROM	FPT_ReceivedDetails RD
	INNER JOIN FPT_ReceivedHeader RH ON RD.BatchId = RH.BatchId