SELECT	UserId, 
		CmpnyNam,
		CAST(LOGINDAT AS Date) AS LoginDate, 
		RIGHT(CONVERT(Varchar, LoginTim, 100), 7) AS LogTime,
		SQLSESID
FROM	DYNAMICS.dbo.ACTIVITY
WHERE	UserId IN (
					SELECT	UserId
					FROM	(
							SELECT	UserId, 
									COUNT(UserId) AS Counter
							FROM	DYNAMICS.dbo.ACTIVITY 
							GROUP BY UserId
							HAVING COUNT(UserId) > 1
							) DAT
				  )
ORDER BY UserId, SQLSESID

/*
DELETE	DYNAMICS.dbo.ACTIVITY
FROM	(
		SELECT	UserId, 
				MIN(SQLSESID) AS SQLSESID
		FROM	DYNAMICS.dbo.ACTIVITY
		WHERE	UserId IN (
							SELECT	UserId
							FROM	(
									SELECT	UserId, 
											COUNT(UserId) AS Counter
									FROM	DYNAMICS.dbo.ACTIVITY 
									GROUP BY UserId
									HAVING COUNT(UserId) > 1
									) DAT
						  )
		GROUP BY UserId
		) DATA
WHERE	ACTIVITY.SQLSESID = DATA.SQLSESID

DELETE DYNAMICS..ACTIVITY WHERE UserId = 'kflores' AND Cmpnynam = 'Atlantic Intermodal Services, LLC'
*/