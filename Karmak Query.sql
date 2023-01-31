-- SELECT * FROM View_SalesOrders WHERE InvoiceNumber BETWEEN '5601' AND '5629'
--SELECT * FROM DirectorSeries.dbo.RepairInvoiceDetailHistory WHERE RepairInvoiceHistoryId = 4559
CREATE PROCEDURE USP_FindKarmakSalesOrders
		@BatchId	Varchar(25),
		@Range1		Varchar(10),
		@Range2		Varchar(10)
AS
SELECT	InvoiceNumber, 
		InvoicedDate, 
		CustomerNumber, 
		UnitNumber, 
		Labor, 
		Fuel_Price, 
		Tires_Price, 
		Misc_Price, 
		Parts_Price, 
		Shop_Price, 
		Fees_Price, 
		OrderTax, 
		InvoiceTotal, 
		Labor + Tires_Price + Parts_Price + Shop_Price + Fees_Price + OrderTax + Misc_Price + Fuel_Price AS Total 
FROM	View_SalesOrders 
WHERE	InvoiceTotal <> 0 
		AND Voided = 0 
		AND InvoiceNumber BETWEEN @Range1 AND @Range2
ORDER BY InvoiceNumber