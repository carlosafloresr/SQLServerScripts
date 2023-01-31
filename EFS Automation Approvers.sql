SELECT	DISTINCT USR.UserId,
		USR.Company,
		USR.DisplayName,
		ISNULL(USR.Title,'') AS Title,
		ISNULL(USR.Location,'') AS Location
FROM	DomainUsers USR
WHERE	USR.Inactive = 0
		AND USR.Company IS NOT Null
		AND USR.Company = 'AIS'
		AND USR.UserId IN ('jcaudle','rburnsed','jbanton','brandonc','stanner','slarsen','fborum')
ORDER BY USR.Company, USR.DisplayName

--SELECT	DISTINCT USR.UserId,
--		USR.Company,
--		USR.DisplayName,
--		ISNULL(USR.Title,'') AS Title,
--		ISNULL(USR.Location,'') AS Location
--FROM	DomainUsers USR
--WHERE	USR.Inactive = 0
--		AND USR.Company IS NOT Null
--		AND USR.Company = 'IMCG'
--		AND USR.UserId IN ('hhoof','jhenry','npayne','rwright','rsturm')
--ORDER BY USR.Company, USR.DisplayName