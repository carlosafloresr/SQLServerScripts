/*
SELECT * FROM View_Integration_FSI_Vendors_Test WHERE InvoiceNumber = '95-199701'
SELECT * FROM View_Integration_FSI_Vendors_Test WHERE BatchId = '9FSI20210709_1439'
*/
ALTER VIEW [dbo].[View_Integration_FSI_Vendors_Test]
AS
SELECT	FSI_ReceivedHeaderId, 
		FH.Company, 
		FS.BatchId,
		FH.WeekEndDate, 
		FH.ReceivedOn, 
		FH.TotalTransactions, 
		FH.TotalSales, 
		FH.TotalVendorAccrual, 
		FH.TotalTruckAccrual,
		FSI_ReceivedSubDetailId, 
		FS.DetailId,
		FD.VoucherNumber,
		FD.InvoiceNumber,
		FD.CustomerNumber,
		FD.BillToRef,
		FS.RecordType, 
		FS.RecordCode, 
		FS.Reference, 
		FS.ChargeAmount1, 
		FS.ChargeAmount2, 
		FS.ReferenceCode,
		FS.AccCode,
		FS.Verification,
		FS.Processed,
		ISNULL(FD.Equipment,'') AS Equipment,
		RTRIM(FD.Equipment) + ISNULL(FD.CheckDigit,'') AS EquipmentNumber,
		'FSIP_' + dbo.PADL(FS.FSI_ReceivedSubDetailId, 10, '0') AS VoucherId,
		FD.Division,
		FS.VndIntercompany,
		'PN:' + RTRIM(FD.InvoiceNumber) + '/CNT:' + ISNULL(FD.Equipment,'No Defined') AS TrxDscrn,
		CASE WHEN FS.AccCode = PA.VarC THEN CAST(CO.CompanyNumber AS Varchar) + '-' + FD.InvoiceNumber ELSE
		CASE WHEN FD.InvoiceType IN ('C','D') AND FS.VendorDocument IS NOT Null AND FS.VendorDocument <> '' THEN FS.VendorDocument
			 WHEN FD.InvoiceType IN ('C','D') AND (FS.VendorDocument IS Null OR FS.VendorDocument = '') THEN InvoiceNumber 
			 WHEN FS.VendorDocument = '' THEN CAST(CO.CompanyNumber AS Varchar) + '-' + FD.InvoiceNumber ELSE
		RTRIM(LEFT(CASE WHEN FS.VendorDocument IS NOT Null THEN CASE WHEN RTRIM(VendorDocument) = RTRIM(FD.Equipment) THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1) ELSE RTRIM(VendorDocument) END
						WHEN FD.Equipment IS NOT Null AND FD.Equipment <> '' THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1)
						WHEN (LEN(RTRIM(ISNULL(FD.Equipment,''))) = 10 OR ISNULL(FD.Equipment,'') = 'FLATBED') AND ISNULL(FD.Equipment,'') <> VendorDocument THEN RTRIM(ISNULL(LEFT(FD.Equipment, 10),'')) + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
						ELSE CASE WHEN RTRIM(VendorDocument) = '' THEN CAST(FSI_ReceivedSubDetailId AS Varchar) ELSE RTRIM(VendorDocument) END + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
					END, 20)) END END AS VendorDocument,
		FH.Agent,
		FS.VendorDocument AS MainVendorDocument,
		FS.VendorDocument AS OriginalVendorDocument,
		CAST(CO.CompanyNumber AS Varchar) + '-' + FD.InvoiceNumber AS NewDocument,
		Null AS SpecialCustomerId,
		FD.InvoiceType,
		PA.VarC AS DemurrageParameter,
		ROW_NUMBER() OVER (PARTITION BY FD.VoucherNumber ORDER BY FS.FSI_ReceivedSubDetailId) AS RowId
FROM    FSI_ReceivedSubDetails FS WITH (NOLOCK)
		INNER JOIN FSI_ReceivedHeader FH WITH (NOLOCK) ON FS.BatchId = FH.BatchId
		INNER JOIN FSI_ReceivedDetails FD WITH (NOLOCK) ON FS.BatchId = FD.BatchId AND FS.DetailId = FD.DetailId
		INNER JOIN PRISQL01P.GPCustom.dbo.Companies CO WITH (NOLOCK) ON FH.Company = CO.CompanyId
		INNER JOIN PRISQL01P.GPCustom.dbo.Parameters PA WITH (NOLOCK) ON FH.Company = PA.Company AND PA.ParameterCode = 'DEMURRAGE_ACCCODE' AND FS.AccCode <> PA.VarC
WHERE	FS.RecordType = 'VND'
		AND FS.PrePay = 0
		AND FS.PrePayType IS Null
		AND FS.VndIntercompany = 0
		AND FS.ChargeAmount1 <> 0
		AND ISNULL(FS.PerDiemType, 0) = 0

/*
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
*/


