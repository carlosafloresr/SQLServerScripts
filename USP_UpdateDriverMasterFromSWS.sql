USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateDriverMasterFromSWS]    Script Date: 4/21/2017 11:26:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_UpdateDriverMasterFromSWS

SELECT	* 
FROM	VendorMaster 
WHERE	Company = 'GIS'
		AND VendorId = 'G1047'
ORDER BY Division, VendorId
*/
ALTER PROCEDURE [dbo].[USP_UpdateDriverMasterFromSWS]
AS
SET NOCOUNT OFF

EXECUTE USP_QuerySWS 'SELECT CASE WHEN CO.AgentOf_Cmpy_No > 0 THEN CO.AgentOf_Cmpy_No ELSE DR.Cmpy_No END AS cmpy_no, DR.Cmpy_No AS CompanyNumber, DR.code, DR.div_code, DR.type, DR.name, DR.HireDT, DR.email FROM trk.driver DR INNER JOIN COM.Company CO ON DR.Cmpy_No = CO.No WHERE DR.type IN (''D'',''O'') ORDER BY 1, 2', '##tmpDrivers'
--AND GPCustom.dbo.IsEmailAddressValid(
SELECT	DRV.*,
		CASE WHEN RTRIM(DRV.Email) = '' OR GPCustom.dbo.IsEmailAddressValid(DRV.email) = 0 THEN Null ELSE LOWER(RTRIM(DRV.email)) END AS EmailAddress,
		COM.CompanyId
INTO	#tmpDriverCompany
FROM	##tmpDrivers DRV
		INNER JOIN Companies COM ON DRV.cmpy_no = COM.CompanyNumber AND COM.IsTest = 0

UPDATE	VendorMaster
SET		VendorMaster.VendorId		= LTRIM(RTRIM(VendorMaster.VendorId)),
		VendorMaster.Division		= DRV.div_code,
		VendorMaster.DriverName		= ISNULL(DRV.Name, dbo.PROPER(ISNULL(RTRIM(DRV.Name), GPCustom.dbo.GetDriverName(DRV.CompanyId, VendorMaster.VendorId, 'O')))),
		VendorMaster.Agent			= CASE WHEN VendorMaster.Company = 'NDS' THEN DRV.CompanyNumber ELSE Null END,
		VendorMaster.HireDate		= CAST(DRV.HireDT AS Date),
		VendorMaster.EmailAddress	= CASE WHEN VendorMaster.EmailAddress IS Null THEN (CASE WHEN DRV.Type = 'D' THEN Null ELSE DRV.EmailAddress END) ELSE VendorMaster.EmailAddress END
FROM	#tmpDriverCompany DRV
WHERE	VendorMaster.Company = DRV.CompanyId
		AND VendorMaster.VendorId = DRV.Code
		AND (VendorMaster.Division <> DRV.div_code
		OR ISNULL(VendorMaster.DriverName, 'NONE') <> dbo.PROPER(DRV.Name)
		OR (VendorMaster.Company = 'NDS' AND (VendorMaster.Agent <> DRV.CompanyNumber OR VendorMaster.Agent IS Null))
		OR VendorMaster.EmailAddress <> DRV.EmailAddress)

DROP TABLE #tmpDriverCompany
DROP TABLE ##tmpDrivers

EXECUTE USP_DriverMaster_EmailAddressUpdate

--select * from vendormaster where vendorid = 'V50001' 

/*
SELECT	VendorId, EmailAddress
FROM	VendorMaster

UPDATE	VendorMaster
SET		emailaddress = CASE WHEN RTRIM(emailaddress) = '' OR GPCustom.dbo.IsEmailAddressValid(emailaddress) = 0 THEN Null ELSE LOWER(RTRIM(emailaddress)) END

-- Clear the email address for those driver with SWS type "D"
EXECUTE USP_QuerySWS 'SELECT CASE WHEN CO.AgentOf_Cmpy_No > 0 THEN CO.AgentOf_Cmpy_No ELSE DR.Cmpy_No END AS cmpy_no, DR.Cmpy_No AS CompanyNumber, DR.code, DR.div_code, DR.type, DR.name, DR.HireDT, DR.email FROM trk.driver DR INNER JOIN COM.Company CO ON DR.Cmpy_No = CO.No WHERE DR.type = ''D'' ORDER BY 1, 2', '##tmpDrivers'

SELECT	DRV.*,
		Null AS EmailAddress,
		COM.CompanyId
INTO	#tmpDriverCompany
FROM	##tmpDrivers DRV
		INNER JOIN Companies COM ON DRV.cmpy_no = COM.CompanyNumber AND COM.IsTest = 0

UPDATE	VendorMaster
SET		VendorMaster.EmailAddress = DRV.EmailAddress
FROM	#tmpDriverCompany DRV
WHERE	VendorMaster.Company = DRV.CompanyId
		AND VendorMaster.VendorId = DRV.Code
		--AND VendorMaster.EmailAddress <> DRV.EmailAddress

DROP TABLE #tmpDriverCompany
DROP TABLE ##tmpDrivers
*/