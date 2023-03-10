USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_GPVendorMaster_VerifyChanges]    Script Date: 8/23/2022 9:12:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_GPVendorMaster_VerifyChanges
UPDATE GPVendorMaster SET Changed = 1 WHERE Company = 'AIS' AND VendorId = '50077A'
*/
ALTER PROCEDURE [dbo].[USP_GPVendorMaster_VerifyChanges]
AS
/*
================================================================================================
VERSION		MODIFIED	USER				MODIFICATION
================================================================================================
1.2			08/22/2022	Carlos A. Flores	The new SWS Inactive logic has been added to the 
											SWS synchronization and the HOLD has been removed 
											from this logic.
================================================================================================
*/
SET NOCOUNT ON

SELECT	GPVM.Company,
		COMP.CompanyNumber,
		GPVM.VendorId,
		GPVM.VendName,
		GPVM.Address1,
		GPVM.Address2,
		GPVM.City,
		GPVM.State,
		GPVM.ZipCode,
		GPVM.Status,
		GPVM.Phone,
		GPVM.Email,
		ISNULL(FSI.LinkedCompany, '') AS ICB_Company,
		IIF(C2.CompanyId IS Null, 0, C2.CompanyNumber) AS ICB_CompanyNumber,
		'VND~GPS~' + CAST(COMP.CompanyNumber AS Varchar) + '~' + CASE WHEN COMP.WithSWSAlias = 1 AND GPVM.SWSVendorId IS NOT Null THEN GPVM.SWSVendorId ELSE RTRIM(GPVM.VendorId) END + '~' + ISNULL(GPVM.VendName,'') + '~' + ISNULL(GPVM.Address1,'') + '~' + ISNULL(GPVM.Address2,'') + '~' + ISNULL(GPVM.City,'') + '~' + ISNULL(GPVM.State,'') + '~' + ISNULL(GPVM.ZipCode,'') + '~' + IIF(SWSInactive = 1, 'I', RTRIM(GPVM.Status)) + '~' + ISNULL(GPVM.Phone,'') + '~' + ISNULL(LTRIM(RTRIM(GPVM.Email)),'') + '~' + CASE WHEN COMP.WithSWSAlias = 1 AND GPVM.SWSVendorId IS NOT Null THEN GPVM.VendorId ELSE '' END + '~' + CAST(IIF(C2.CompanyId IS Null, 0, C2.CompanyNumber) AS Varchar) + '~' + GPVM.VendClass AS SWSText
FROM	GPVendorMaster GPVM
		INNER JOIN Companies COMP ON GPVM.Company = COMP.CompanyId AND COMP.SWSVendors = 1
		LEFT JOIN IntegrationsDB.Integrations.dbo.FSI_Intercompany_ARAP FSI ON GPVM.Company = FSI.Company AND GPVM.VendorId = FSI.Account AND FSI.RecordType = 'V' AND FSI.TransType = 'ICB'
		LEFT JOIN Companies C2 ON FSI.LinkedCompany = C2.CompanyId
WHERE	GPVM.Changed = 1
		AND GPVM.SWSVendor = 1
ORDER BY COMP.CompanyNumber, GPVM.VendorId