DECLARE	@ValueName		Varchar(30),
		@DataType		Varchar(15),
		@DefaultValue	Varchar(50),
		@Fields			Varchar(Max) = '',
		@Query			Varchar(Max) = '',
		@ManifestId		Int

DECLARE TableFields CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Fk_ManifestTypeId
		,DataType
		,ValueName
		,DefaultValue
FROM	ValueTypes
WHERE	Inactive = 0
ORDER BY 
		Fk_ManifestTypeId, 
		ValueName

OPEN TableFields
FETCH FROM TableFields INTO @ManifestId, @DataType, @ValueName, @DefaultValue

SET @Query	= 'CREATE TABLE ExtendedData (Fk_TransactionId Bigint, '
SET @Fields = ''

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Fields = @Fields + CASE WHEN @Fields = '' THEN '' ELSE ', ' END + 'F' + dbo.PADL(@ManifestId, 2, '0') + '_' + @ValueName + ' ' + @DataType + 
							CASE WHEN @DefaultValue IS Null THEN ' NULL' ELSE ' NOT NULL CONSTRAINT Const_ExtendedData_' + @ValueName + '_' + dbo.PADL(@ManifestId, 2, '0') + ' DEFAULT (' + dbo.QuotesRequired(@DataType) + @DefaultValue + dbo.QuotesRequired(@DataType) + ')' END
	
	FETCH FROM TableFields INTO @ManifestId, @DataType, @ValueName, @DefaultValue
END	

CLOSE TableFields
DEALLOCATE TableFields

SET @Query = @Query + @Fields + ')'

PRINT @Query

EXECUTE(@Query)