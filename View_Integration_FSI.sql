/*
SELECT * FROM View_Integration_FSI WHERE InvoiceNumber = '95-210992-1'
*/
ALTER VIEW [dbo].[View_Integration_FSI]
AS
SELECT	FSI_ReceivedHeaderId, 
		FH.Company, 
		WeekEndDate, 
		FH.ReceivedOn, 
		TotalTransactions, 
		TotalSales, 
		TotalVendorAccrual, 
		TotalTruckAccrual, 
		FSI_ReceivedDetailId, 
		FD.BatchId, 
		DetailId,
		VoucherNumber,
		InvoiceNumber, 
		InvoiceNumber AS Original_InvoiceNumber,
		CustomerNumber, 
		ApplyTo, 
		BillToRef, 
		InvoiceDate, 
		DeliveryDate, 
		DueDate, 
		AccessorialTotal, 
		VendorPayTotal, 
		FuelSurcharge, 
		FuelRebateTotal, 
		InvoiceTotal, 
		DocumentType, 
		ShipperName, 
		ShipperCity, 
		ConsigneeName, 
		ConsigneeCity, 
		BrokeredSale, 
		TruckAccrualTotal, 
		CompanyTruckAccrual, 
		CompanyTruckDivision, 
		CompanyTruckFuelRebate, 
		CompanyDriverPay, 
		InvoiceType, 
		Division, 
		RatingTable, 
		Verification, 
		ISNULL(RI.Status, FD.Processed) AS Processed,
		FD.Processed AS DetailProcessed,
		FH.Status,
		Intercompany,
		RecordStatus,
		Emailed,
		Agent,
		FD.Equipment,
		RTRIM(FD.Equipment) + ISNULL(FD.CheckDigit,'') AS EquipmentNumber,
		'FSIAR' + CONVERT(Varchar, FH.ReceivedOn, 12) + REPLACE(CONVERT(Char(5), FH.ReceivedOn, 8), ':', '') AS SummaryBatch,
		CASE WHEN PrePayType NOT IN ('A','P') THEN Null ELSE PrePayType END AS PrePayType,
		ICB,
		ComponentBill = CAST(IIF(ISNUMERIC(RIGHT(InvoiceNumber, 1)) = 1 AND SUBSTRING(InvoiceNumber, LEN(InvoiceNumber) - 1, 1) = '-', 1, 0) AS Bit)
FROM    FSI_ReceivedDetails FD WITH (NOLOCK)
		INNER JOIN FSI_ReceivedHeader FH WITH (NOLOCK) ON FD.BatchID = FH.BatchId
		LEFT JOIN ReceivedIntegrations RI WITH (NOLOCK) ON FD.BatchID = RI.BatchID AND FH.Company = RI.Company AND RI.Integration = 'FSI'
WHERE	FD.Intercompany = 0
GO


