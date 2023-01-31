DECLARE	@Query		Varchar(MAX),
		@Company	Varchar(5)

DECLARE	@tblPosing	Table (
		Company		Varchar(5),
		GLAccount	Varchar(20),
		AccountIdx	Int,
		AcctIndex	Int,
		RowId		Int,
		PSTDesc		Varchar(100))

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CompanyId)
FROM	GPCustom.dbo.Companies
WHERE	IsTest = 0 AND CompanyId <> 'GSA'

OPEN curData 
FETCH FROM curData INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Checking company: ' + @Company
		SET @Query = N'SELECT ''' + @Company + ''' AS Company, RTRIM(GLA.ACTNUMST), GLA.ACTINDX, PST.ACTINDX, PST.DEX_ROW_ID, PST.PTGACDSC
		FROM	' + @Company + '.dbo.GL00105 GLA
				FULL OUTER JOIN ' + @Company + '.dbo.SY01100 PST ON PST.PTGACDSC = ''Discounts Taken''
		WHERE	GLA.ACTNUMST = ''0-00-6060'''
		
	PRINT @Query
	INSERT INTO @tblPosing
	EXECUTE(@Query)

	FETCH FROM curData INTO @Company
END

CLOSE curData
DEALLOCATE curData

SELECT	*
FROM	@tblPosing

/*
UPDATE	pds.dbo.SY01100
SET		ACTINDX = 777
WHERE	DEX_ROW_ID = 115
*/

