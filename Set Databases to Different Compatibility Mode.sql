DECLARE	@Query		Varchar(Max),
		@DBName		Varchar(20)

DECLARE Transaction_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	name
FROM	sys.databases 
WHERE	compatibility_level < 130

OPEN Transaction_Companies 
FETCH FROM Transaction_Companies INTO @DBName

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Database ' + @DBName

	SET @Query = N'ALTER DATABASE ' + @DBName + ' SET COMPATIBILITY_LEVEL = 130'
	EXECUTE(@Query)

	FETCH FROM Transaction_Companies INTO @DBName
END

CLOSE Transaction_Companies
DEALLOCATE Transaction_Companies