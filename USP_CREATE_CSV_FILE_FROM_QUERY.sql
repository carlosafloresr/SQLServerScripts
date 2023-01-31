/*
EXECUTE USP_CREATE_CSV_FILE_FROM_QUERY 'SELECT * FROM Companies', 'C:\TEMP\COMPANIES2.CSV'
*/
ALTER PROCEDURE USP_Create_CSV_File_From_Query
    @SQL			Nvarchar(MAX),
    @CSVFileName	Nvarchar(200)
AS
BEGIN
    IF ISNULL(@SQL,'') = '' OR ISNULL(@CSVFileName,'') = ''
    BEGIN
        RAISERROR ('Invalid SQL/CsvFile values passed!; Aborting...', 0, 1) WITH NOWAIT
        RETURN
    END

    DROP TABLE IF EXISTS global_temp_CSVtable;
    
	DECLARE	@columnList		varchar(4000), 
			@columnList1	varchar(4000),
			@SQLcmd			varchar(4000),
			@dos_cmd		nvarchar(4000)

    SET @SQLcmd = REPLACE(@SQL, 'FROM', 'INTO global_temp_CSVtable FROM')
    EXECUTE(@SQLcmd); 

    DECLARE @cols TABLE (i Int identity, colname Varchar(100))
    
	INSERT INTO @cols
    SELECT	column_name
    FROM	information_schema.COLUMNS
    WHERE	TABLE_NAME = 'global_temp_CSVtable'

    DECLARE @i				Int, 
			@maxi			Int

    SELECT	@i		= 1,
			@maxi	= MAX(i) 
	FROM	@cols

    WHILE (@i <= @maxi)
    BEGIN
        SELECT	@SQL = 'alter table global_temp_CSVtable alter column [' + colname + '] VARCHAR(max) NULL'
        FROM	@cols
        WHERE	i = @i

        EXECUTE sp_executesql @SQL
        
		SELECT	@i = @i + 1
    END

    SELECT	@columnList		= COALESCE(@columnList + ''', ''', '') + column_name,
			@columnList1	= COALESCE(@columnList1 + ', ', '') + column_name
    FROM	information_schema.columns
    WHERE	table_name = 'global_temp_CSVtable'
    ORDER BY ORDINAL_POSITION

    SELECT	@columnList = '''' + @columnList + '''';

		SELECT	@dos_cmd = 'BCP "SELECT ' + @columnList + 
						' UNION ALL ' +
						'SELECT * FROM ' + db_name() + '..global_temp_CSVtable" ' + 
						'QUERYOUT ' + @CSVFileName + ' -c -t, -T'
		PRINT @dos_cmd

		EXECUTE master.dbo.xp_cmdshell @dos_cmd, No_output 

    DROP TABLE IF EXISTS global_temp_CSVtable;
END