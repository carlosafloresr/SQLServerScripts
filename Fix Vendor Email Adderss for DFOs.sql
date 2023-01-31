EXECUTE USP_QuerySWS 'SELECT CASE WHEN CO.AgentOf_Cmpy_No > 0 THEN CO.AgentOf_Cmpy_No ELSE DR.Cmpy_No END AS cmpy_no, DR.code AS DriverId, DR.email FROM trk.driver DR INNER JOIN COM.Company CO ON DR.Cmpy_No = CO.No WHERE DR.type = ''D'' AND DR.email <> '''' AND DR.email NOT LIKE ''%@NONE%'' ORDER BY 1, 2', '##tmpSWS'

SELECT	CPY.CompanyId,
		SWS.*
INTO	##tmpData
FROM	##tmpSWS SWS
		INNER JOIN Companies CPY ON SWS.cmpy_no = CPY.CompanyNumber AND CPY.IsTest = 0

UPDATE	VendorMaster
SET		VendorMaster.emailaddress = Null
FROM	(
		SELECT	TMP.CompanyId,
				PMV.VendorId,
				PMV.EmailAddress,
				TMP.email
		FROM	VendorMaster PMV
				INNER JOIN ##tmpData TMP ON PMV.VendorId = TMP.DriverId
		WHERE	PMV.EmailAddress IS NOT Null
				AND PMV.EmailAddress <> ''
				AND PMV.EmailAddress = TMP.Email
		) DATA
WHERE	VendorMaster.Company = DATA.CompanyId
		AND VendorMaster.VendorId = DATA.VendorId

DROP TABLE ##tmpSWS
DROP TABLE ##tmpData