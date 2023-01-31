CREATE PROCEDURE USP_BackupDatabases
AS
DECLARE	@DBName	Varchar(50),
		@CDate	Char(8),
		@Query	Varchar(Max)

SET @CDate = CAST(YEAR(GETDATE()) AS Char(4)) + dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0')

DECLARE DBases CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT DBName FROM BackupDatabases WHERE Inactive = 0 ORDER BY DBName

OPEN DBases
FETCH FROM DBases INTO @DBName

BEGIN TRANSACTION

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET	@Query = 'BACKUP DATABASE [' + @DBName + '] TO DISK = N''\\ilswdc05\Backup\SQLBackups\' + @DBName + '\' + @DBName + '_' + @CDate + '.bak'' WITH NOFORMAT, NOINIT, NAME = N''' + @DBName + ''', SKIP, NOREWIND, NOUNLOAD, STATS = 10'	PRINT @Query	EXECUTE(@Query)

	FETCH FROM DBases INTO @DBName
END

CLOSE DBases
DEALLOCATE DBases