INSERT INTO Divisions_ProjectEmails
SELECT	'ROADSIDEREPAIRS' AS Project,
		CompanyId,
		Division,
		OpsEmail,
		CAST(0 AS Bit) AS Inactive 
FROM	View_Divisions
WHERE	CompanyId <> 'NDS'
		AND IsTrucking = 1
ORDER BY CompanyId, Division