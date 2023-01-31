/*
EXECUTE USP_CustomerHoldsByClass
*/
ALTER PROCEDURE USP_CustomerHoldsByClass
AS
DECLARE	@Company	Varchar(5),
		@Query		Varchar(2000)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CompanyId
FROM	GPCustom.dbo.Companies 
WHERE	CompanyId <> 'ABS'

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query	 = 'UPDATE  ' + RTRIM(@Company) + '.dbo.RM00101
					SET		Hold = 1 
					WHERE	CUSTCLAS IN (''ASC'',''COD'')
							AND Inactive = 0
							AND Hold = 0'
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies