SET NOCOUNT ON

DECLARE	@DBSource	Varchar(5) = 'PTS',
		@DBTarget	Varchar(5) = 'PDS',
		@Delete		Bit = 1

DECLARE	@TableName	Varchar(75),
		@TableId	Int,
		@FieldName	Varchar(50),
		@Query		Varchar(Max),
		@Query2		Varchar(Max)

DECLARE @tblTables Table (TableName Varchar(75), TableId Int)

INSERT INTO @tblTables
SELECT	Name, object_id
FROM	SYS.Tables
WHERE	NAME IN ('RM00105','RM00201','SY01200')

DECLARE curTables CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	TableName, TableId
FROM	@tblTables

OPEN curTables 
FETCH FROM curTables INTO @TableName, @TableId

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = ''

	DECLARE curFields CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	Name AS FieldName 
	FROM	SYS.columns
	WHERE	object_id = @TableId
			AND Name NOT LIKE 'DEX_RWO_%'
			AND is_identity = 0
	ORDER BY Name

	OPEN curFields 
	FETCH FROM curFields INTO @FieldName

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @Query = @Query + IIF(@Query = '', '', ', ') + @FieldName + ''

		FETCH FROM curFields INTO @FieldName
	END

	CLOSE curFields
	DEALLOCATE curFields

	IF @Delete = 1
	BEGIN
		SET @Query2 = 'DELETE ' + @DBTarget + '.dbo.' + @TableName
		EXECUTE(@Query2)
	END

	SET @Query = 'INSERT INTO ' + @DBTarget + '.dbo.' + @TableName + ' (' + @Query + ') SELECT ' + @Query + ' FROM ' + @DBSource + '.dbo.' + @TableName

	PRINT @Query
	EXECUTE(@Query)

	FETCH FROM curTables INTO @TableName, @TableId
END

CLOSE curTables
DEALLOCATE curTables