USE [ILS_Data]
GO

/****** Object:  View [dbo].[View_SalesOrders]    Script Date: 11/2/2022 9:20:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
SELECT * FROM View_SalesOrders WHERE InvoicedDate > '12/01/2021' AND VoidInvoiceDate IS Null
InvoiceNumber = 22108
*/
ALTER VIEW [dbo].[View_SalesOrders]
AS
SELECT	InvoiceNumber, 
		OrderId, 
		RepairOrderNumber, 
		InvoicedDate, 
		Voided,
		VoidInvoiceDate,
		TaxStatus,
		CustomerNumber,
		CompanyName,
		CustPO,
		UnitNumber,
		VinNumber,
		Year,
		MeterReading,
		OrderTax,
		Labor,
		Fuel_Price,
		Fuel_Cost,
		Misc_Price,
		Misc_Cost,
		Tires_Price,
		Tires_Cost,
		Parts_Price,
		Parts_Cost,
		Shop_Price,
		Shop_Cost,
		Fees_Price,
		Fees_Price_All,
		Fees_Cost,
		Package,
		InvoiceTotal,
		RepairInvoiceHistoryId,
		IsClaim,
		CASE WHEN AmntMR > 0 AND AmntTires > 0 AND AmntPeopleNet > 0 THEN 'MTP' 
			 WHEN AmntMR > 0 AND AmntTires > 0 AND AmntPeopleNet = 0 THEN 'MT' 
			 WHEN AmntMR > 0 AND AmntTires = 0 AND AmntPeopleNet > 0 THEN 'MP' 
			 WHEN AmntMR > 0 AND AmntTires = 0 AND AmntPeopleNet = 0 THEN 'M' 
			 WHEN AmntMR = 0 AND AmntTires > 0 AND AmntPeopleNet = 0 THEN 'T'
			 WHEN AmntMR = 0 AND AmntTires = 0 AND AmntPeopleNet > 0 THEN 'P'
			 WHEN AmntMR = 0 AND AmntTires > 0 AND AmntPeopleNet > 0 THEN 'TP'
		ELSE 'M' END AS ServiceTypes,
		CASE WHEN AmntMR > 0 AND AmntTires > 0 AND AmntPeopleNet > 0 THEN 3
			 WHEN AmntMR > 0 AND AmntTires > 0 AND AmntPeopleNet = 0 THEN 2
			 WHEN AmntMR > 0 AND AmntTires = 0 AND AmntPeopleNet > 0 THEN 2
			 WHEN AmntMR > 0 AND AmntTires = 0 AND AmntPeopleNet = 0 THEN 1
			 WHEN AmntMR = 0 AND AmntTires > 0 AND AmntPeopleNet = 0 THEN 1
			 WHEN AmntMR = 0 AND AmntTires = 0 AND AmntPeopleNet > 0 THEN 1
			 WHEN AmntMR = 0 AND AmntTires > 0 AND AmntPeopleNet > 0 THEN 2
		ELSE 1 END AS NumberOfServices,
		TaxRate,
		ROUND(AmntMR * ((TaxRate / 100) + 1), 2) AS AmntMR,
		ROUND(AmntTires * ((TaxRate / 100) + 1), 2) AS AmntTires,
		ROUND(AmntPeopleNet * ((TaxRate / 100) + 1), 2) AS AmntPeopleNet,
		DescPeopleNet,
		DescTires,
		DescMR,
		ISNULL(RTRIM(DescMR) + ' ','') + ISNULL(RTRIM(DescTires) + ' ','') + ISNULL(RTRIM(DescPeopleNet),'') AS InvoiceServices
