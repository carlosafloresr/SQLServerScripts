DECLARE	@Query		Varchar(2000),
		@Company	Varchar(5)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT CompanyId
FROM	Companies
WHERE	Trucking = 1
		AND CompanyId NOT IN ('GLSO', 'DNJ', 'IGS', 'GSA', 'OIS')

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Company

	SET @Query = N'SELECT	*
					FROM	(
							SELECT	PM1.VendorId,
									REPLACE(LEFT(PM1.VndChkNm, PATINDEX(''%'' + RTRIM(PM1.VendorId) + ''%'', PM1.VndChkNm)), ''#'', '''') AS Current_CheckName,
									REPLACE(LEFT(PM2.VndChkNm, PATINDEX(''%'' + RTRIM(PM2.VendorId) + ''%'', PM2.VndChkNm)), ''#'', '''') AS Backup_CheckName,
									PM1.VndChkNm AS CurrentName,
									PM2.VndChkNm AS BackupName
							FROM	LENSASQL001.GPCustom.dbo.PM00200_' + RTRIM(@Company) + ' PM1
									INNER JOIN ' + RTRIM(@Company) + '.dbo.PM00200 PM2 ON PM1.VendorId = PM2.VendorId
							) DATA
					WHERE	Current_CheckName <> Backup_CheckName'
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies
