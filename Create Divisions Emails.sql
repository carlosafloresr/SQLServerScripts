update	Divisions 
set		opsemail = EmailRequest
from	(
SELECT	companyid, division,
		'ops_div' + RTRIM(Division) + '@' + CASE CompanyId 
		WHEN 'AIS' THEN 'atlanticintermodal.com'
		WHEN 'DNJ' THEN 'godnj.com'
		WHEN 'GIS' THEN 'gulfintermodal.com'
		ELSE 'imcg.com' END AS EmailRequest
FROM	View_Divisions
WHERE	CompanyId in ('AIS','DSNJ','GIS','IMC')) dat
where	Divisions.Fk_CompanyID = dat.CompanyId and Divisions.DivisionNumber = dat.Division