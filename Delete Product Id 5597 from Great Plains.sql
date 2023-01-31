DELETE	DYNAMICS.dbo.DB_Upgrade 
WHERE	PRODID = 5597
GO

DELETE	DYNAMICS.dbo.DU000020 
WHERE	PRODID = 5597
GO

DELETE	DYNAMICS.dbo.DU000030 
WHERE	PRODID = 5597
GO

DECLARE	@Company	Varchar(5),
		@Query		Varchar(2000)

DECLARE OOS_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	InterId
FROM	DYNAMICS.dbo.View_AllCompanies

OPEN OOS_Companies 
FETCH FROM OOS_Companies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Company: ' + @Company
	SET @Query = 'DROP TABLE ' + @Company + '.dbo.SEE30303'
	EXECUTE(@Query)

	FETCH FROM OOS_Companies INTO @Company
END

CLOSE OOS_Companies
DEALLOCATE OOS_Companies
GO