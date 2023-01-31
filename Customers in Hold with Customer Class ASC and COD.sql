DECLARE @Company	Varchar(5),
		@Query		Varchar(500)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CompanyID
FROM	DYNAMICS.dbo.View_Companies
WHERE	CompanyID <> 'ABS'
ORDER BY CompanyID

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT CUSTNMBR, CUSTNAME, HOLD FROM ' + RTRIM(@Company) + '.dbo.RM00101 WHERE CUSTCLAS IN (''ASC'',''COD'') ORDER BY CUSTNMBR'
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies