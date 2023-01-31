ALTER PROCEDURE USP_Report_EscrowInterest_Statement
	@CompanyId	Char(6), 
	@AccountIndex	Int, 
	@DriverClass	Char(3),
	@Period		Char(6)
AS
DECLARE	@Query		Varchar(4000)
SET	@Query		= 'SELECT EI.*, PM.VendName, CmpnyNam AS CompanyName, CASE WHEN PM.Ten99Type = 4 THEN ''YES'' ELSE ''NO'' END AS IS1099 FROM ' + 
	'GPCustom.dbo.EscrowInterest EI INNER JOIN ' + @CompanyId + '.dbo.PM00200 PM ON PM.VendorId = EI.VendorId ' +
	'LEFT JOIN Dynamics.dbo.View_AllCompanies CO ON EI.CompanyID = CO.InterID ' +
	'WHERE EI.AccountIndex = ' + RTRIM(CAST(@AccountIndex AS Char(8))) + ' AND ' + 'EI.CompanyId = ''' + @CompanyId + ''' AND DriverClass = ''' + @DriverClass + ''' ORDER BY EI.VendorId, EI.DateIni'
EXECUTE (@Query)
GO

EXECUTE USP_Report_EscrowInterest_Statement 'AISTE', 248, 'DDD', '200703'