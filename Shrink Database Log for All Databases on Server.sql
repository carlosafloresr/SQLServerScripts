DECLARE	@Database	Varchar(25),
		@Query		Varchar(MAX)

DECLARE curDatabases CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(Name) AS DBName
FROM	sys.databases
WHERE	Name <> 'TempDB'

OPEN curDatabases 
FETCH FROM curDatabases INTO @Database

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'USE ' + @Database + ';

	ALTER DATABASE ' + @Database + '
	SET RECOVERY SIMPLE;

	DBCC SHRINKFILE (2, 1);

	ALTER DATABASE ' + @Database + '
	SET RECOVERY FULL;'
	
	EXECUTE(@Query)

	FETCH FROM curDatabases INTO @Database
END

CLOSE curDatabases
DEALLOCATE curDatabases
GO
