USE [GPCustom]
GO

SET NOCOUNT ON

DECLARE	@Company		Varchar(5),
		@RecordId		Varchar(20),
		@Folder			Varchar(100),
		@RecordType		Varchar(10),
		@Query			Varchar(Max),
		@RunUpdate		Bit = 1

DECLARE	@tblCheckBooks	Table (
		Company		Varchar(5),
		RecordId	Varchar(20),
		Folder		Varchar(100),
		RecordType	Varchar(10))

DECLARE curCheckBooks CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	InterId
FROM	DYNAMICS.dbo.View_AllCompanies
WHERE	InterId NOT IN ('ATEST','RCMR')

OPEN curCheckBooks 
FETCH FROM curCheckBooks INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'SELECT ''' + RTRIM(@Company) + ''' AS Company,
				BANKID,
				UPPER(DLFILAPTH) AS DLFILAPTH,
				''SAFEPAY'' AS RecordType
		FROM	' + RTRIM(@Company) + '.dbo.ME123501 
		WHERE	DLFILAPTH LIKE ''%\\%''
				OR DLFILAPTH LIKE ''%//%'''

	INSERT INTO @tblCheckBooks
	EXECUTE(@Query)

	SET @Query = 'SELECT ''' + RTRIM(@Company) + ''' AS Company,
				CHEKBKID,
				UPPER(DomPmtsFile),
				''EFT'' AS RecordType
		FROM	' + RTRIM(@Company) + '.dbo.CM00101 
		WHERE	DomPmtsFile LIKE ''%\\%'''

	INSERT INTO @tblCheckBooks
	EXECUTE(@Query)

	SET @Query = 'SELECT ''' + RTRIM(@Company) + ''' AS Company,
				CHEKBKID,
				UPPER(EFTPMPrenoteFile),
				''PRE-NOTE'' AS RecordType
		FROM	' + RTRIM(@Company) + '.dbo.CM00101 
		WHERE	EFTPMPrenoteFile LIKE ''%\\%''
				OR EFTPMPrenoteFile LIKE ''%//%'''

	INSERT INTO @tblCheckBooks
	EXECUTE(@Query)
	
	FETCH FROM curCheckBooks INTO @Company
END

CLOSE curCheckBooks
DEALLOCATE curCheckBooks

-- SCRIPT FOR UPDATES

SELECT	Company, 
		RecordId, 
		RTRIM(Folder) AS Folder, 
		RecordType
FROM	@tblCheckBooks
ORDER BY
		Company,
		RecordId,
		RecordType

DECLARE curDateToUpdate CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company, 
		RecordId, 
		RTRIM(Folder) AS Folder, 
		RecordType
FROM	@tblCheckBooks
ORDER BY
		Company,
		RecordId,
		RecordType

OPEN curDateToUpdate 
FETCH FROM curDateToUpdate INTO @Company, @RecordId, @Folder, @RecordType

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF @RecordType = 'SAFEPAY'
	BEGIN
		SET @Query = 'UPDATE ' + RTRIM(@Company) + '.dbo.ME123501 '
		SET @Query = @Query + 'SET DLFILAPTH = ''' + REPLACE(@Folder, '\\PRIAPINT01P\FTP\SAFEPAY\', '\\PRIAPINT01P\BankFiles$\SafePay\') + ''' '
		SET @Query = @Query + 'WHERE BANKID = ''' + RTRIM(@RecordId) + ''''
		PRINT @Query
		PRINT ''

		IF @RunUpdate = 1
			EXECUTE(@Query)
	END

	IF @RecordType = 'EFT'
	BEGIN
			SET @Query = 'UPDATE ' + RTRIM(@Company) + '.dbo.CM00101
SET		DomPmtsFile = ''' + REPLACE(@Folder, '\\PRIAPINT01P\EFT_FILES\', '\\PRIAPINT01P\BankFiles$\EFT\') + '''
WHERE	CHEKBKID = ''' + RTRIM(@RecordId) + ''''
		PRINT @Query
		PRINT ''
		
		IF @RunUpdate = 1
			EXECUTE(@Query)
	END

	IF @RecordType = 'PRE-NOTE'
	BEGIN
		SET @Query = 'UPDATE ' + RTRIM(@Company) + '.dbo.CM00101
SET		EFTPMPrenoteFile = ''' + REPLACE(@Folder, '\\PRIAPINT01P\EFT_FILES\', '\\PRIAPINT01P\BankFiles$\EFT\') + '''
WHERE	CHEKBKID = ''' + RTRIM(@RecordId) + ''''
		PRINT @Query
		PRINT ''
		
		IF @RunUpdate = 1
			EXECUTE(@Query)

		SET @Query = 'UPDATE ' + RTRIM(@Company) + '.dbo.CM00101
SET		EFTPMPrenoteFile = ''' + REPLACE(@Folder, '//PRIAPINT01P/EFT_FILES/', '//PRIAPINT01P/BankFiles$/EFT/') + '''
WHERE	CHEKBKID = ''' + RTRIM(@RecordId) + ''''
		PRINT @Query
		PRINT ''
		
		IF @RunUpdate = 1
			EXECUTE(@Query)
	END
	
	FETCH FROM curDateToUpdate INTO @Company, @RecordId, @Folder, @RecordType
END

IF @RunUpdate = -1
BEGIN
	UPDATE	Parameters
	SET		VarC = UPPER(REPLACE(REPLACE(VarC, 'ILSINT01', 'PRIAPINT01P'), 'ILSINT02', 'PRIAPINT01P'))
	WHERE	ParameterCode IN ('SAFEPAYFILESFOLDER','EFT_TEXTFILESPATH')

	UPDATE	Parameters
	SET		VarC = 'AcctTreasuryManagement@imcc.com'
	WHERE	ParameterCode = 'EFT_EMAILGROUP'
END

CLOSE curDateToUpdate
DEALLOCATE curDateToUpdate