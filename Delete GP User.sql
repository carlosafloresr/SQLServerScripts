DECLARE @UserId		Varchar(30),
		@Company	Varchar(5),
		@Query		Varchar(500)

SET @UserId = 'bbista'

DECLARE Transaction_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(InterId)
FROM	DYNAMICS.dbo.View_AllCompanies

OPEN Transaction_Companies 
FETCH FROM Transaction_Companies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Company

	SET @Query = N'DELETE ' + @Company + '.dbo.SY01401 WHERE USERID = ''' + @UserId + ''''
		
	EXECUTE(@Query)

	FETCH FROM Transaction_Companies INTO @Company
END

CLOSE Transaction_Companies
DEALLOCATE Transaction_Companies

