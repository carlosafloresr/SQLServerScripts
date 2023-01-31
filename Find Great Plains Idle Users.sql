DECLARE	@IdleMinutes	Int = 5, -- Set the number of minutes. If the idle minutes are greater than this, the users will appear in the results.
		@RunTime		Datetime = GETDATE()

SELECT	A.USERID,
		RTRIM(U.USERNAME) AS USERNAME,
		RTRIM(A.CMPNYNAM) AS COMPANY_NAME,
		CONVERT(Varchar(10), logindat, 101) + ' ' + LTRIM(SUBSTRING(CONVERT(Varchar(20), logintim, 100), 13, LEN(CONVERT(Varchar(20), logintim, 100)))) AS LOGIN_TIME,
		CASE WHEN DATEDIFF(mi, P.last_batch, @RunTime) >= 60 THEN CAST((CASE WHEN DATEDIFF(mi, P.last_batch, @RunTime) > 1 THEN DATEDIFF(mi, P.last_batch, @RunTime) ELSE 0 END) / 60 AS Varchar(5)) + ' hours(2), ' 
				+ RIGHT('0' + CAST((CASE WHEN DATEDIFF(mi, P.last_batch, @RunTime) > 1 THEN DATEDIFF(mi, P.last_batch, @RunTime) ELSE 0 END) %60 AS Varchar(2)), 2) + ' minute(s)'
			 WHEN DATEDIFF(mi, P.last_batch, @RunTime) < 60 THEN RIGHT('0' + CAST((CASE WHEN DATEDIFF(mi, P.last_batch, @RunTime) > 1 THEN DATEDIFF(mi, P.last_batch, @RunTime) ELSE 0 END )%60 AS Varchar(2)), 2) + ' minute(s)'
			 ELSE '' END AS IDLETIME,	
		CASE WHEN DATEDIFF(mi, P.last_batch, @RunTime) > 1 THEN DATEDIFF(mi, P.last_batch, @RunTime) ELSE 0 END AS IDLE_TIME,
		CONVERT(Varchar, @RunTime, 101) + ' ' + RIGHT(CONVERT(Varchar, @RunTime, 100), 7) AS Run_Date_Time
FROM	DYNAMICS..ACTIVITY A
		LEFT JOIN DYNAMICS..SY01400 U ON A.USERID = U.USERID
		LEFT JOIN DYNAMICS..SY01500 C ON A.CMPNYNAM = C.CMPNYNAM
		LEFT JOIN tempdb..DEX_SESSION S ON A.SQLSESID = S.session_id
		LEFT JOIN Master..sysprocesses P ON S.sqlsvr_spid = P.spid AND ecid = 0
		LEFT JOIN Master..sysdatabases D ON P.dbid = D.dbid
WHERE	CASE WHEN DATEDIFF(mi, P.last_batch, @RunTime) > 1 THEN DATEDIFF(mi, P.last_batch, @RunTime) ELSE 0 END >= @IdleMinutes
ORDER BY 6 DESC, 1