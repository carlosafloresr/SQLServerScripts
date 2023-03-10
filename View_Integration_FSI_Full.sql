/*
SELECT	*
FROM	View_Integration_FSI_Full
WHERE	BatchId = '9FSI20210709_1551'
*/
ALTER VIEW [dbo].[View_Integration_FSI_Full]
AS
SELECT	FSI_ReceivedHeaderId, 
		DT.Company, 
		WeekEndDate, 
		ReceivedOn,
		TotalTransactions, 
		TotalSales, 
		TotalVendorAccrual, 
		TotalTruckAccrual, 
		FSI_ReceivedDetailId, 
		BatchId, 
		CASE WHEN dbo.AT('SUM', BatchId, 1) = 0 THEN DetailId ELSE 1 END AS DetailId,
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
		Processed,
		[Status],
		RecordType, 
		RecordCode,
		Reference, 
		ChargeAmount1, 
		ChargeAmount2, 
		ReferenceCode, 
		SubVerification,
		SubProcessed,
		Intercompany,
		VndIntercompany,
		GPBatchId,
		CASE WHEN VendorDocument = Equipment THEN CAST(FSI_ReceivedSubDetailId AS Varchar) 
			 WHEN RecordType = 'ACC' THEN Equipment
			 ELSE VendorDocument END AS VendorDocument,
		VendorReference,
		Agent,
		RecordStatus, 
		Imaged, 
		Printed, 
		Emailed,
		Equipment,
		PrePay,
		PrePayType,
		AR_PrePayType,
		ISNULL(AccCode, RecordCode) AS AccCode,
		CAST(CASE WHEN dbo.AT('SUM', BatchId, 1) = 0 THEN 0 ELSE 1 END AS Bit) AS IsSummary,
		FSI_ReceivedSubDetailId,
		ICB_AR,
		ICB_AP,
		PerDiemType,
		'' AS GLAccount,
		LEFT(CASE WHEN Company = 'GLSO' THEN InvoiceNumber + '|' + VendorDocument ELSE Equipment + '|' + InvoiceNumber END, 30) AS PrepayReference,
		--IIF(DT.Company = 'GLSO', REPLACE(RTRIM(InvoiceNumber), '  ', ' ') + '|' + RTRIM(VendorDocument), REPLACE(RTRIM(Equipment), '  ', ' ') + '|' + RTRIM(InvoiceNumber)) AS PrepayReference,
		PierPassType,
		DemurrageAdminFee,
		SWSRecordId,
		ExternalId
