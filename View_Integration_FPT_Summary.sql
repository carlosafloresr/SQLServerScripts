alter VIEW View_Integration_FPT_Summary
AS
SELECT	Company, 
	RD.BatchId,
	FPT_ReceivedHeaderId, 
	WeekEndDate, 
	ReceivedOn, 
	TotalTransactions, 
	TotalInvoices, 
	Status,
	VendorId, 
	SUM(FuelAmount) AS FuelAmount, 
	SUM(AdditiveAmount) AS AdditiveAmount, 
	SUM(OilAmount) AS OilAmount,
	SUM(SalesTax) AS SalesTax,
	SUM(Fees) AS Fees, 
	SUM(Discount) AS Discount, 
	SUM(Cash) AS Cash,
	SUM(CashFee) AS CashFee,
	SUM(InvoiceTotal) AS InvoiceTotal, 
	SUM(Balance) AS Balance,
	SUM(TotalFuel) AS TotalFuel
FROM	FPT_ReceivedDetails RD
	INNER JOIN FPT_ReceivedHeader RH ON RD.BatchId = RH.BatchId
GROUP BY
	Company, 
	RD.BatchId,
	FPT_ReceivedHeaderId, 
	WeekEndDate, 
	ReceivedOn, 
	TotalTransactions, 
	TotalInvoices, 
	Status,
	VendorId


