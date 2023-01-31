DECLARE	@SearchStr		Nvarchar(100) = RTRIM('EFT000000000189'),
		@NewValue		Nvarchar(100),
		@Query			Nvarchar(MAX),
		@Table			Nvarchar(20),
		@Column			Nvarchar(50)

DECLARE	@tblResults		Table (
		TableName		Nvarchar(30),
		ColumnName		Nvarchar(50), 
		ColumnValue		Nvarchar(3630))

SET NOCOUNT ON

--EXECUTE	@NewValue = GPCustom.dbo.USP_FindNextVendorIdforGP

DECLARE	@TableName		Nvarchar(256) = '', 
		@ColumnName		Nvarchar(128), 
		@SearchStr2		Nvarchar(110) = QUOTENAME('%' + @SearchStr + '%','''')

WHILE @TableName IS NOT NULL
BEGIN
	SET @ColumnName = ''
	SET @TableName = (	SELECT	MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
						FROM 	Information_Schema.Tables
						WHERE 	TABLE_TYPE = 'BASE TABLE'
								AND	QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TableName
								AND	OBJECTPROPERTY(OBJECT_ID(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)), 'IsMSShipped') = 0)
								--AND TABLE_NAME lIKE 'RM%')

	WHILE (@TableName IS NOT NULL) AND (@ColumnName IS NOT NULL)
	BEGIN
		SET @ColumnName = (	SELECT	MIN(QUOTENAME(COLUMN_NAME))
							FROM 	Information_Schema.Columns
							WHERE 	TABLE_SCHEMA = PARSENAME(@TableName, 2)
									AND	TABLE_NAME = PARSENAME(@TableName, 1)
									AND	DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar')
									AND	QUOTENAME(COLUMN_NAME) > @ColumnName)
	
		IF @ColumnName IS NOT NULL
		BEGIN
			INSERT INTO @tblResults
			EXEC ('SELECT ''' + @TableName + ''',''' + @ColumnName + ''', RTRIM(LEFT(' + @ColumnName + ', 3630)) 
				FROM ' + @TableName + ' (NOLOCK)  WHERE ' + @ColumnName + ' LIKE ' + @SearchStr2)

			--print 'SELECT ''' + @TableName + ''',''' + @ColumnName + ''', RTRIM(LEFT(' + @ColumnName + ', 3630)) FROM ' + @TableName + ' (NOLOCK)  WHERE ' + @ColumnName + ' LIKE ' + @SearchStr2
		END
	END	
END

SELECT	DISTINCT *
FROM	@tblResults

--DECLARE curTables CURSOR LOCAL KEYSET OPTIMISTIC FOR
--SELECT	DISTINCT RTRIM(TableName), RTRIM(ColumnName)
--FROM	@tblResults

--OPEN curTables 
--FETCH FROM curTables INTO @Table, @Column

--WHILE @@FETCH_STATUS = 0 
--BEGIN
--	SET @Query = N'UPDATE ' + DB_NAME() + '.' + @Table + ' SET ' + @Column + ' = ''' + RTRIM(@NewValue) + ''' WHERE ' + @Column + ' = ''' + RTRIM(@SearchStr) + ''''
	
--	PRINT @Query

--	FETCH FROM curTables INTO @Table, @Column
--END

--CLOSE curTables
--DEALLOCATE curTables
--GO