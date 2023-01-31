/*
EXECUTE USP_CustomerMaster_RequiredDocuments
*/
ALTER PROCEDURE USP_CustomerMaster_RequiredDocuments
AS
EXECUTE USP_QUERYSWS 'SELECT DISTINCT CASE WHEN Cmpy_No BETWEEN 10 AND 49 THEN 10 ELSE Cmpy_No END AS Cmpy_No, Code, DocCodes FROM COM.BillTo', '##tmpSWS'

UPDATE	CustomerMaster
SET		CustomerMaster.RequiredDocuments = DATA.DocCodes
FROM	(
		SELECT	CM.CompanyId,
				CM.CustNmbr,
				ISNULL(SW.DocCodes,'') AS DocCodes
		FROM	CustomerMaster CM
				INNER JOIN Companies CO ON CM.CompanyId = CO.CompanyId
				LEFT JOIN ##tmpSWS SW ON SW.Cmpy_No = CO.CompanyNumber AND CM.CustNmbr = SW.Code
		) DATA
WHERE	CustomerMaster.CompanyId = DATA.CompanyId
		AND CustomerMaster.CustNmbr = DATA.CustNmbr
		AND CustomerMaster.RequiredDocuments <> DATA.DocCodes

DROP TABLE ##tmpSWS

EXECUTE USP_QUERYSWS N'SELECT MRCompany_Code, Code, BatchBill, LaborRate FROM PUBLIC.MRBillTo WHERE MRCompany_Code = ''55''', '##tmpDepot'

UPDATE	CustomerMaster
SET		CustomerMaster.BatchBilling	= DATA.BatchBill,
		CustomerMaster.LaborRate	= DATA.LaborRate
FROM	(
		SELECT	CM.CompanyId,
				CM.CustNmbr,
				ISNULL(CASE WHEN SW.BatchBill = 'N' THEN 0 ELSE 1 END,0) AS BatchBill,
				ISNULL(SW.LaborRate, 0) AS LaborRate
		FROM	CustomerMaster CM
				INNER JOIN Companies CO ON CM.CompanyId = CO.CompanyId
				LEFT JOIN ##tmpDepot SW ON SW.MRCompany_Code = CO.CompanyNumber AND CM.CustNmbr = SW.Code
		) DATA
WHERE	CustomerMaster.CompanyId = DATA.CompanyId
		AND CustomerMaster.CustNmbr = DATA.CustNmbr
		AND (CustomerMaster.BatchBilling <> DATA.BatchBill
		OR CustomerMaster.LaborRate <> DATA.LaborRate)

DROP TABLE ##tmpDepot