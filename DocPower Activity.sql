SELECT	CAST(ProcessedOn AS Date) AS Date,
		COUNT(*) AS Counter
FROM	DocPowerImages
WHERE	CAST(ProcessedOn AS Date) >= '12/19/2018'
		--AND Success = 0
GROUP BY CAST(ProcessedOn AS Date)
order by 1
/*
SELECT	DISTINCT EmailSubject
FROM	DocPowerImages
WHERE	ProcessedOn > '08/12/2018'

SELECT	ProcessedBy,
		COUNT(*) AS Counter
FROM	DocPowerImages
WHERE	ProcessedOn > '08/14/2018'
GROUP BY ProcessedBy
*/