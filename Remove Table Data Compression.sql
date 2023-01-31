/*
=============================================================
                REMOVE TABLE DATA COMPRESSION
=============================================================
*/
DECLARE @Table	VARCHAR(255),
		@Cmd	VARCHAR(2000)

DECLARE TablesCursor CURSOR FOR
	SELECT	SCHEMA_NAME(sys.objects.schema_id) + '.' + OBJECT_NAME(sys.objects.object_id) AS [ObjectName]  
	FROM	sys.partitions  
			INNER JOIN sys.objects ON sys.partitions.object_id = sys.objects.object_id  
	WHERE	Data_Compression > 0  
			AND SCHEMA_NAME(sys.objects.schema_id) <> 'SYS'  
	ORDER BY 1

OPEN TablesCursor

FETCH NEXT FROM TablesCursor INTO @Table
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @Table

	SET @Cmd = N'ALTER TABLE ' + @Table + ' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);'
	PRINT @Cmd
	EXECUTE(@Cmd)

	ALTER DATABASE SWS
	SET RECOVERY SIMPLE;
	
	DBCC SHRINKFILE (2, 1);
	
	ALTER DATABASE SWS
	SET RECOVERY FULL;

	FETCH NEXT FROM TablesCursor INTO @Table
END

CLOSE TablesCursor
DEALLOCATE TablesCursor

SELECT  SCHEMA_NAME(sys.objects.schema_id) AS [SchemaName]  
		,OBJECT_NAME(sys.objects.object_id) AS [ObjectName]  
		,[rows]  
		,[data_compression_desc]  
		,[index_id] as [IndexID_on_Table]
FROM	sys.partitions  
		INNER JOIN sys.objects ON sys.partitions.object_id = sys.objects.object_id  
WHERE	Data_Compression > 0  
		AND SCHEMA_NAME(sys.objects.schema_id) <> 'SYS'  
ORDER BY SchemaName, ObjectName

/*
ALTER TABLE [dbo].[testinginvoicedata] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
*/

