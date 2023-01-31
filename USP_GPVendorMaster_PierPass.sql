/*
EXECUTE USP_GPVendorMaster_PierPass
*/
CREATE PROCEDURE USP_GPVendorMaster_PierPass
AS
DECLARE @tblSWS		Table (
		Cmpy_No		Int,
		Code		Varchar(15),
		Status		Char(1))

INSERT INTO @tblSWS
EXECUTE USP_QuerySWS_ReportData 'SELECT cmpy_no, code, status FROM TRK.Vendor WHERE name LIKE ''PIER%'' OR name LIKE ''REGION%'' AND cmpy_no between 1 and 10 AND status = ''A'''

UPDATE	GPVendorMaster
SET		GPVendorMaster.PierPassType = 1,
		GPVendorMaster.SWSVendor	= 1
FROM	(
		SELECT	COM.CompanyId,
				SWS.Code,
				GPV.PierPassType AS PPT
		FROM	@tblSWS SWS
				INNER JOIN Companies COM ON SWS.Cmpy_No = COM.CompanyNumber AND COM.IsTest = 0
				LEFT JOIN GPVendorMaster GPV ON COM.CompanyId = GPV.Company AND SWS.Code = GPV.VendorId
		) DATA
WHERE	GPVendorMaster.Company = DATA.CompanyId
		AND GPVendorMaster.VendorId = DATA.Code