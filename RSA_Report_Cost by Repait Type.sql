SELECT	DIN.Company,
		dbo.PROPER(VNT.Vendor) AS VendorName,
		VEN.Id AS VendorId,
		VNT.State,
		TIC.RepairNumber AS OTRNumber,
		ISNULL(VEN.RepairCompletionDateTime, INV.InvoiceDate) AS RepairCompletionDate,
		INV.InvoiceDate,
		INV.InvoiceNumber,
		COALESCE(INV.EFSNumber, VEN.EFSTransaction, '') AS EFSNumber,
		IND.Repair,
		COF.Name,
		IND.BaseCost
FROM	Tickets TIC
		INNER JOIN VendorInfo VEN ON TIC.Id = VEN.IdRepairNumber
		INNER JOIN DriverInfo DIN ON TIC.id = DIN.IdRepairNumber
		INNER JOIN RSA_VendorsNetwork VNT ON VEN.IdVendor = VNT.RSA_VendorsNetworkId
		INNER JOIN RSA_Invoice INV ON TIC.id = INV.IdRepairNumber AND INV.Historic = 0
		INNER JOIN RSA_InvoiceDetail IND ON INV.id = IND.IdInvoice AND IND.TypeTire IS NOT Null
		INNER JOIN CauseOfFailures COF ON IND.Failure = COF.Id
WHERE	TIC.Active = 1
ORDER BY 
		DIN.Company,
		VNT.Vendor,
		INV.InvoiceDate