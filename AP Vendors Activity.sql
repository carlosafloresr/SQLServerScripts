DECLARE	@Company	Varchar(5),
		@Query		Varchar(Max)

DECLARE @tblVendors	Table (
		Company		Varchar(5),
		VendorId	Varchar(15),
		VendorName	Varchar(100),
		TaxId		Varchar(20))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(InterId) AS Company
FROM	Dynamics.dbo.View_AllCompanies 
WHERE	InterId NOT IN ('ATEST','ABS','HIS01','HIS04','ITEST')

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Company

	SET @Query = 'SELECT ''' + @Company + ''', VENDORID, VENDNAME, IIF(TXIDNMBR = '''', VENDORID, TXIDNMBR) FROM ' + @Company + '.dbo.PM00200 ORDER BY VENDORID'
	
	INSERT INTO @tblVendors
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

SELECT	*
FROM	@tblVendors
ORDER BY TaxId