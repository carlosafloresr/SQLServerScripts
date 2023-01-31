SELECT	RIGHT(LTRIM(ProjectName), 4) AS Company,
		YEAR(DateCreated) AS DocYear,
		COUNT(*) AS Counter
FROM	View_DEXDocuments
WHERE	ProjectName LIKE '%Payable%'
		AND DateCreated >= '01/01/2017'
GROUP BY RIGHT(LTRIM(ProjectName), 4), YEAR(DateCreated)
ORDER BY 1, 2