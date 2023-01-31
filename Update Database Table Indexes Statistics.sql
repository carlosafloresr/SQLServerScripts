DECLARE @Database	VARCHAR(255) = DB_NAME(), 
		@Table		VARCHAR(255), 
		@cmd		NVARCHAR(500),
		@fillfactor INT 

SET @fillfactor = 90

SET @cmd = 'DECLARE curTableCursor CURSOR FOR SELECT ''['' + table_catalog + ''].['' + table_schema + ''].['' + 
  table_name + '']'' AS tableName FROM [' + @Database + '].INFORMATION_SCHEMA.TABLES 
  WHERE table_type = ''BASE TABLE'''

-- Create table cursor
EXECUTE(@cmd)
OPEN curTableCursor

FETCH NEXT FROM curTableCursor INTO @Table
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @Table
    SET @cmd = 'UPDATE STATISTICS ' + @Table
    EXECUTE(@cmd) 

    FETCH NEXT FROM curTableCursor INTO @Table   
END   

CLOSE curTableCursor
DEALLOCATE curTableCursor
GO