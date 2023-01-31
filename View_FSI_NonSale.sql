USE [Integrations]
GO

/****** Object:  View [dbo].[View_FSI_NonSale]    Script Date: 1/26/2023 6:33:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
SELECT	*
FROM	View_FSI_NonSale
WHERE	BatchId = '9FSI20210708_1547' --'9FSI20210629_1201'
		--AND IsDemurrage = 1
*/
ALTER VIEW [dbo].[View_FSI_NonSale]
AS
SELECT	DT.Company, 
		CAST(WeekEndDate AS Date) AS WeekEndDate, 
		BatchId, 
		InvoiceNumber,
		InvoiceDate,
		BillToRef, 
		InvoiceType, 
		Division, 
		RecordCode AS VendorId,
		Amount,
		VndIntercompany,
		CASE WHEN RecordType = 'ACC' THEN Equipment
			 ELSE VendorDocument END AS VendorDocument,
		VendorReference,
		AccCode,
		LEFT(CASE WHEN Company = 'GLSO' THEN InvoiceNumber + '|' + VendorDocument ELSE Equipment + '|' + InvoiceNumber END, 30) AS PrepayReference,
		CASE WHEN ICB_AP = 1 AND RecordType = 'VND' AND IsDemurrage = 0 THEN 'ICB' -- 4
			 WHEN ICB_AR = 1 AND RecordType <> 'VND' AND IsDemurrage = 0 THEN 'ICB' -- 4
			 WHEN ICB_AP = 0 AND PrePay = 1 AND PrePayType = 'P' AND PierPassType = 0 AND IsDemurrage = 0 THEN 'PREPAY' -- 3
			 WHEN PrePayType = 'A' AND IsDemurrage = 0 THEN 'ACCRUAL' -- 7
			 WHEN PierPassType = 1 AND IsDemurrage = 0 THEN 'PIERPASS' -- 5
			 WHEN VndIntercompany = 1 AND IsDemurrage = 0 THEN 'INTERCOMPANY' -- 2
			 WHEN PerDiemType = 1 AND IsDemurrage = 0 THEN 'PERDIEM' -- 6
			 WHEN IsDemurrage = 1 THEN 'DEMURRAGE' -- 8
			 ELSE 'VENDOR PAY' END AS TransType, -- 1
		CASE WHEN ICB_AP = 1 AND RecordType = 'VND' AND IsDemurrage = 0 THEN 4
			 WHEN ICB_AR = 1 AND RecordType <> 'VND' AND IsDemurrage = 0 THEN 4
			 WHEN ICB_AP = 0 AND PrePay = 1 AND PrePayType = 'P' AND PierPassType = 0 AND IsDemurrage = 0 THEN 3
			 WHEN PrePayType = 'A' AND IsDemurrage = 0 THEN 7
			 WHEN PierPassType = 1 AND IsDemurrage = 0 THEN 5
			 WHEN VndIntercompany = 1 AND IsDemurrage = 0 THEN 2
			 WHEN PerDiemType = 1 AND IsDemurrage = 0 THEN 6
			 WHEN IsDemurrage = 1 THEN 8
			 ELSE 1 END AS TransTypeId,
		CASE WHEN VndIntercompany = 1 OR ICB_AP = 1 THEN 'TIP'
			 WHEN (ICB_AP = 0 AND PrePay = 1 AND PrePayType = 'P') OR PierPassType = 1 OR PerDiemType = 1 OR PrePayType = 'A' OR IsDemurrage = 1 THEN 'FSIG'
			 ELSE 'FSIP' END AS IntegrationType,
		IsDemurrage,
		Equipment,
		FSI_ReceivedSubDetailId AS RecordId
