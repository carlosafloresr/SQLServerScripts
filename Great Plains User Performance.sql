SELECT	USERID, 
		COUNT(*) AS COUNTER 
FROM	DYNAMICS.dbo.SY07140 
WHERE	USERID IN (SELECT userid FROM DYNAMICS.dbo.ACTIVITY)
GROUP BY USERID 
ORDER BY 2 DESC

/*
SELECT * FROM DYNAMICS..SY07140 ORDER BY USERID
SELECT * FROM DYNAMICS..SY07140_Changes

DELETE SY07140 WHERE USERID NOT IN (SELECT userid FROM DYNAMICS..ACTIVITY)

SELECT userid, count(*) as counter
FROM DYNAMICS..SY07140_Changes
group by UserId
*/