CREATE PROCEDURE USP_DeleteOOSTemporalTables
AS
DECLARE	@TableName	Varchar(100),
		@Query		Varchar(MAX)

DECLARE OOS_Tables CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	name
FROM	sys.objects
WHERE	name LIKE 'OOS_OOS%'
		AND type_desc = 'USER_TABLE'
		AND create_date < GETDATE() - 3
ORDER BY create_date DESC

OPEN OOS_Tables 
FETCH FROM OOS_Tables INTO @TableName

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'DROP TABLE ' + @TableName

	EXECUTE(@Query)

	FETCH FROM OOS_Tables INTO @TableName
END

CLOSE OOS_Tables
DEALLOCATE OOS_Tables