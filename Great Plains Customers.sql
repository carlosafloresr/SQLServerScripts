SELECT	CUSTNMBR,
		CUSTNAME,
		CUSTCLAS
FROM	CustomerMaster
WHERE	CompanyId = 'pts'
		and LEN(RTRIM(CUSTNMBR)) < 7
		and inactive = 0
ORDER BY 2

update	CustomerMaster
set		Changed = 1,
		Trasmitted = 0
WHERE	CompanyId = 'pts'
		and LEN(RTRIM(CUSTNMBR)) < 7
		and inactive = 0