FROM	(SELECT	RIH.InvoiceNumber, 
				RIH.OrderId, 
				RIH.RepairOrderNumber, 
				RIH.InvoicedDate, 
				CAST(CASE WHEN RIH.VoidInvoiceDate IS Null THEN 0 ELSE 1 END AS Bit) AS Voided,
				RIH.VoidInvoiceDate,
				RIH.TaxStatus,
				RIH.CustomerNumber,
				RIH.CompanyName,
				RIH.CustomerPurchaseOrderNumber AS CustPO,
				RIH.UnitNumber,
				RIH.VinNumber,
				RIH.Year,
				RIH.MeterReading,
				OrderTax = ISNULL((SELECT SalesTaxTotal FROM DirectorSeries.dbo.RepairOrder ROR WHERE ROR.RepairOrderID = RIH.OrderID),0),
				Labor = ISNULL((SELECT SUM(LDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceLaborDetailHistory LDH WHERE LDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId),0),
				Fuel_Price = ISNULL((SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber = 'FUEL'),0),
				Fuel_Cost = ISNULL((SELECT SUM(RDH.ExtendedCost) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber = 'FUEL'),0),
				Misc_Price = ISNULL((SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber = 'OUTSIDE VENDOR' AND RDH.PartDescription NOT LIKE '%TIRE%'),0),
				Misc_Cost = ISNULL((SELECT SUM(RDH.ExtendedCost) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber = 'OUTSIDE VENDOR' AND RDH.PartDescription NOT LIKE '%TIRE%'),0),
				Tires_Price = ISNULL((SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH INNER JOIN View_Parts VPA ON RDH.PartNumber = VPA.PartNumber WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND (VPA.ProductKey = 'TIRES' OR RDH.PartDescription LIKE '%TIRE%')),0),
				Tires_Cost = ISNULL((SELECT SUM(RDH.Cost) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH INNER JOIN View_Parts VPA ON RDH.PartNumber = VPA.PartNumber WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND (VPA.ProductKey = 'TIRES' OR RDH.PartDescription LIKE '%TIRE%')),0),
				Parts_Price = ISNULL((SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH INNER JOIN View_Parts VPA ON RDH.PartNumber = VPA.PartNumber AND RDH.SupplierId = VPA.SupplierId WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND VPA.ProductKey <> 'TIRES' AND RDH.PartNumber NOT IN ('MONTHLYMAINT','MONTHLY PARKING','TRUCK WASH O/O') AND RDH.TransactionType = 'P'),0),
				Parts_Cost = ISNULL((SELECT SUM(ISNULL(VPA.Cost, RDH.Cost)) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH INNER JOIN View_Parts VPA ON RDH.PartNumber = VPA.PartNumber AND RDH.SupplierId = VPA.SupplierId WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND VPA.ProductKey <> 'TIRES' AND RDH.PartNumber NOT IN ('MONTHLYMAINT','MONTHLY PARKING','TRUCK WASH O/O') AND RDH.TransactionType = 'P'),0),
				Shop_Price = ISNULL((SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH INNER JOIN View_Parts VPA ON RDH.PartNumber = VPA.PartNumber WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND VPA.ProductKey <> 'TIRES' AND RDH.PartNumber NOT IN ('MONTHLYMAINT','MONTHLY PARKING','TRUCK WASH O/O') AND RDH.TransactionType = 'S'),0),
				Shop_Cost = ISNULL((SELECT SUM(VPA.Cost) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH INNER JOIN View_Parts VPA ON RDH.PartNumber = VPA.PartNumber WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND VPA.ProductKey <> 'TIRES' AND RDH.PartNumber NOT IN ('MONTHLYMAINT','MONTHLY PARKING','TRUCK WASH O/O') AND RDH.TransactionType = 'S'),0),
				Fees_Price = ISNULL((SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber IN ('MONTHLYMAINT','MONTHLY PARKING','TRUCK WASH O/O','EPA Charge')),0),
				Fees_Price_All = ISNULL((SELECT SUM(RDH.ExtendedPrice) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId),0),
				Fees_Cost = ISNULL((SELECT SUM(RDH.ExtendedCost) FROM DirectorSeries.dbo.RepairInvoiceDetailHistory RDH WHERE RDH.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RDH.PartNumber IN ('MONTHLYMAINT','MONTHLY PARKING','TRUCK WASH O/O','EPA Charge')),0),
				Package = ISNULL((SELECT SUM(ROO.FlatPartsAmount) FROM DirectorSeries.dbo.RepairOrderOperation ROO WHERE ROO.RepairOrderID = RIH.OrderID),0),
				RIH.InvoiceTotal,
				RIH.RepairInvoiceHistoryId,
				CASE WHEN EXISTS(SELECT ROO.RepairCode FROM DirectorSeries.dbo.RepairInvoiceOperationHistory ROO WHERE ROO.RepairInvoiceHistoryId = RIH.RepairInvoiceHistoryId AND RepairCode = 'CLAIM') THEN 1 ELSE 0 END AS IsClaim,
				AmntPeopleNet = ISNULL(dbo.FindRepairAmount(RIH.RepairInvoiceHistoryId, 'P'), 0),
				AmntTires = ISNULL(dbo.FindRepairAmount(RIH.RepairInvoiceHistoryId, 'T'), 0),
				AmntMR = ISNULL(dbo.FindRepairAmount(RIH.RepairInvoiceHistoryId, 'M'), 0),
				DescPeopleNet = dbo.FindServices(RIH.RepairInvoiceHistoryId, 'P'),
				DescTires = dbo.FindServices(RIH.RepairInvoiceHistoryId, 'T'),
				DescMR = dbo.FindServices(RIH.RepairInvoiceHistoryId, 'M'),
				TaxRate = (SELECT Rate FROM DirectorSeries.dbo.TaxRate WHERE TaxRateID = 1),
				CAST(CASE WHEN RIH.CustomerNumber = 'CONTMAINT' THEN 1 ELSE 0 END AS Bit) AS IsContractMaintenance
		FROM	DirectorSeries.dbo.RepairInvoiceHistory RIH) RECS

/*
SELECT distinct InvoiceNumber FROM View_SalesOrders WHERE InvoicedDate > '01/01/2015'
InvoiceNumber = 22108

SELECT * FROM DirectorSeries.dbo.RepairInvoiceHistory WHERE OrderId = 5522

SELECT * FROM View_SalesOrders WHERE OrderId = 5445
SELECT * FROM DirectorSeries.dbo.RepairInvoiceLaborDetailHistory WHERE RepairInvoiceHistoryId IN (SELECT RepairInvoiceHistoryId FROM DirectorSeries.dbo.RepairInvoiceHistory WHERE OrderId = 5445)
SELECT * FROM DirectorSeries.dbo.RepairInvoiceOperationHistory WHERE RepairInvoiceHistoryId IN (SELECT RepairInvoiceHistoryId FROM DirectorSeries.dbo.RepairInvoiceHistory WHERE OrderId = 5445)
SELECT * FROM DirectorSeries.dbo.RepairInvoiceDetailHistory WHERE RepairInvoiceHistoryId IN (SELECT RepairInvoiceHistoryId FROM DirectorSeries.dbo.RepairInvoiceHistory WHERE OrderId = 5445)

SELECT	ExtendedPrice AS Amount 
				FROM	DirectorSeries.dbo.RepairInvoiceLaborDetailHistory
				WHERE	RepairInvoiceOperationHistoryId IN (SELECT	RepairInvoiceOperationHistoryId
													FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory
													WHERE	RepairOrderNumber = 5390
															AND RepairCode IN ('INSTALL','PEOPLNET','REMOVAL'))
				UNION
				SELECT	ExtendedPrice AS Amount 
				FROM	DirectorSeries.dbo.RepairInvoiceDetailHistory
				WHERE	RepairInvoiceOperationHistoryId IN (SELECT	RepairInvoiceOperationHistoryId
													FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory
													WHERE	RepairOrderNumber = 5390
															AND RepairCode IN ('INSTALL','PEOPLNET','REMOVAL'))
*/

GO