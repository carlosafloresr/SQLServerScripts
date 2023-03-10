SELECT	[Company]
		,TransType
		,[LinkedCompany]
		,CASE WHEN [RecordType] = 'C' THEN'Customer' ELSE 'Vendor' END AS RecordType
		,[Account]
FROM	[Integrations].[dbo].[FSI_Intercompany_ARAP]
WHERE	TransType = 'ICB'
		AND Company = 'PTS'
		AND RecordType = 'C'
ORDER BY Company,TransType, LinkedCompany, RecordType, Account

SELECT	ForCompany AS Company,
		LinkedCompany,
		TransType,
		CASE WHEN LinkType = 'R' THEN 'Receivable' ELSE 'Payable' END AS LinkType,
		AccountNumber
FROM	FSI_Intercompany_Companies
WHERE	ForCompany = 'PTS'
		--AND LinkedCompany = 'GLSO'
order by Company, LinkedCompany, TransType, LinkType

/*
TRUNCATE TABLE FSI_Intercompany_ARAP
TRUNCATE TABLE FSI_Intercompany_Companies

INSERT INTO [Integrations].[dbo].[FSI_Intercompany_ARAP]
		(Company, LinkedCompany, RecordType, Account, ForGLIntegration, TransType)
SELECT	Company, LinkedCompany, RecordType, Account, ForGLIntegration, TransType
FROM	[PRISQL004P].[Integrations].[dbo].[FSI_Intercompany_ARAP]
WHERE	FSI_IntercompanyId IN (77,78,79,80,82)

INSERT INTO [Integrations].[dbo].[FSI_Intercompany_Companies]
		(ForCompany,
		LinkType,
		LinkedCompany,
		AccountIndex,
		AccountNumber,
		TransType)
SELECT	ForCompany,
		LinkType,
		LinkedCompany,
		AccountIndex,
		AccountNumber,
		TransType
FROM	[PRISQL004P].[Integrations].[dbo].[FSI_Intercompany_Companies]
*/

--SELECT	ForCompany,
--		LinkType,
--		LinkedCompany,
--		AccountIndex,
--		AccountNumber
--FROM	FSI_Intercompany_Companies

/*
DECLARE	@Company		Varchar(5),
		@AccountNumber	Varchar(15),
		@AccountIndex	Int,
		@Query			varchar(1000)

DECLARE	@tblAccount Table (AccountIndex Int)

DECLARE curRecords CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(ForCompany),
		RTRIM(AccountNumber)
FROM	FSI_Intercompany_Companies

OPEN curRecords 
FETCH FROM curRecords INTO @Company, @AccountNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT ACTINDX FROM [SECSQL01T].[' + @Company + '].[dbo].[GL00105] WHERE ACTNUMST = ''' + @AccountNumber + ''''
	
	PRINT @Query
	INSERT INTO @tblAccount
	EXECUTE(@Query)

	SET @AccountIndex = (SELECT AccountIndex FROM @tblAccount)

	UPDATE FSI_Intercompany_Companies SET AccountIndex = @AccountIndex WHERE ForCompany = @Company AND AccountNumber = @AccountNumber

	DELETE @tblAccount

	FETCH FROM curRecords INTO @Company, @AccountNumber
END

CLOSE curRecords
DEALLOCATE curRecords
*/