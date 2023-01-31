SET NOCOUNT ON

DECLARE	@Company	Varchar(5),
		@Alias		Varchar(10),
		@Query		Varchar(Max)

DECLARE @tblVendors	Table (
		Company		Varchar(5),
		VendorId	Varchar(15),
		VendorName	Varchar(100),
		Address1	Varchar(100),
		Address2	Varchar(100),
		City		Varchar(35),
		State		Varchar(35),
		TaxId		Varchar(20))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CompanyId) AS Company, CompanyAlias
FROM	View_CompanyAgents 
WHERE	CompanyId NOT IN ('ATEST','ABS','HIS01','HIS04','ITEST','IILS', 'NDS','GSA')
		AND Trucking = 1

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company, @Alias

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Company

	SET @Query = 'SELECT ''' + @Alias + ''', RTRIM(VENDORID), RTRIM(VENDNAME), RTRIM(ADDRESS1), RTRIM(ADDRESS1), RTRIM(CITY), RTRIM(STATE), TXIDNMBR FROM ' + @Company + '.dbo.PM00200 WHERE VENDSTTS = 1 AND VNDCLSID <> ''DRV'' AND VENDNAME <> ''ADP'' ORDER BY VENDORID'
	
	INSERT INTO @tblVendors
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company, @Alias
END

CLOSE curCompanies
DEALLOCATE curCompanies

SELECT	DISTINCT Company,
		VendorId, 
		VendorName,
		Address1,
		Address2,
		City,
		State,
		GPCustom.dbo.GenerateCodeText(TaxId) AS Encoded_TaxId
FROM	@tblVendors
WHERE	TaxId <> ''
ORDER BY 8, 1, 3
