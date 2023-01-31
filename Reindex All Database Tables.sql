DECLARE @Database	VARCHAR(250) = DB_NAME(), 
		@Table		VARCHAR(250), 
		@cmd		NVARCHAR(1500),
		@fillfactor INT = 90 

DECLARE curTables CURSOR FOR
SELECT	'[' + table_catalog + '].[' + table_schema + '].[' + table_name + ']' AS tableName 
FROM	INFORMATION_SCHEMA.TABLES 
WHERE	table_type = 'BASE TABLE' 
ORDER BY 1 

OPEN curTables
 
FETCH NEXT FROM curTables INTO @Table 
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @Table

    SET @cmd = 'ALTER INDEX ALL ON ' + @Table + ' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR(3), @fillfactor) + ', SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = ON)'
    EXECUTE(@cmd) 

    FETCH NEXT FROM curTables INTO @Table   
END

CLOSE curTables
DEALLOCATE curTables
GO