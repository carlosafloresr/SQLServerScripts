SET NOCOUNT ON

DECLARE	@Company	Varchar(5),
		@Query		Varchar(MAX)

DECLARE @tblGLAccounts Table (Account Varchar(12), [Type] Char(2))

DECLARE @tblCpyAccounts Table (Company Varchar(5), GlAccount Varchar(12), [Description] Varchar(75), NewDescription Varchar(75))

INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-07-1100','AR')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-10-1100','AR')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-15-1100','AR')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-20-1100','AR')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-31-1100','AR')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-33-1100','AR')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-40-1100','AR')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-45-1100','AR')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-70-1100','AR')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-80-1100','AR')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-90-1100','AR')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-07-2100','AP')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-10-2100','AP')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-15-2100','AP')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-20-2100','AP')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-31-2100','AP')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-33-2100','AP')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-40-2100','AP')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-45-2100','AP')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-70-2100','AP')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-80-2100','AP')
INSERT INTO @tblGLAccounts (Account, Type) VALUES ('0-90-2100','AP')

SELECT	* 
INTO	##tmpGLAccounts 
FROM	@tblGLAccounts

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CompanyId
FROM	GPCustom.dbo.Companies
WHERE	Trucking = 1
		AND IsTest = 0
UNION
SELECT	'IMCC'
UNION
SELECT	'IILS'
UNION
SELECT	'GSA'

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Company

	SET @Query = 'SELECT ''' + IIF(@Company = 'IMCC', 'IMCH', IIF(@Company = 'IILS', 'IMCC', @Company)) + ''', RTRIM(GL5.ACTNUMST) AS ACTNUMST,
		RTRIM(GL1.ACTDESCR) AS ACTDESCR, ''''
	FROM	' + @Company + '.dbo.GL00100 GL1
	INNER JOIN ' + @Company + '.dbo.GL00105 GL5 ON GL1.ACTINDX = GL5.ACTINDX AND GL5.ACTNUMST IN (SELECT Account FROM ##tmpGLAccounts)'

	INSERT INTO @tblCpyAccounts
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

DROP TABLE ##tmpGLAccounts

UPDATE	@tblCpyAccounts
SET		NewDescription = REPLACE(LTRIM(RTRIM(Description)), 'IILS', 'IMCC')

UPDATE	@tblCpyAccounts
SET		NewDescription = REPLACE(NewDescription, 'ILS', 'IMCC')

UPDATE	@tblCpyAccounts
SET		NewDescription = REPLACE(NewDescription, '  ', ' ')

UPDATE	@tblCpyAccounts
SET		NewDescription = REPLACE(NewDescription, ', LLC-', '')

UPDATE	@tblCpyAccounts
SET		NewDescription = REPLACE(NewDescription, ', LLC', '')

UPDATE	@tblCpyAccounts
SET		NewDescription = REPLACE(NewDescription, ' Intermodal', '')

UPDATE	@tblCpyAccounts
SET		NewDescription = REPLACE(NewDescription, ' Services', '')

UPDATE	@tblCpyAccounts
SET		NewDescription = REPLACE(NewDescription, ' Solutions', '')

UPDATE	@tblCpyAccounts
SET		NewDescription = REPLACE(NewDescription, 'IGS', 'IMCNA')

UPDATE	@tblCpyAccounts
SET		NewDescription = REPLACE(NewDescription, 'IMC Global', 'IMCNA')

UPDATE	@tblCpyAccounts
SET		NewDescription = REPLACE(NewDescription, 'IMC Company', 'IMCNA')

UPDATE	@tblCpyAccounts
SET		NewDescription = LEFT(NewDescription, LEN(NewDescription) - 1)
WHERE	RIGHT(NewDescription, 1) = '-'

SELECT	*
FROM	@tblCpyAccounts