FROM	(
		SELECT	FH.Company,
				FH.BatchId,
				WeekEndDate, 
				InvoiceNumber,
				InvoiceDate,
				CustomerNumber, 
				BillToRef, 
				InvoiceType, 
				Division, 
				ISNULL(RecordType, 'NONE') AS RecordType, 
				ISNULL(RecordCode, 'NONE') AS RecordCode,
				ChargeAmount1 AS Amount, 
				FS.VndIntercompany,
				CASE WHEN DEM.VarC IS NOT Null THEN CAST(COM.CompanyNumber AS Varchar) + '-' + FD.InvoiceNumber ELSE 
				CASE WHEN FD.InvoiceType IN ('C','D') AND FS.VendorReference IS NOT Null AND FS.VendorReference <> '' THEN FS.VendorReference
					 WHEN FD.InvoiceType IN ('C','D') AND (FS.VendorDocument IS Null OR FS.VendorDocument = '') THEN InvoiceNumber ELSE
						RTRIM(LEFT(CASE WHEN VendorDocument IS NOT Null THEN CASE WHEN RTRIM(VendorDocument) = RTRIM(FD.Equipment) THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1) ELSE RTRIM(VendorDocument) END
						WHEN Equipment IS NOT Null AND Equipment <> '' THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1)
						WHEN (LEN(RTRIM(ISNULL(FD.Equipment,''))) = 10 OR ISNULL(FD.Equipment,'') = 'FLATBED') AND ISNULL(FD.Equipment,'') <> VendorDocument THEN RTRIM(ISNULL(LEFT(FD.Equipment, 10),'')) + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
						ELSE CASE WHEN RTRIM(VendorDocument) = '' THEN CAST(FSI_ReceivedSubDetailId AS Varchar) ELSE RTRIM(VendorDocument) END + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
					END, 20)) END END AS VendorDocument,
				VendorReference,
				FD.Equipment,
				RTRIM(FD.Equipment) + ISNULL(FD.CheckDigit,'') AS EquipmentNumber,
				FS.PrePay,
				IIF(FS.PrePayType IN ('A','P'), FS.PrePayType, Null) AS PrePayType,
				ISNULL(IIF(FD.PrePayType IN ('A','P'), FD.PrePayType, Null),'') AS AR_PrePayType,
				FS.AccCode,
				FSI_ReceivedSubDetailId,
				IIF(EXISTS(SELECT AR.Company FROM FSI_Intercompany_ARAP AR WHERE AR.Company = FH.Company AND AR.Account = FD.CustomerNumber AND AR.RecordType = 'C'), 1, 0) AS ICB_AR,
				IIF(EXISTS(SELECT AR.Company FROM FSI_Intercompany_ARAP AR WHERE AR.Company = FH.Company AND AR.Account = FS.RecordCode AND AR.RecordType = 'V'), 1, 0) AS ICB_AP,
				--CAST(CASE WHEN FS.RecordType IN ('ACC','VND') AND FS.AccCode = PAR.VarC AND VND.VendorId IS Null THEN 1 ELSE 0 END AS Bit) AS PerDiemType,
				CAST(0 AS Bit) AS PerDiemType,
				PierPassType = CAST(IIF(VND.VendorId IS Null, 0, 1) AS Bit),
				IIF(DEM.VarC IS Null, 0, 1) AS IsDemurrage
		FROM    FSI_ReceivedDetails FD
				INNER JOIN FSI_ReceivedHeader FH WITH (NOLOCK) ON FD.BatchID = FH.BatchId
				INNER JOIN FSI_ReceivedSubDetails FS WITH (NOLOCK) ON FD.BatchID = FS.BatchId AND FD.DetailId = FS.DetailId AND FS.RecordType = 'VND'
				INNER JOIN PRISQL01P.GPCustom.dbo.Companies COM WITH (NOLOCK) ON FH.Company = COM.CompanyId
				LEFT JOIN PRISQL01P.GPCustom.dbo.Parameters DEM WITH (NOLOCK) ON DEM.Company = FH.Company AND DEM.ParameterCode = 'DEMURRAGE_ACCCODE' AND FS.AccCode = DEM.VarC --AND CMA.WithDemurrage = 1
				LEFT JOIN PRISQL01P.GPCustom.dbo.GPVendorMaster VND WITH (NOLOCK) ON FH.Company = VND.Company AND FS.RecordCode = VND.VendorId AND VND.PierPassType = 1
		) DT
		
GO


