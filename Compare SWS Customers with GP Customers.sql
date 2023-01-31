EXECUTE USP_QuerySWS 'SELECT cmpy_no, code, name from com.billto where btt_type = ''SSL''  and status != ''I'' group by cmpy_no,code,name order by cmpy_no,code', '##TMPSWS'

SELECT	cmpy_no AS SWS_Company, RTRIM(code) AS SWS_CustNo, name AS SWS_CustName,
		CM.CompanyId, RTRIM(CM.CustNmbr) AS CustNmbr, CM.CustName, CM.CustClas
		--CASE CM.BillType WHEN 0 THEN 'Not Defined' WHEN 1 THEN 'Principal' WHEN 2 THEN 'Cargo Owner' ELSE '3rd Party' END AS BillToType
FROM	CustomerMaster CM
		INNER JOIN Companies CO ON CM.CompanyId = CO.CompanyId
		INNER JOIN ##TMPSWS SW ON SW.cmpy_no = CO.CompanyNumber AND SW.CODE = CM.CustNmbr

DROP TABLE ##TMPSWS