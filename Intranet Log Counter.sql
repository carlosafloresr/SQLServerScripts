SELECT	UserId,
		Module,
		COUNT(*) AS Counter
FROM	Intranet.dbo.IntranetLog
GROUP BY UserId,
		Module
ORDER BY
		3 DESC, 2, 1

SELECT	Module,
		COUNT(*) AS Counter
FROM	Intranet.dbo.IntranetLog
GROUP BY Module
ORDER BY
		2 DESC, 1