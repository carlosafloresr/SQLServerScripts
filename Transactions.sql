ALTER PROCEDURE USP_EscrowTransactions_List
	@CompanyId	Char(6), 
	@EscrowModule	Int = Null,
	@Account	Char(15) = Null,
	@DateIni	SmallDateTime = Null,
	@DateEnd	SmallDateTime = Null
AS
DECLARE	@Query		Varchar(5000),
	@IniDate	Char(10),
	@EndDate	Char(22)

SET	@IniDate	= CONVERT(Char(10), @DateIni, 101)
SET	@EndDate	= CONVERT(Char(10), @DateEnd, 101) + ' 11:59:59 PM'
SET	@Query		= 'SELECT EI.*, COALESCE(P1.TrxDscrn, P2.TrxDscrn, '' '') AS TransDescription, CAST(CASE WHEN Amount < 0 THEN ''Credit'' ELSE ''Debit'' END AS Char(6)) AS TranType FROM GPCustom.dbo.EscrowTransactions EI 
	LEFT JOIN ' + @CompanyId + '.dbo.PM20000 P1 ON EI.VoucherNumber = P1.Vchrnmbr LEFT JOIN ' + @CompanyId + '.dbo.PM10000 P2 ON EI.VoucherNumber = P2.VchnumWk WHERE EI.AccountNumber = ''' + 
	RTRIM(@Account) + ''' AND EI.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND Fk_EscrowModuleId = ' + RTRIM(CAST(@EscrowModule AS Char(10))) +
	' AND TransactionDate BETWEEN ''' + @IniDate + ''' AND ''' + @EndDate + ''' ORDER BY TransactionDate, VoucherNumber'

print @Query
EXECUTE (@Query)
GO

--EXECUTE USP_EscrowTransactions_List 'AISTE', 1, '0-00-2790', '08/01/2007', '08/10/2007'

/*
SELECT 	E1.*,
	ISNULL(P1.TrxDscrn, P2.TrxDscrn) AS TransDescription
FROM 	GPCustom.dbo.EscrowTransactions E1
	LEFT JOIN PM20000 P1 ON E1.VoucherNumber = P1.Vchrnmbr
	LEFT JOIN PM10000 P2 ON E1.VoucherNumber = P2.VchnumWk
*/