DECLARE	@DBName		Varchar(50),
		@Query		Varchar(Max)

DECLARE	@tblDatabases Table
		(DBName		Varchar(50),
		Description	Varchar(150) Null)

INSERT INTO @tblDatabases (DBName)
SELECT	name
FROM	sys.databases
ORDER BY 1

DECLARE curDatabases CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DBName
FROM	@tblDatabases

OPEN curDatabases 
FETCH FROM curDatabases INTO @DBName

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT Value AS Note FROM ' + @DBName + '.sys.extended_properties WHERE class = 0 AND Name = ''Description'''
		
	EXECUTE(@Query)

	FETCH FROM curDatabases INTO @DBName
END

CLOSE curDatabases
DEALLOCATE curDatabases

SELECT	*
FROM	@tblDatabases
-- sp_helpdb 'ABS'