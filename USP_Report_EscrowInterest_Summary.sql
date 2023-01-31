ALTER PROCEDURE USP_Report_EscrowInterest_Summary
	@CompanyId	Char(6), 
	@AccountIndex	Int, 
	@DriverClass	Char(3),
	@Period		Char(6),
	@DriverId	Char(10) = Null
AS
DECLARE	@Query		Varchar(4000)

IF @DriverId IS Null
SET	@Query		= 'SELECT EI.AccountNumber AS Account, CAST(CASE WHEN PM.Ten99Type = 4 THEN 1 ELSE 0 END AS Bit) AS IS1099, EI.VendorId, SUM(Ei.InterestAmount) AS Amount FROM ' + 
	'GPCustom.dbo.EscrowInterest EI INNER JOIN ' + RTRIM(@CompanyId) + '.dbo.PM00200 PM ON PM.VendorId = EI.VendorId ' +
	'WHERE EI.AccountIndex = ' + RTRIM(CAST(@AccountIndex AS Char(8))) + ' AND ' + 'EI.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND DriverClass = ''' + @DriverClass + '''' +
	' GROUP BY EI.AccountNumber, CAST(CASE WHEN PM.Ten99Type = 4 THEN 1 ELSE 0 END AS Bit), EI.VendorId'
ELSE
SET	@Query		= 'SELECT EI.AccountNumber AS Account, CAST(CASE WHEN PM.Ten99Type = 4 THEN 1 ELSE 0 END AS Bit) AS IS1099, SUM(Ei.InterestAmount) AS Amount FROM ' + 
	'GPCustom.dbo.EscrowInterest EI INNER JOIN ' + RTRIM(@CompanyId) + '.dbo.PM00200 PM ON PM.VendorId = EI.VendorId ' +
	'WHERE EI.AccountIndex = ' + RTRIM(CAST(@AccountIndex AS Char(8))) + ' AND ' + 'EI.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND DriverClass = ''' + @DriverClass + '''' +
	' AND EI.VendorId = ''' + @DriverId + ''' GROUP BY EI.AccountNumber, CAST(CASE WHEN PM.Ten99Type = 4 THEN 1 ELSE 0 END AS Bit)'

PRINT @Query
EXECUTE (@Query)

GO
