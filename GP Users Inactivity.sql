 
SET NOCOUNT ON

DECLARE	@Counter			Int,
		@InactivityTime		Int = 90, --(SELECT VarI FROM GPCustom.dbo.Parameters WHERE ParameterCode = 'GPINACTIVEMINUTES')
		@Disconnect			Bit = 0


DECLARE	@tblGPUsers	Table (
		CompanyId			Varchar(5), 
		CompanyName			Varchar(100), 
		UserId				Varchar(15), 
		UserName			Varchar(50),
		LoggedInMinutes		Int,
		InactiveMinutes		Int,
		InactiveHours		Int,
		Spid				Int)

PRINT @InactivityTime

INSERT INTO @tblGPUsers
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

SET @Counter = (SELECT COUNT(*) FROM @tblGPUsers)

PRINT 'Active Sessions: ' + CAST(@Counter AS Varchar)

IF @Counter > 0 AND @Disconnect = 1
BEGIN
	DELETE	DYNAMICS.dbo.ACTIVITY 
	WHERE	UserId IN (SELECT UserId FROM @tblGPUsers WHERE InactiveMinutes > @InactivityTime)

	DELETE	TEMPDB.dbo.DEX_LOCK 
	WHERE	session_id NOT IN (SELECT SQLSESID FROM DYNAMICS.dbo.ACTIVITY)
END

SELECT	*
FROM	@tblGPUsers
ORDER BY InactiveMinutes DESC, UserId