ALTER PROCEDURE USP_Report_EscrowDetailTrialBalance
	@CompanyId	Char(6), 
	@EscrowModule	Int,
	@Account	Char(15),
	@DateIni	SmallDateTime,
	@DateEnd	SmallDateTime,
	@VendorId	Char(10) = Null
AS
DECLARE	@IniDate	Char(10),
	@EndDate	Char(22),
	@Query		Varchar(5000),
	@Query2		Varchar(1000),
	@Query3		Varchar(3000)

IF @Account IS Null
	SET	@Query2 = ''
ELSE
	SET	@Query2 = 'ET.AccountNumber = ''' + RTRIM(@Account) + ''' AND '

SET	@IniDate	= CONVERT(Char(10), @DateIni, 101)
SET	@EndDate	= CONVERT(Char(10), @DateEnd, 101) + ' 11:59:59 PM'

SET	@Query3		= 'SELECT E1.AccountNumber, E1.VendorId, SUM(E1.Amount) AS Balance 
	FROM EscrowTransactions E1
	LEFT JOIN ' + @CompanyId + '.dbo.PM20000 P1 ON VoucherNumber = P1.Vchrnmbr 
	LEFT JOIN ' + @CompanyId + '.dbo.PM10000 P2 ON VoucherNumber = P2.VchnumWk 
	WHERE CompanyId = ''' + RTRIM(@CompanyId) + ''' AND Fk_EscrowModuleId = ' + 
	RTRIM(CAST(@EscrowModule AS Char(10))) + ' AND COALESCE(P2.PstgDate, P1.PosteDDT, E1.TransactionDate) < ''' + @IniDate + ''' GROUP BY E1.AccountNumber, E1.VendorId'

SET 	@Query 		= 'SELECT ET.*, COALESCE(P2.TrxDscrn, P1.TrxDscrn, '' '') AS TransDescription, CmpnyNam AS CompanyName, LEFT(dbo.PROPER(VendName), 40) AS VendName, ISNULL(BA.Balance, 0.00) AS Balance, UPPER(GL.ActDescr) AS ActDescr, 
	PV.ProNumber, PV.ChassisNumber, PV.TrailerNumber, COALESCE(P1.DocNumbr, P1.DocNumbr , '' '') AS DocNumber, COALESCE(P2.PstgDate, P1.PosteDDT, ET.TransactionDate) AS PostDate FROM EscrowTransactions ET
	LEFT JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId 
	LEFT JOIN Purchasing_Vouchers PV ON ET.CompanyId = PV.CompanyId AND ET.VoucherNumber =  PV.VoucherNumber 
	LEFT JOIN ' + @CompanyId + '.dbo.PM20000 P1 ON ET.VoucherNumber = P1.Vchrnmbr 
	LEFT JOIN ' + @CompanyId + '.dbo.PM10000 P2 ON ET.VoucherNumber = P2.VchnumWk 
	LEFT JOIN ' + @CompanyId + '.dbo.PM00200 VE ON ET.VendorId = VE.VendorId
	LEFT JOIN ' + @CompanyId + '.dbo.GL00100 GL ON EA.AccountIndex = GL.ActIndx 
	LEFT JOIN Dynamics.dbo.View_AllCompanies CO ON ET.CompanyID = CO.InterID 
	LEFT JOIN (' + @Query3 + ') BA ON ET.AccountNumber = BA.AccountNumber AND ET.VendorId = BA.VendorId WHERE ' + 
	@Query2 + 'ET.CompanyId = ''' + RTRIM(@CompanyId) + ''' AND ET.Fk_EscrowModuleId = ' + RTRIM(CAST(@EscrowModule AS Char(10))) +
	' AND COALESCE(P2.PstgDate, P1.PosteDDT, ET.TransactionDate) BETWEEN ''' + @IniDate + ''' AND ''' + @EndDate + ''' ORDER BY ET.AccountNumber, ET.VendorId, ET.TransactionDate, ET.VoucherNumber'

EXECUTE (@Query)


GO
