DECLARE	@RecordId		Bigint,
		@ValueName		Varchar(30),
		@Value			Varchar(500),
		@DataType		Varchar(30),
		@DefaultValue	Varchar(50),
		@Query			Varchar(Max) = 'CREATE TABLE ##tblExtendedData (Fk_TransactionId Bigint, ',
		@Fields			Varchar(Max) = ''

DECLARE TableFields CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	ValueName,
		DataType,
		DefaultValue
FROM	ValueTypes
WHERE	Fk_ManifestTypeId = 1
		AND Inactive = 0

OPEN TableFields
FETCH FROM TableFields INTO @ValueName, @DataType, @DefaultValue

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Fields = @Fields + CASE WHEN @Fields = '' THEN '' ELSE ', ' END + @ValueName + ' ' + @DataType +  
							CASE WHEN @DefaultValue IS Null THEN ' NULL' ELSE ' NOT NULL CONSTRAINT tblExtendedData_' + @ValueName + ' DEFAULT (' + dbo.QuotesRequired(@DataType) + @DefaultValue + dbo.QuotesRequired(@DataType) + ')' END

	FETCH FROM TableFields INTO @ValueName, @DataType, @DefaultValue
END

SET @Query = @Query + @Fields + ')'

CLOSE TableFields
DEALLOCATE TableFields

EXECUTE(@Query)

DECLARE ExtraValues CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	AV.Fk_TransactionId,
		VT.ValueName,
		AV.AdditionalValue,
		VT.DataType
FROM	AdditionalValues AV
		INNER JOIN ValueTypes VT ON AV.Fk_ValueTypeId = VT.ValueTypeId

OPEN ExtraValues
FETCH FROM ExtraValues INTO @RecordId, @ValueName, @Value, @DataType

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF NOT EXISTS(SELECT Fk_TransactionId FROM ##tblExtendedData WHERE Fk_TransactionId = @RecordId)
		INSERT INTO ##tblExtendedData (Fk_TransactionId) VALUES (@RecordId)

	SET @Query = 'UPDATE ##tblExtendedData SET ' + @ValueName + ' = ' + dbo.QuotesRequired(@DataType) + @Value + dbo.QuotesRequired(@DataType) + ' WHERE Fk_TransactionId = ' + CAST(@RecordId AS Varchar)
	EXECUTE(@Query)
	FETCH FROM ExtraValues INTO @RecordId, @ValueName, @Value, @DataType
END

CLOSE ExtraValues
DEALLOCATE ExtraValues

SELECT * FROM ##tblExtendedData

DROP TABLE ##tblExtendedData

