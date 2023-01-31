DECLARE	@ChangeType Char(1) = 'R', -- C: Clean Name / R: Restore Name
		@Company	Varchar(15) = DB_NAME(),
		@Query		Varchar(1000)

IF @ChangeType = 'C' -- Updates the Vendor Name to clean it
BEGIN
	DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	CompanyId
	FROM	GPCustom.dbo.Companies 
	WHERE	(@Company IS Null 
			AND Trucking = 1)
			OR (@Company IS NOT Null 
			AND CompanyId = @Company)
			

	OPEN curCompanies 
	FETCH FROM curCompanies INTO @Company

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		PRINT @Company

		SET @Query = 'DROP TABLE GPCustom.dbo.PM00200_' + @Company + '

		SELECT	*
		INTO	GPCustom.dbo.PM00200_' + @Company + '
		FROM	' + @Company + '.dbo.PM00200

		UPDATE	' + @Company + '.dbo.PM00200
		SET		VndChkNm = REPLACE(LEFT(VndChkNm, PATINDEX(''%'' + RTRIM(VendorId) + ''%'', VndChkNm) - 1), ''#'', '''')
		WHERE	PATINDEX(''%'' + RTRIM(VendorId) + ''%'', VndChkNm) > 0
				AND VndClsId = ''DRV'''

		EXECUTE(@Query)

		FETCH FROM curCompanies INTO @Company
	END

	CLOSE curCompanies
	DEALLOCATE curCompanies
END
ELSE
BEGIN
	DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	CompanyId
	FROM	GPCustom.dbo.Companies 
	WHERE	(@Company IS Null 
			AND Trucking = 1)
			OR (@Company IS NOT Null 
			AND CompanyId = @Company)

	OPEN curCompanies 
	FETCH FROM curCompanies INTO @Company

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		PRINT @Company

		SET @Query = 'UPDATE ' + @Company + '.dbo.PM00200
		SET		PM00200.VndChkNm = DATA.VndChkNm
		FROM	GPCustom.dbo.PM00200_' + @Company + ' DATA
		WHERE	PM00200.VendorId = DATA.VendorId'

		EXECUTE(@Query)

		FETCH FROM curCompanies INTO @Company
	END

	CLOSE curCompanies
	DEALLOCATE curCompanies
END