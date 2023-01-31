DECLARE @Col01 Varchar(100),
	 @Query Varchar(Max)
SET @Col01 = (SELECT top 1 AccountAlias FROM EscrowAccounts WHERE CompanyiD = 'AIS' AND AccountNumber = '0-00-2790')

SET @Query = 'SELECT top 1 AccountAlias as [' + @Col01 + '] FROM EscrowAccounts WHERE CompanyiD = ''AIS'' AND AccountNumber = ''0-00-2790'''
--exec ( @query)

SELECT top 1 AccountAlias AS (@Col01) FROM EscrowAccounts WHERE CompanyiD = 'AIS'
