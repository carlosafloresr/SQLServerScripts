SELECT	DET.BatchId
		,DET.DetailId
		,DET.VoucherNumber
		,DET.InvoiceNumber
		,DET.CustomerNumber
		,DET.ApplyTo
		,DET.BillToRef
		,DET.InvoiceDate
		,DET.DeliveryDate
		,DET.DueDate
		,DET.AccessorialTotal
		,DET.VendorPayTotal
		,DET.FuelSurcharge
		,DET.FuelRebateTotal
		,DET.InvoiceTotal
		,DET.DocumentType
		,DET.ShipperName
		,DET.ShipperCity
		,DET.ConsigneeName
		,DET.ConsigneeCity
		,DET.BrokeredSale
		,DET.TruckAccrualTotal
		,DET.CompanyTruckAccrual
		,DET.CompanyTruckDivision
		,DET.CompanyTruckFuelRebate
		,DET.CompanyDriverPay
		,DET.InvoiceType
		,DET.Division
		,DET.RatingTable
		,SUB.RecordType
		,SUB.RecordCode
		,SUB.Reference
		,SUB.ChargeAmount1
		,SUB.ChargeAmount2
		,SUB.ReferenceCode
FROM	FSI_ReceivedDetails DET
		INNER JOIN FSI_ReceivedSubDetails SUB ON DET.BatchId = SUB.BatchId AND DET.DetailId = SUB.DetailId
WHERE	InvoiceNumber IN ('4-19056', '07-132259')

