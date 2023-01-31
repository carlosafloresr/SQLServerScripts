SELECT	RTRIM(SY01500.INTERID) AS CompanyId, 
		RTRIM(SY01500.CMPNYNAM) AS CompanyName,  
		RTRIM(Activity.USERID) AS UserId, 
		RTRIM(Usr.USERNAME) AS UserName,
		DATEDIFF(minute, sysproc.login_time, GETDATE()) AS LoggedInMinutes,
		DATEDIFF(minute, sysproc.last_batch, GETDATE()) AS InactiveMinutes,
		DATEDIFF(hour, sysproc.last_batch, GETDATE()) AS InactiveHours,
		sysProc.spid
FROM	DYNAMICS.dbo.ACTIVITY Activity (NOLOCK)
		INNER JOIN DYNAMICS.dbo.SY01400 Usr (NOLOCK) ON Activity.USERID = Usr.USERID
		INNER JOIN DYNAMICS.dbo.SY01500 SY01500 ON Activity.CMPNYNAM = SY01500.CMPNYNAM
		LEFT OUTER JOIN tempdb..DEX_SESSION DexSession ON Activity.SQLSESID = DexSession.session_id
		LEFT OUTER JOIN master..sysprocesses sysproc ON DexSession.sqlsvr_spid = sysproc.spid AND Activity.USERID = sysproc.loginame
WHERE	DATEDIFF(minute, sysproc.login_time, GETDATE()) IS NOT Null

/*
DELETE DYNAMICS..ACTIVITY WHERE UserId IN ('eulloa') and CmpnyNam = 'Ohio Intermodal Services, LLC'
DELETE tempdb..DEX_SESSION WHERE sqlsvr_spid <> 388

*/

SELECT	*
FROM	tempdb..DEX_SESSION