DECLARE	@Company		Varchar(5),
		@CompanyAlias	Varchar(10),
		@Query			Varchar(MAX)

DECLARE	@tblCustomers	Table (
		Company			Varchar(5),
		VendorId		Varchar(12),
		Vendor_Name		Varchar(100),
		Ten99Amount		Numeric(10,2))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CompanyID) AS CompanyId
FROM	DYNAMICS.dbo.View_Companies
WHERE	CompanyID NOT IN ('FI', 'NDS', 'ATEST')
ORDER BY 1

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT ''' + @Company + ''' AS Company,
		RTRIM(APH.VENDORID) AS VENDORID,
		RTRIM(VND.VENDNAME) AS NAME,
		SUM(APH.TEN99AMNT * IIF(APH.DOCTYPE < 5, 1, -1)) AS TEN99AMNT
FROM	' + @Company + '.dbo.PM30200 APH
		INNER JOIN ' + @Company + '.dbo.PM00200 VND ON APH.VENDORID = VND.VENDORID
WHERE	APH.TEN99AMNT <> 0
		AND APH.DOCDATE BETWEEN ''01/01/2020'' AND ''12/31/2020''
		AND VND.TEN99TYPE < 2
GROUP BY APH.VENDORID, VND.VENDNAME'

	PRINT @Query

	INSERT INTO @tblCustomers
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

SELECT	*
FROM	@tblCustomers
ORDER BY Company, VendorId
/*
UPDATE	PM30300
SET		TEN99AMNT = 0
WHERE	VENDORID IN ('1034','1245','292')
		AND TEN99AMNT <> 0
		AND DOCDATE BETWEEN '01/01/2020' AND '05/04/2021'
*/