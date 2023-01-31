/*
SELECT	* 
FROM	View_Integration_FSI_Sales_Demurrage 
WHERE	BatchId = '9FSI20210629_1201'
*/
ALTER VIEW [dbo].[View_Integration_FSI_Sales_Demurrage]
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
		FD.Processed AS DetailProcessed,
		FH.Status,
		Intercompany,
		RecordStatus,
		Agent,
		FD.Equipment,
		RTRIM(FD.Equipment) + ISNULL(FD.CheckDigit,'') AS EquipmentNumber,
		'FSIAR' + CONVERT(Varchar, FH.ReceivedOn, 12) + REPLACE(CONVERT(Char(5), FH.ReceivedOn, 8), ':', '') AS SummaryBatch,
		CASE WHEN FD.PrePayType NOT IN ('A','P') THEN Null ELSE FD.PrePayType END AS PrePayType,
		FD.ICB,
		CASE WHEN FS.DetailId IS Null THEN 0 ELSE 1 END AS IsDemurrage,
		CASE WHEN FS.DetailId IS Null THEN 0 ELSE FS.ChargeAmount1 END AS DemurrageAmount
FROM    FSI_ReceivedDetails FD
		INNER JOIN FSI_ReceivedHeader FH ON FD.BatchID = FH.BatchId
		LEFT JOIN PRISQL01P.GPCustom.dbo.Parameters PAR ON FH.Company = PAR.Company AND PAR.ParameterCode = 'DEMURRAGE_ACCCODE'
		INNER JOIN FSI_ReceivedSubDetails FS ON FD.BatchId = FS.BatchId AND FD.DetailId = FS.DetailId AND FS.RecordType = 'ACC' AND FS.RecordCode = ISNULL(PAR.VarC,'NONE')
GO


