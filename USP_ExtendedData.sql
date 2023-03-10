USE [Manifest]
GO
/****** Object:  StoredProcedure [dbo].[USP_ExtendedData]    Script Date: 5/15/2015 4:26:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_ExtendedData
*/
ALTER PROCEDURE [dbo].[USP_ExtendedData]
AS
DECLARE	@AdditionalValueId	Bigint,
		@Fk_TransactionId	Bigint,
		@AdditionalValue	Varchar(500),
		@FieldName			Varchar(30),
		@DataType			Varchar(15),
		@Query				Varchar(Max) = '',
		@EquipmentDetailId	Bigint,
		@EquipmentNumber	Varchar(20)

DECLARE CursorAddValues CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	AV.AdditionalValueId,
		AV.Fk_TransactionId,
		AV.AdditionalValue,
		'F' + dbo.PADL(VT.Fk_ManifestTypeId, 2, '0')  + '_' + VT.ValueName AS FieldName,
		VT.DataType
FROM	AdditionalValues AV
		INNER JOIN ValueTypes VT ON AV.Fk_ValueTypeId = VT.ValueTypeId
WHERE	AV.Migrated = 0

OPEN CursorAddValues
FETCH FROM CursorAddValues INTO @AdditionalValueId, @Fk_TransactionId, @AdditionalValue, @FieldName, @DataType

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF EXISTS(SELECT Fk_TransactionId FROM ExtendedData WHERE Fk_TransactionId = @Fk_TransactionId)
		SET @Query	= 'UPDATE ExtendedData SET ' + @FieldName + ' = ''' + RTRIM(@AdditionalValue) + ''' WHERE Fk_TransactionId = ' + CAST(@Fk_TransactionId AS Varchar)
	ELSE
		SET @Query	= 'INSERT INTO ExtendedData (Fk_TransactionId, ' + @FieldName + ') VALUES (' + CAST(@Fk_TransactionId AS Varchar) + ',''' + RTRIM(@AdditionalValue) + ''')'
	
	EXECUTE(@Query)
	
	UPDATE AdditionalValues SET Migrated = 1 WHERE AdditionalValueId = @AdditionalValueId

	FETCH FROM CursorAddValues INTO @AdditionalValueId, @Fk_TransactionId, @AdditionalValue, @FieldName, @DataType
END	

CLOSE CursorAddValues
DEALLOCATE CursorAddValues

DECLARE CursorEquipmentValues CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	ED.EquipmentDetailId,
		ED.Fk_TransactionId,
		ED.EquipmentNumber,
		ET.Description AS FieldName
FROM	EquipmentDetails ED
		INNER JOIN EquipmentTypes ET ON ED.Fk_EquipmentTypeId = ET.EquipmentTypeId
WHERE	Migrated = 0

OPEN CursorEquipmentValues
FETCH FROM CursorEquipmentValues INTO @EquipmentDetailId, @Fk_TransactionId, @EquipmentNumber, @FieldName

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF EXISTS(SELECT Fk_TransactionId FROM ExtendedData WHERE Fk_TransactionId = @Fk_TransactionId)
		SET @Query	= 'UPDATE ExtendedData SET ' + @FieldName + ' = ''' + RTRIM(@EquipmentNumber) + ''' WHERE Fk_TransactionId = ' + CAST(@Fk_TransactionId AS Varchar)
	ELSE
		SET @Query	= 'INSERT INTO ExtendedData (Fk_TransactionId, ' + @FieldName + ') VALUES (' + CAST(@Fk_TransactionId AS Varchar) + ',''' + RTRIM(@EquipmentNumber) + ''')'
	
	EXECUTE(@Query)
	
	UPDATE EquipmentDetails SET Migrated = 1 WHERE EquipmentDetailId = @EquipmentDetailId

	FETCH FROM CursorEquipmentValues INTO @EquipmentDetailId, @Fk_TransactionId, @EquipmentNumber, @FieldName
END	

CLOSE CursorEquipmentValues
DEALLOCATE CursorEquipmentValues