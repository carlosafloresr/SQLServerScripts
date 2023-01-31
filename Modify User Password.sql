/*
ALTER LOGIN Crystal WITH PASSWORD = ''

SELECT	Name 
FROM	SysUsers 
WHERE	Gid = 0 
		AND IsLogin = 1 
		AND HasDBAccess = 1
		AND IsNTUser = 0
		AND Name NOT IN ('dbo','sa','sa1','sa2','integration','lessonuser1','lessonuser2','crystal','gpuser','integrations','econnect')


SELECT Name FROM Dynamics.dbo.SysUsers WHERE Gid = 0 AND IsLogin = 1 AND HasDBAccess = 1 AND IsNTUser = 0 AND Name NOT IN ('dbo','sa','sa1','sa2','integration','lessonuser1','lessonuser2','crystal','gpuser','integrations','econnect')
/*

ALTER LOGIN acunningham WITH Password = 'Password001'