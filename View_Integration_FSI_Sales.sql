USE [Integrations]
GO

/****** Object:  View [dbo].[View_Integration_FSI_Sales]    Script Date: 1/4/2023 10:35:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
SELECT * FROM View_Integration_FSI_Sales WHERE BatchId = '9FSI20210629_1201'
*/
ALTER VIEW [dbo].[View_Integration_FSI_Sales]
AS
SELECT	FSI_ReceivedHeaderId, 
		FH.Company, 
		FH.WeekEndDate, 
		FH.ReceivedOn, 
		TotalTransactions, 
		TotalSales, 
		TotalVendorAccrual, 
		TotalTruckAccrual, 
		FSI_ReceivedDetailId, 
		FD.BatchId, 
		FD.DetailId,
		FD.VoucherNumber,
		FD.InvoiceNumber, 
		FD.InvoiceNumber AS Original_InvoiceNumber,
		FD.CustomerNumber, 
		FD.ApplyTo, 
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
		FD.Verification, 
		ISNULL(RI.Status, FD.Processed) AS Processed,
		FD.Processed AS DetailProcessed,
		FH.Status,
		Intercompany,
		RecordStatus,
		Agent,
		FD.Equipment,
		RTRIM(FD.Equipment) + ISNULL(FD.CheckDigit,'') AS EquipmentNumber,
		'FSIAR' + CONVERT(Varchar, FH.ReceivedOn, 12) + REPLACE(CONVERT(Char(5), FH.ReceivedOn, 8), ':', '') AS SummaryBatch,
		CASE WHEN FD.PrePayType NOT IN ('A','P') THEN Null ELSE FD.PrePayType END AS PrePayType,
		FD.ICB
FROM    FSI_ReceivedDetails FD WITH (NOLOCK)
		INNER JOIN FSI_ReceivedHeader FH WITH (NOLOCK) ON FD.BatchID = FH.BatchId
		LEFT JOIN ReceivedIntegrations RI WITH (NOLOCK) ON FD.BatchID = RI.BatchID AND FH.Company = RI.Company AND RI.Integration = 'FSI'


GO


