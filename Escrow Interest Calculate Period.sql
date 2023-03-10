DECLARE	@CompanyId		Varchar(5),
		@AccountIndex	Int,
		@AccountNumber	Varchar(15),
		@Query			Varchar(Max)

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CompanyId,
		AccountIndex,
		AccountNumber
FROM	EscrowAccounts
WHERE	Fk_EscrowModuleId = 10
		AND CompanyId = 'AIS' --<> 'ATEST' --NOT IN ('AIS','DNJ','GIS','HMIS','ATEST')
ORDER BY CompanyId, AccountNumber

OPEN curData 
FETCH FROM curData INTO @CompanyId, @AccountIndex, @AccountNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Running for ' + @CompanyId + ' account ' + @AccountNumber

	EXECUTE USP_EscrowInterest_Calculation	@CompanyId, 
											@AccountIndex,
											@AccountNumber,
											'DRV',
											'12/30/2018',
											'04/06/2019',
											'201901',
											'CFLORES'
		
	EXECUTE(@Query)

	FETCH FROM curData INTO @CompanyId, @AccountIndex, @AccountNumber
END

CLOSE curData
DEALLOCATE curData