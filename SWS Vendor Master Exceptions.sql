SELECT	*
INTO	#tmpData
FROM	(
		SELECT	SW.Cmpy_no,
				CO.CompanyId,
				SW.vn_code,
				PM.VendName,
				PM.VndClsid,
				CASE WHEN PM.VENDSTTS = 1 THEN 'A' ELSE 'I' END AS [Status]
		FROM	SWSVendorExceptions SW
				INNER JOIN Companies CO ON SW.cmpy_no = CO.CompanyNumber AND CO.IsTest = 0
				INNER JOIN IMC.dbo.PM00200 PM ON SW.vn_code = PM.VendorId
		WHERE	SW.Cmpy_no = 1
		UNION
		SELECT	SW.Cmpy_no,
				CO.CompanyId,
				SW.vn_code,
				PM.VendName,
				PM.VndClsid,
				CASE WHEN PM.VENDSTTS = 1 THEN 'A' ELSE 'I' END AS [Status]
		FROM	SWSVendorExceptions SW
				INNER JOIN Companies CO ON SW.cmpy_no = CO.CompanyNumber AND CO.IsTest = 0
				INNER JOIN GIS.dbo.PM00200 PM ON SW.vn_code = PM.VendorId
		WHERE	SW.Cmpy_no = 2
		UNION
		SELECT	SW.Cmpy_no,
				CO.CompanyId,
				SW.vn_code,
				PM.VendName,
				PM.VndClsid,
				CASE WHEN PM.VENDSTTS = 1 THEN 'A' ELSE 'I' END AS [Status]
		FROM	SWSVendorExceptions SW
				INNER JOIN Companies CO ON SW.cmpy_no = CO.CompanyNumber AND CO.IsTest = 0
				INNER JOIN AIS.dbo.PM00200 PM ON SW.vn_code = PM.VendorId
		WHERE	SW.Cmpy_no = 4
		UNION
		SELECT	SW.Cmpy_no,
				CO.CompanyId,
				SW.vn_code,
				PM.VendName,
				PM.VndClsid,
				CASE WHEN PM.VENDSTTS = 1 THEN 'A' ELSE 'I' END AS [Status]
		FROM	SWSVendorExceptions SW
				INNER JOIN Companies CO ON SW.cmpy_no = CO.CompanyNumber AND CO.IsTest = 0
				INNER JOIN OIS.dbo.PM00200 PM ON SW.vn_code = PM.VendorId
		WHERE	SW.Cmpy_no = 5
		UNION
		SELECT	SW.Cmpy_no,
				CO.CompanyId,
				SW.vn_code,
				PM.VendName,
				PM.VndClsid,
				CASE WHEN PM.VENDSTTS = 1 THEN 'A' ELSE 'I' END AS [Status]
		FROM	SWSVendorExceptions SW
				INNER JOIN Companies CO ON SW.cmpy_no = CO.CompanyNumber AND CO.IsTest = 0
				INNER JOIN DNJ.dbo.PM00200 PM ON SW.vn_code = PM.VendorId
		WHERE	SW.Cmpy_no = 7
		UNION
		SELECT	SW.Cmpy_no,
				CO.CompanyId,
				SW.vn_code,
				PM.VendName,
				PM.VndClsid,
				CASE WHEN PM.VENDSTTS = 1 THEN 'A' ELSE 'I' END AS [Status]
		FROM	SWSVendorExceptions SW
				INNER JOIN Companies CO ON SW.cmpy_no = CO.CompanyNumber AND CO.IsTest = 0
				INNER JOIN GLSO.dbo.PM00200 PM ON SW.vn_code = PM.VendorId
		WHERE	SW.Cmpy_no = 9
				-- SW.Cmpy_no NOT IN (1,2,4,5,7,9)
		) DATA
/*
SELECT	*
FROM	GPVendorMaster
WHERE	VendorId = '11647'

SELECT	*
FROM	GIS.dbo.PM00200
WHERE	VendorId = '11647'
*/
SELECT	*
FROM	#tmpData

SELECT	SWS.cmpy_no,
		CO.CompanyId,
		SWS.vn_code
FROM	SWSVendorExceptions SWS
		INNER JOIN Companies CO ON SWS.cmpy_no = CO.CompanyNumber AND CO.IsTest = 0
		LEFT JOIN #tmpData TMP ON SWS.Cmpy_no = TMP.Cmpy_no AND SWS.vn_code = TMP.vn_code
WHERE	TMP.vn_code IS NULL

DROP TABLE #tmpData