FROM	(
		SELECT	FSI_ReceivedHeaderId, 
				FH.Company, 
				WeekEndDate, 
				ReceivedOn,
				TotalTransactions, 
				TotalSales, 
				TotalVendorAccrual, 
				TotalTruckAccrual, 
				FSI_ReceivedDetailId, 
				FD.BatchId, 
				FD.DetailId,
				FD.VoucherNumber,
				InvoiceNumber, 
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
				ISNULL(TruckAccrualTotal, 0.0) AS TruckAccrualTotal, 
				ISNULL(CompanyTruckAccrual, 0.0) AS CompanyTruckAccrual, 
				ISNULL(CompanyTruckDivision, '') AS CompanyTruckDivision,
				ISNULL(CompanyTruckFuelRebate, 0.0) AS CompanyTruckFuelRebate,
				ISNULL(CompanyDriverPay, 0.0) AS CompanyDriverPay,
				InvoiceType, 
				Division, 
				RatingTable, 
				FD.Verification, 
				FD.Processed,
				FH.Status,
				ISNULL(RecordType, 'NONE') AS RecordType, 
				ISNULL(RecordCode, 'NONE') AS RecordCode,
				Reference, 
				ChargeAmount1, 
				ChargeAmount2, 
				ReferenceCode, 
				FD.Verification AS SubVerification,
				FS.Processed AS SubProcessed,
				FD.Intercompany,
				FS.VndIntercompany,
				LEFT('FSIAR' + REPLACE(dbo.FormatDateYMD(ReceivedOn, 1, 1, 1), '_', ''), 30) AS GPBatchId,
				CASE WHEN FD.InvoiceType IN ('C','D') AND FS.VendorDocument IS NOT Null AND FS.VendorDocument <> '' THEN FS.VendorDocument
				WHEN FD.InvoiceType IN ('C','D') AND (FS.VendorDocument IS Null OR FS.VendorDocument = '') THEN InvoiceNumber ELSE
				RTRIM(LEFT(CASE WHEN VendorDocument IS NOT Null THEN CASE WHEN RTRIM(VendorDocument) = RTRIM(FD.Equipment) THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1) ELSE RTRIM(VendorDocument) END
						WHEN Equipment IS NOT Null THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1)
						WHEN (LEN(RTRIM(ISNULL(FD.Equipment,''))) = 10 OR ISNULL(FD.Equipment,'') = 'FLATBED') AND ISNULL(FD.Equipment,'') <> VendorDocument THEN RTRIM(ISNULL(LEFT(FD.Equipment, 10),'')) + dbo.PADL(RIGHT(CAST(FSI_ReceivedSubDetailId AS Varchar), 7), 9, '0')
						ELSE CASE WHEN RTRIM(VendorDocument) = '' THEN CAST(FSI_ReceivedSubDetailId AS Varchar) ELSE RTRIM(VendorDocument) END + dbo.PADL(RIGHT(CAST(FSI_ReceivedSubDetailId AS Varchar), 7), 9, '0')
					END, 20)) END AS VendorDocument,
				VendorReference,
				Agent,
				FD.RecordStatus, 
				FD.Imaged, 
				FD.Printed, 
				FD.Emailed,
				FD.Equipment,
				RTRIM(FD.Equipment) + ISNULL(FD.CheckDigit,'') AS EquipmentNumber,
				FS.PrePay,
				IIF(FS.PrePayType IN ('A','P'), FS.PrePayType, Null) AS PrePayType,
				ISNULL(IIF(FD.PrePayType IN ('A','P'), FD.PrePayType, Null),'') AS AR_PrePayType,
				FS.AccCode,
				FSI_ReceivedSubDetailId,
				FD.ICB AS ICB_AR,
				FS.ICB AS ICB_AP,
				CAST(CASE WHEN FS.RecordType IN ('ACC','VND') AND FS.AccCode = PAR.VarC AND VND.VendorId IS Null THEN 1 ELSE 0 END AS Bit) AS PerDiemType,
				PierPassType = CAST(IIF(VND.VendorId IS Null, 0, 1) AS Bit),
				FS.DemurrageAdminFee,
				FS.SWSRecordId,
				FS.ExternalId
				--CAST(0 AS Bit) AS PerDiemType
		FROM    FSI_ReceivedDetails FD WITH (NOLOCK)
				INNER JOIN FSI_ReceivedHeader FH WITH (NOLOCK) ON FD.BatchID = FH.BatchId
				INNER JOIN PRISQL01P.GPCustom.dbo.Parameters PAR ON PAR.Company = 'ALL' AND PAR.ParameterCode = 'PRD_ACCESSORAILCODE'
				LEFT JOIN FSI_ReceivedSubDetails FS WITH (NOLOCK) ON FD.BatchID = FS.BatchId AND FD.DetailId = FS.DetailId --AND FS.RecordType = 'VND'
				LEFT JOIN PRISQL01P.GPCustom.dbo.GPVendorMaster VND WITH (NOLOCK) ON FH.Company = VND.Company AND FS.RecordCode = VND.VendorId AND VND.PierPassType = 1
		) DT
		--LEFT JOIN FSI_SpecialCustomers SC ON DT.Company = SC.Company AND DT.CustomerNumber = SC.CustomerId
GO
