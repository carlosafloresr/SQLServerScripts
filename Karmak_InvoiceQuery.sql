DECLARE	@RepairOrderNumber		Int,
		@RepairInvoiceHistoryId	Int,
		@CustomerId				Int,
		@InvoiceNumber			Int,
		@OrderId				Int

SET		@InvoiceNumber			= 5631

SELECT	@OrderId				= OrderId,
		@RepairOrderNumber		= RepairOrderNumber,
		@RepairInvoiceHistoryId	= RepairInvoiceHistoryId
FROM	DirectorSeries.dbo.RepairInvoiceHistory 
WHERE	InvoiceNumber			= @InvoiceNumber

--SELECT	@CustomerId		= CustomerId
--FROM	RepairOrder 
--WHERE	RepairOrderNumber = @RepairOrderNumber
-- SELECT * FROM View_Parts WHERE PartNumber = '3539166C2'

-- select PartNumber from DirectorSeries.dbo.PartsInventory ORDER BY PartNumber WHERE PartNumber = '3539166C2'
-- select * from DirectorSeries.dbo.PartsInventory WHERE PartNumber = '3539166C2'
-- select PartNumber, count(PartNumber) as counter from DirectorSeries.dbo.PartsInventory group by PartNumber having count(PartNumber) > 1 ORDER BY PartNumber WHERE PartNumber = '3539166C2'
-- select * from DirectorSeries.dbo.ProductLine

SELECT	RIH.InvoiceNumber, 
		RIH.OrderId, 
		RIH.RepairOrderNumber, 
		RIH.InvoicedDate, 
		RIH.InvoiceTotal, 
		RIH.VoidInvoiceDate,
		RIH.TaxStatus,
		RIH.CustomerNumber,
		RIH.CompanyName,
		RIH.CustomerPurchaseOrderNumber AS CustPO,
		RIH.UnitNumber,
		RIH.VinNumber,
		RIH.Year,
		RIH.MeterReading,
		OrderTax = (SELECT SalesTaxTotal FROM DirectorSeries.dbo.RepairOrder ROR WHERE ROR.RepairOrderID = RIH.OrderID),
		Labor = (SELECT SUM(LDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceLaborDetailHistory LDH WHERE LDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId),
		Fuel_Price = (SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber = 'FUEL'),
		Fuel_Cost = (SELECT SUM(RDH.ExtendedCost) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber = 'FUEL'),
		Misc_Price = (SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber = 'OUTSIDE VENDOR'),
		Misc_Cost = (SELECT SUM(RDH.ExtendedCost) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber = 'OUTSIDE VENDOR'),
		Tires_Price = (SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH INNER JOIN View_Parts VPA ON RDH.PartNumber = VPA.PartNumber WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND VPA.ProductKey = 'TIRES'),
		Tires_Cost = (SELECT SUM(RDH.ExtendedCost) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH INNER JOIN View_Parts VPA ON RDH.PartNumber = VPA.PartNumber WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND VPA.ProductKey = 'TIRES'),
		Parts_Price = (SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH INNER JOIN View_Parts VPA ON RDH.PartNumber = VPA.PartNumber AND RDH.SupplierId = VPA.SupplierId WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND VPA.ProductKey <> 'TIRES' AND RDH.PartNumber NOT IN ('MONTHLYMAINT','MONTHLY PARKING','TRUCK WASH O/O') AND RDH.TransactionType = 'P'),
		Parts_Cost = (SELECT SUM(RDH.ExtendedCost) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH INNER JOIN View_Parts VPA ON RDH.PartNumber = VPA.PartNumber AND RDH.SupplierId = VPA.SupplierId WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND VPA.ProductKey <> 'TIRES' AND RDH.PartNumber NOT IN ('MONTHLYMAINT','MONTHLY PARKING','TRUCK WASH O/O') AND RDH.TransactionType = 'P'),
		Fees_Price = (SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber IN ('MONTHLYMAINT','MONTHLY PARKING','TRUCK WASH O/O','EPA Charge')),
		Fees_Cost = (SELECT SUM(RDH.ExtendedCost) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber IN ('MONTHLYMAINT','MONTHLY PARKING','TRUCK WASH O/O','EPA Charge')),
		Package = (SELECT SUM(ROO.FlatPartsAmount) FROM DirectorSeries.dbo.RepairOrderOperation ROO WHERE ROO.RepairOrderID = RIH.OrderID)
FROM	DirectorSeries.dbo.RepairInvoiceHistory RIH
WHERE	RIH.RepairOrderNumber = @RepairOrderNumber

-- SELECT * FROM View_Parts order by productkey
-- SELECT * FROM Customer WHERE CustomerId = @CustomerId
-- SELECT * FROM DirectorSeries.dbo.RepairInvoiceHistory WHERE RepairOrderNumber = @RepairOrderNumber
 
SELECT * 
FROM	DirectorSeries.dbo.RepairInvoiceDetailHistory RDH 
		INNER JOIN View_Parts VPA ON RDH.PartNumber = VPA.PartNumber AND RDH.SupplierId = VPA.SupplierId
WHERE	RDH.RepairInvoiceHistoryId = @RepairInvoiceHistoryId 
		AND VPA.ProductKey <> 'TIRES' 
		AND RDH.PartNumber NOT IN ('MONTHLYMAINT','MONTHLY PARKING','TRUCK WASH O/O') 
		AND RDH.TransactionType = 'P'

--SELECT * FROM DirectorSeries.dbo.RepairInvoiceDetailHistory WHERE RepairInvoiceHistoryId = @RepairInvoiceHistoryId
SELECT * FROM DirectorSeries.dbo.RepairOrder WHERE RepairOrderID = @OrderID
--SELECT * FROM DirectorSeries.dbo.RepairOrderDetail WHERE RepairOrderID = @OrderID
--SELECT * FROM DirectorSeries.dbo.RepairInvoiceLaborDetailHistory WHERE RepairInvoiceHistoryId = @RepairInvoiceHistoryId
--SELECT * FROM DirectorSeries.dbo.RepairOrderOperation WHERE RepairOrderID = @OrderID
--SELECT * FROM DirectorSeries.dbo.RepairInvoiceOperationHistory WHERE RepairOrderNumber = @RepairOrderNumber

/*
SELECT * FROM RepairOrder WHERE RepairOrderNumber = @RepairOrderNumber
SELECT * FROM RepairInvoiceHistory WHERE  = 4443
SELECT * FROM RepairOrderDetail WHERE RepairOrderId IN (SELECT RepairOrderId FROM RepairOrder WHERE RepairOrderNumber = 5456)
*/
