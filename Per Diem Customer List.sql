SELECT	CMAS.CompanyId,
		CMAS.CustNmbr AS CustomerNumber,
		CMAS.CustName AS CustomerName,
		CMAS.FreightBillTo,
		CASE CMAS.BillType WHEN 1 THEN 'Principal' WHEN 2 THEN 'Cargo Owner' ELSE '3rd Party Logistics Provider' END AS BillType,
		CASE WHEN CMAS.DoesBillPerDiem = 1 THEN 'YES' ELSE 'NO' END AS DoesBillPerDiem,
				CASE WHEN CMAS.BillToAllLocations = 1 THEN 'YES' ELSE 'NO' END AS BillToAllLocations,
		CMAS.SCAC_Code,
		ISNULL(PPD.LPCode, '') AS LPCode,
		ISNULL(PPD.PDBillTo, '') AS PDBillTo,
		CASE WHEN PPD.Tariff IS Null THEN '' WHEN PPD.Tariff = 1 THEN 'YES' ELSE 'NO' END AS Tariff
FROM	CustomerMaster CMAS
		LEFT JOIN PrincipalPerDiem PPD ON CMAS.CompanyId = PPD.CompanyId AND CMAS.CustNmbr = PPD.CustNmbr
WHERE	CMAS.BillType > 0
		AND CMAS.Inactive = 0
ORDER BY
		CMAS.CompanyId,
		CMAS.CustName,
		CMAS.CustNmbr