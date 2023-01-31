DECLARE	@Query		Varchar(1000),
		@Company	Varchar(5)

DECLARE	@tblBatches	Table
		(COMPANY	Varchar(5),
		BACHNUMB	Varchar(25), 
		MKDTOPST	Smallint, 
		CHKSPRTD	Smallint, 
		BCHSOURC	Varchar(25), 
		USERID		Varchar(25),
		GLPOSTDT	Date)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CompanyID 
FROM	DYNAMICS.dbo.View_Companies 
WHERE	CompanyID NOT IN ('ATEST','FIDMO','RCMR') 
ORDER BY CompanyID

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT ''' + RTRIM(@Company) + ''' AS Company, BACHNUMB, MKDTOPST, CHKSPRTD, BCHSOURC, USERID, GLPOSTDT FROM ' + RTRIM(@Company) + '.dbo.SY00500 WHERE BACHNUMB NOT IN ('''', ''dweaver'')'
	
	INSERT INTO @tblBatches
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

SELECT	*
FROM	@tblBatches
WHERE	MKDTOPST = 1
		OR CHKSPRTD = 1