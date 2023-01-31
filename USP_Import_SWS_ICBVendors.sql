/*
EXECUTE USP_Import_SWS_ICBVendors
*/
CREATE PROCEDURE USP_Import_SWS_ICBVendors
AS
DECLARE @tblData Table (CompanyNo Int, CompanyId Varchar(5) Null, VendorId Varchar(15), ICB_CompanyNo Int, ICBCompanyId Varchar(5))

INSERT INTO @tblData (CompanyNo, VendorId, ICB_CompanyNo)
EXECUTE USP_QuerySWS 'SELECT cmpy_no, code, icb_cmpy_no FROM trk.vendor WHERE icb_cmpy_no BETWEEN 1 AND 999 ORDER BY cmpy_no, icb_cmpy_no'

UPDATE	@tblData
SET		CompanyId = DATA.Company,
		ICBCompanyId = DATA.ICBCompany
FROM	(
SELECT	DAT.*,
		COM.CompanyId AS Company,
		ICB.CompanyId AS ICBCompany
FROM	@tblData DAT
		LEFT JOIN Companies COM ON DAT.CompanyNo = COM.CompanyNumber
		LEFT JOIN Companies ICB ON DAT.ICB_CompanyNo = ICB.CompanyNumber
		) DATA
WHERE	[@tblData].CompanyNo = DATA.CompanyNo
		AND [@tblData].VendorId = DATA.VendorId
		AND [@tblData].ICB_CompanyNo = DATA.ICB_CompanyNo

/*
SELECT	*
FROM	PRISQL004P.Integrations.dbo.FSI_Intercompany_ARAP
*/

INSERT INTO PRISQL004P.Integrations.dbo.FSI_Intercompany_ARAP
		(Company,
		LinkedCompany,
		RecordType,
		Account,
		ForGLIntegration,
		TransType)
SELECT	DAT.CompanyId,
		DAT.ICBCompanyId,
		'V',
		DAT.VendorId,
		1,
		'ICB'
FROM	@tblData DAT
		LEFT JOIN PRISQL004P.Integrations.dbo.FSI_Intercompany_ARAP FSI ON DAT.CompanyId = FSI.Company AND DAT.ICBCompanyId = FSI.LinkedCompany AND DAT.VendorId = FSI.Account AND FSI.RecordType = 'V' AND FSI.TransType = 'ICB'
WHERE	FSI.Account IS Null
ORDER BY 2, 5