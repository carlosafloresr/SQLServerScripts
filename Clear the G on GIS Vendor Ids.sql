DECLARE	@VendorId		Varchar(30),
		@NewVendorId	Varchar(30),
		@TableName		Varchar(50),
		@Query			Varchar(2000),
		@CounterI		Int = 1,
		@CounterJ		Int = 1,
		@CharOptions	Char(9) = '123456789'

-- Find all non driver vendors beginning with "G"
DECLARE curVendors CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	RTRIM(VendorId)
	FROM	PM00200
	WHERE	VendorId LIKE 'G%'
			AND VndClsId <> 'DRV'
			AND VendorId = 'G0049'

OPEN curVendors
FETCH FROM curVendors INTO @VendorId

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @NewVendorId = CASE WHEN SUBSTRING(@VendorId, 2, 1) = '0' THEN '1' ELSE '' END + SUBSTRING(@VendorId, 2, LEN(@VendorId) - 1)

	-- Checks if the new Vendor Id without the "G" already exists
	WHILE EXISTS(SELECT VendorId FROM PM00200 WHERE VendorId = @NewVendorId)
	BEGIN
		SET @NewVendorId = SUBSTRING(@CharOptions, @CounterI, 1) + SUBSTRING(@VendorId, 2, LEN(@VendorId) - 1)
		SET @CounterI = @CounterI + 1

		IF @CounterI > 9
		BEGIN
			SET @CounterJ = @CounterJ + 1
			SET @CounterI = 1
		END
	END

	PRINT 'Vendor ' + @VendorId + ' changed to ' + @NewVendorId

	-- Find Tables with the column VendorId
	DECLARE curTables CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	SO.Name
		FROM	SYS.objects SO
				INNER JOIN SYS.all_columns SA ON SO.object_id = SA.object_id AND SA.Name = 'vendorid'
		WHERE	SO.type = 'U'
		ORDER BY SO.Name

	OPEN curTables
	FETCH FROM curTables INTO @TableName

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		-- Check if the table has rows for the selected vendor 
		SET @Query = N'IF EXISTS(SELECT VendorId FROM ' + RTRIM(@TableName) + ' WHERE VendorId = ''' + RTRIM(@VendorId) + ''') BEGIN SELECT * FROM ' + RTRIM(@TableName) + ' WHERE VendorId = ''' + RTRIM(@VendorId) + ''' END'
		
		--SET @Query = N'IF EXISTS(SELECT VendorId FROM ' + RTRIM(@TableName) + ' WHERE VendorId = ''' + RTRIM(@VendorId) + ''') BEGIN UPDATE ' + RTRIM(@TableName) + ' SET VendorId = ''' + RTRIM(@NewVendorId) + ''' WHERE VendorId = ''' + RTRIM(@VendorId) + ''' END'
		EXECUTE(@Query)

		FETCH FROM curTables INTO @TableName
	END

	CLOSE curTables
	DEALLOCATE curTables

	FETCH FROM curVendors INTO @VendorId
END

CLOSE curVendors
DEALLOCATE curVendors