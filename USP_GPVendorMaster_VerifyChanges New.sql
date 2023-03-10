USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_GPVendorMaster_VerifyChanges]    Script Date: 5/3/2017 9:00:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_GPVendorMaster_VerifyChanges
*/
ALTER PROCEDURE [dbo].[USP_GPVendorMaster_VerifyChanges]
AS
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
		'VND~GPS~' + CAST(COMP.CompanyNumber AS Varchar) + '~' + RTRIM(GPVM.VendorId) + '~' + ISNULL(GPVM.VendName,'') + '~' + ISNULL(GPVM.Address1,'') + '~' + ISNULL(GPVM.Address2,'') + '~' + ISNULL(GPVM.City,'') + '~' + ISNULL(GPVM.State,'') + '~' + ISNULL(GPVM.ZipCode,'') + '~' + RTRIM(GPVM.Status) + '~' + ISNULL(GPVM.Phone,'') + '~' + ISNULL(GPVM.Email,'') AS SWSText
FROM	GPVendorMaster GPVM
		INNER JOIN Companies COMP ON GPVM.Company = COMP.CompanyId AND COMP.SWSVendors = 1
WHERE	GPVM.SWSVendor = 1
		AND GPVM.Changed = 1
ORDER BY COMP.CompanyNumber, GPVM.VendorId

/*
-- TRUNCATE TABLE GPVendorMaster
*/