SET NOCOUNT ON

DECLARE	@Company		Varchar(5),
		@Account		Varchar(15), 
		@Description	Varchar(50),
		@Query			Varchar(MAX)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	distinct Company, Account, Description
FROM	IntercompanyReport_Accounts

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company, @Account, @Description

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'UPDATE ' + @Company + '.dbo.GL00100 SET ACTDESCR = ''' + @Description + ''' WHERE ACTINDX IN (SELECT ACTINDX FROM ' + @Company + '.dbo.GL00105 WHERE ACTNUMST = ''' + @Account + ''')'
	
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company, @Account, @Description
END

CLOSE curCompanies
DEALLOCATE curCompanies