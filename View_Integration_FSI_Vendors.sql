USE [Integrations]
GO

/****** Object:  View [dbo].[View_Integration_FSI_Vendors]    Script Date: 5/18/2022 8:40:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
SELECT * FROM View_Integration_FSI_Vendors WHERE InvoiceNumber = '95-105465'
SELECT * FROM View_Integration_FSI_Vendors WHERE BatchId = '9FSI20210709_1439'
*/
ALTER VIEW [dbo].[View_Integration_FSI_Vendors]
AS
SELECT	FSI_ReceivedHeaderId, 
		FH.Company, 
		FS.BatchId,
		WeekEndDate, 
		ReceivedOn, 
		TotalTransactions, 
		TotalSales, 
		TotalVendorAccrual, 
		TotalTruckAccrual,
		FSI_ReceivedSubDetailId, 
		FS.DetailId,
		FD.VoucherNumber,
		InvoiceNumber,
		CustomerNumber,
		BillToRef,
		RecordType, 
		RecordCode, 
		Reference, 
		ChargeAmount1, 
		ChargeAmount2, 
		ReferenceCode,
		FS.AccCode,
		FS.Verification,
		FS.Processed,
		ISNULL(FD.Equipment,'') AS Equipment,
		RTRIM(FD.Equipment) + ISNULL(FD.CheckDigit,'') AS EquipmentNumber,
		'FSIP_' + dbo.PADL(FSI_ReceivedSubDetailId, 10, '0') AS VoucherId,
		Division,
		VndIntercompany,
		'PN:' + RTRIM(FD.InvoiceNumber) + '/CNT:' + ISNULL(FD.Equipment,'No Defined') AS TrxDscrn,
		CASE WHEN FS.AccCode = PA.VarC THEN CAST(CO.CompanyNumber AS Varchar) + '-' + FD.InvoiceNumber ELSE
		CASE WHEN FD.InvoiceType IN ('C','D') AND FS.VendorDocument IS NOT Null AND FS.VendorDocument <> '' THEN FS.VendorDocument
			 WHEN FD.InvoiceType IN ('C','D') AND (FS.VendorDocument IS Null OR FS.VendorDocument = '') THEN InvoiceNumber 
			 WHEN FS.VendorDocument = '' THEN CAST(CO.CompanyNumber AS Varchar) + '-' + FD.InvoiceNumber ELSE
		RTRIM(LEFT(CASE WHEN VendorDocument IS NOT Null THEN CASE WHEN RTRIM(VendorDocument) = RTRIM(FD.Equipment) THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1) ELSE RTRIM(VendorDocument) END
						WHEN Equipment IS NOT Null AND Equipment <> '' THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1)
						WHEN (LEN(RTRIM(ISNULL(FD.Equipment,''))) = 10 OR ISNULL(FD.Equipment,'') = 'FLATBED') AND ISNULL(FD.Equipment,'') <> VendorDocument THEN RTRIM(ISNULL(LEFT(FD.Equipment, 10),'')) + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
						ELSE CASE WHEN RTRIM(VendorDocument) = '' THEN CAST(FSI_ReceivedSubDetailId AS Varchar) ELSE RTRIM(VendorDocument) END + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
					END, 20)) END END AS VendorDocument,
		Agent,
		VendorDocument AS MainVendorDocument,
		FS.VendorDocument AS OriginalVendorDocument,
		CAST(CO.CompanyNumber AS Varchar) + '-' + FD.InvoiceNumber AS NewDocument,
		Null AS SpecialCustomerId,
		FD.InvoiceType,
		PA.VarC AS DemurrageParameter,
		ROW_NUMBER() OVER (PARTITION BY VoucherNumber ORDER BY FSI_ReceivedSubDetailId) AS RowId,
		FS.ExternalId
FROM    FSI_ReceivedSubDetails FS WITH (NOLOCK),
		FSI_ReceivedHeader FH WITH (NOLOCK), 
		FSI_ReceivedDetails FD WITH (NOLOCK),
		PRISQL01P.GPCustom.dbo.Companies CO WITH (NOLOCK),
		PRISQL01P.GPCustom.dbo.Parameters PA WITH (NOLOCK)
WHERE	(FS.BatchId = FH.BatchID
		AND FS.BatchID = FD.BatchId 
		AND FS.DetailId = FD.DetailId
		AND FH.Company = CO.CompanyId
		AND FH.Company = PA.Company
		AND PA.ParameterCode = 'DEMURRAGE_ACCCODE')
		AND FS.RecordType = 'VND' 
		AND FS.PrePay = 0
		AND FS.PrePayType IS Null
		AND FS.VndIntercompany = 0
		AND ISNULL(FS.PerDiemType,0) = 0
		AND FS.AccCode <> PA.VarC
GO


