SELECT	custnmbr
		,custname
		,COALESCE([1],0.00) AS 'Current'
		,COALESCE([2],0.00) AS '31-60'
		,COALESCE([3],0.00) AS '61-90'
		,COALESCE([4],0.00) AS 'Over-91'
		,[User Date]
FROM	(
		SELECT	'Aging Day' = CASE	WHEN ABS(DATEDIFF(day, docdate, GETDATE())) BETWEEN 0 AND 30 THEN 1 
									WHEN ABS(DATEDIFF(day, docdate, GETDATE())) BETWEEN 31 AND 60 THEN 2 
									WHEN ABS(DATEDIFF(day, docdate, GETDATE())) BETWEEN 61 AND 90  THEN 3 
									WHEN ABS(DATEDIFF(day, docdate, GETDATE())) > 90 THEN 4 END
 				,'Total'	= CASE	WHEN RMDTYPAL = 1 THEN SUM(CURTRXAM)
									WHEN RMDTYPAL = 3 THEN SUM(CURTRXAM)
									WHEN RMDTYPAL = 7 THEN (SUM(CURTRXAM)) * -1 
									WHEN RMDTYPAL = 9 THEN (SUM(CURTRXAM)) * -1 END
				,custname
				,rm101.custnmbr
				,CAST(docdate AS Date) AS 'User Date'
		FROM	RM20101 rm201 
				INNER JOIN RM00101 Rm101 ON rm201.custnmbr = rm101.custnmbr
		GROUP BY	
				rm101.custnmbr
				,custname
				,rmdtypal
				,docdate 
		) AS SourceTable
PIVOT	(
		SUM(Total)
		FOR	[Aging Day] IN ([1],[2],[3],[4]) 
		) AS PVT
ORDER BY custnmbr
	
--SELECT	*
--FROM	RM20101

