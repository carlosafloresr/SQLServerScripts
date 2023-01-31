DECLARE	@CompanyId	Varchar(5),
		@UserId		Varchar(25),
		@Query		Varchar(MAX)

DECLARE	@Companies	Table 
		(CompanyId	Int, 
		CompanyCode Varchar(5))

INSERT INTO @Companies
SELECT	CMPANYID, 
		INTERID
FROM	DYNAMICS.dbo.SY01500
WHERE	INTERID NOT IN ('ATEST','FIDMO')

SELECT	DISTINCT COM.CompanyCode, 
		USR.USERID
FROM	@Companies COM
		INNER JOIN SY10000 USR ON COM.CompanyId = USR.CMPANYID
WHERE	USR.DICTID = 0
		AND USR.SECRESTYPE = 23
ORDER BY 1, 2

--DECLARE curGPCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR


--OPEN curGPCompanies 
--FETCH FROM curGPCompanies INTO @CompanyId

--WHILE @@FETCH_STATUS = 0 
--BEGIN
--	PRINT 'Escrow updating ' + @CompanyId

--	SET @Query = @CompanyId + '.dbo.USP_UpdateEscrowTransactions'
		
--	EXECUTE(@Query)

--	FETCH FROM curGPCompanies INTO @CompanyId
--END

--CLOSE curGPCompanies
--DEALLOCATE curGPCompanies