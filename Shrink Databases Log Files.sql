/*
=============================================================
                SHRINK DATABASES LOG FILE  
=============================================================
*/
DECLARE @Database	VARCHAR(255), 
		@Cmd		VARCHAR(500)
		
DECLARE DatabaseCursor CURSOR FOR
	SELECT name FROM master.dbo.sysdatabases
	WHERE name NOT IN ('master','msdb','tempdb','model','distribution')
	ORDER BY 1

OPEN DatabaseCursor

FETCH NEXT FROM DatabaseCursor INTO @Database
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @Database

	SET @Cmd = N'USE [' + @Database + ']; ' + 

	-- Truncate the log by changing the database recovery model to SIMPLE.
	 'ALTER DATABASE [' + @Database + '] SET RECOVERY SIMPLE; ' + 

	-- Shrink the truncated log file to 1 MB.
	'DBCC SHRINKFILE (2, 1); ' +

	-- Reset the database recovery model.
	'ALTER DATABASE [' + @Database + '] SET RECOVERY FULL;'

	--PRINT @Cmd
	EXECUTE(@Cmd)

	FETCH NEXT FROM DatabaseCursor INTO @Database
END

CLOSE DatabaseCursor
DEALLOCATE DatabaseCursor