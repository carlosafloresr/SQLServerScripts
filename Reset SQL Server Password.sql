DECLARE	@Name	Varchar(50),
		@Test	Varchar(100),
		@Script	Varchar(100)

DECLARE Users CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Name
FROM	sys.server_principals 
WHERE	(type_desc = 'SQL_LOGIN' OR type_desc = 'WINDOWS_LOGIN') 
		AND name NOT IN ('sa','NT AUTHORITY\SYSTEM','DYNSA','NT AUTHORITY\NETWORK SERVICE','IILOGISTICS\ilsadmin','DomainImporter','CRYSTAL','ecconect','gpcustom','iilogistics\cflores','IILOGISTICS\EconnectUser','Integrations','intranetcrystal','IILOGISTICS\BusinessPortal','distributor_admin','FRxForecaster','GPUser','mbaker','kpowell')
		AND PATINDEX('%frx%', name) = 0
		AND PATINDEX('%user%', name) = 0
		AND LEN(name) < 15
		AND name = 'cflores'

OPEN Users 
FETCH FROM Users INTO @Name

WHILE @@FETCH_STATUS = 0
BEGIN
	--EXECUTE SP_Password @new = 'memphis1', @loginame = @Name
	SET @Script = 'ALTER LOGIN ' + @Name + ' WITH PASSWORD = ''Memphis1!'''
	EXECUTE (@Script)
	PRINT @Name
	
	FETCH FROM Users INTO @Name
END

CLOSE Users
DEALLOCATE Users

/*
USE master
GO
EXEC sp_configure 'Ole Automation Procedures', '1'
RECONFIGURE

*/