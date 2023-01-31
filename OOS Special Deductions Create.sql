DECLARE	@DeductionCode	Varchar(10) = 'DUPL_PYMNT',
		@Description	Varchar(50) = 'Duplicate Payment Deduction',
		@AccountCredit	Varchar(15) = '0-00-1100',
		@AccountDebit	Varchar(15) = '0-00-2050',
		@GLAccount		Varchar(15),
		@IndexCredit	Int,
		@IndexDebit		Int,
		@Company		Varchar(5),
		@Query			Varchar(MAX)

DECLARE	@tblAccount		Table (
		AccountIndex	Int,
		AccountNumber	Varchar(15))

DECLARE	@tblDeductions	Table (
		Company			Varchar(5),
		CreditIndex		Int Null,
		CreditAccount	Varchar(15) Null,
		DebitIndex		Int Null,
		DebitAccount	Varchar(15) Null)

INSERT INTO @tblDeductions (Company)
SELECT	DISTINCT CompanyId
FROM	Companies
WHERE	Trucking = 1
		AND WithDrivers = 1
		AND IsTest = 0
		AND CompanyId = 'IMC'
		--AND CompanyId NOT IN (SELECT Company FROM OOS_DeductionTypes WHERE DeductionCode = 'FUELTAX')

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT CompanyId
FROM	Companies
WHERE	Trucking = 1
		AND WithDrivers = 1
		AND IsTest = 0
		AND CompanyId = 'IMC'
		--AND CompanyId NOT IN (SELECT Company FROM OOS_DeductionTypes WHERE DeductionCode = 'FUELTAX')

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblAccount

	SET @GLAccount	= CASE WHEN @Company = 'NDS' THEN '0' + @AccountCredit ELSE @AccountCredit END
	SET @Query		= 'SELECT ACTINDX, ''' + RTRIM(@GLAccount) + ''' FROM ' + RTRIM(@Company) + '.dbo.GL00105 WHERE ACTNUMST = ''' + RTRIM(@GLAccount) + ''''

	INSERT INTO @tblAccount
	EXECUTE(@Query)

	UPDATE	@tblDeductions
	SET		CreditIndex		= ACT.AccountIndex,
			CreditAccount	= ACT.AccountNumber
	FROM	@tblAccount ACT
	WHERE	Company = @Company

	DELETE @tblAccount

	SET @GLAccount	= CASE WHEN @Company = 'NDS' THEN '0' + @AccountDebit ELSE @AccountDebit END
	SET @Query		= 'SELECT ACTINDX, ''' + RTRIM(@GLAccount) + ''' FROM ' + RTRIM(@Company) + '.dbo.GL00105 WHERE ACTNUMST = ''' + RTRIM(@GLAccount) + ''''

	INSERT INTO @tblAccount
	EXECUTE(@Query)

	SELECT	@IndexDebit = AccountIndex
	FROM	@tblAccount
	WHERE	AccountNumber = @AccountDebit

	UPDATE	@tblDeductions
	SET		DebitIndex		= ACT.AccountIndex,
			DebitAccount	= ACT.AccountNumber
	FROM	@tblAccount ACT
	WHERE	Company = @Company

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

INSERT INTO OOS_DeductionTypes
		(Company,
		DeductionCode,
		Description,
		CrdAccounts,
		DebAccounts,
		CrdAcctIndex,
		CreditAccount,
		CreditPercentage,
		DebAcctIndex,
		DebitAccount,
		DebitPercentage,
		Frequency,
		CreatedBy,
		ModifiedBy,
		DeductionType,
		SpecialDeduction)
SELECT	Company,
		@DeductionCode AS DeductionCode,
		@Description,
		1 AS CrdAccounts,
		1 AS DebAccounts,
		CreditIndex,
		CreditAccount,
		100 AS CreditPercentage,
		DebitIndex,
		DebitAccount,
		100 AS DebitPercentage,
		'W' AS Frequency,
		'CFLORES' AS CreatedBy,
		'CFLORES' AS ModifiedBy,
		'OTHER' AS DeductionType,
		1 AS SpecialDeduction
FROM	@tblDeductions