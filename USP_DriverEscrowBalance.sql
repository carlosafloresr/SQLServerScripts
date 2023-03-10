USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_DriverEscrowBalance]    Script Date: 1/26/2022 9:37:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_DriverEscrowBalance 'AIS', '071411DSDRVCK', 'A0644', 'CFLORES'
EXECUTE USP_DriverEscrowBalance 'PTS', 'DSDR102417DD', '5468', 'CFLORES'
 071411DSDRVCK 071411DSDRVDD
"GPCustom"."dbo"."USP_Report_EscrowDetailTrialBalance";1 'AIS', 1, NULL, {ts '2011-07-08 08:10:17'}, {ts '2011-07-14 08:10:17'}, NULL, 'CFLORES', 0, 0, '071411DSDRVCK'
*/
ALTER PROCEDURE [dbo].[USP_DriverEscrowBalance]
		@Company		Varchar(5),
		@BatchId		Varchar(17),
		@DriverId		Varchar(15) = Null,
		@UserId			Varchar(25)
AS
DECLARE	@Year			Int,
		@Week			Int,
		@CpnyName		Varchar(40),
		@Driver			Varchar(10),
		@WeekEnd		Datetime,
		@WEndDate		Datetime,
		@CutoffDate		Datetime,
		@IsEFT			Int,
		@Note			Varchar(2000),
		@Query			Varchar(5000),
		@Query3			Varchar(5000),
		@QryVendor		Varchar(3000),
		@IniDate		Char(10),
		@EndDate		Char(22),
		@CompanyName	Varchar(50)

SET		@IsEFT		= (CASE WHEN PATINDEX('%DD%', @BatchId) > 0 THEN 1 ELSE 0 END)
SET		@WeekEnd	= (SELECT MAX(DocDate) FROM GPCustom.dbo.PM10300 WHERE Company = @Company AND BachNumb = @BatchId)

SET		@CpnyName	= RTRIM((SELECT TOP 1 CmpnyNam FROM Dynamics.dbo.View_AllCompanies WHERE Interid = @Company))
SET		@WEndDate	= (CASE	WHEN GPCustom.dbo.WeekDay(@WeekEnd) < 5 THEN @WeekEnd + (5 - GPCustom.dbo.WeekDay(@WeekEnd))
							WHEN GPCustom.dbo.WeekDay(@WeekEnd) = 5 THEN @WeekEnd
							ELSE @WeekEnd + (12 - GPCustom.dbo.WeekDay(@WeekEnd)) END)
SET		@Year		= YEAR(@WEndDate)
SET		@Week		= DATENAME(Week, @WEndDate)
SET		@CutoffDate = @WeekEnd
SET		@Query		= N'EXECUTE ' + @Company + '.dbo.USP_Driver_PayrollType ''' + @Company + ''',''' + CAST(@WEndDate AS Varchar) + ''',''' + @BatchId + ''',''' + @DriverId + ''',1,''' + @UserId + ''''

EXECUTE(@Query)

DELETE	GPCustom.dbo.EscrowBalancesReport 
WHERE	UserId = @UserId

SET	@IniDate		= CONVERT(Char(10), @WeekEnd - 6, 101)
SET	@EndDate		= CONVERT(Char(10), @WeekEnd, 101) + ' 11:59:59 PM'
SET	@CompanyName	= (SELECT CmpnyNam FROM Dynamics.dbo.View_AllCompanies WHERE InterID = @Company)

IF @DriverId IS Null
	SET	@QryVendor = ''
ELSE
	SET @QryVendor = 'ET.VendorId = ''' + RTRIM(@DriverId) + ''' AND '

SET @Query3		= 'SELECT E1.AccountNumber, E1.VendorId, SUM(E1.Amount) AS Balance FROM GPCustom.dbo.View_EscrowTransactions E1 WHERE CompanyId = ''' + @Company + ''' AND E1.DeletedOn IS Null 
	AND Fk_EscrowModuleId = 1 AND E1.PostingDate < ''' + @IniDate + ''' AND E1.DeletedBy IS Null GROUP BY E1.AccountNumber, E1.VendorId'
					
SET @Query 		= 'INSERT INTO GPCustom.dbo.EscrowBalancesReport SELECT DISTINCT ET.*, LEFT(COALESCE(G0.Refrence, P0.DistRef, P3.DistRef, P1.TrxDscrn, P2.TrxDscrn, ET.Comments, '' ''), 500) AS TransDescription, LEFT(CmpnyNam, 50) AS CompanyName, 
	LEFT(VendName, 50) AS VendName, ISNULL(BA.Balance, 0.00) AS Balance, UPPER(GL.ActDescr) AS ActDescr, 
	ET.ProNumber AS ProNumberMain, LEFT(COALESCE(P1.DocNumbr, P2.DocNumbr, ET.InvoiceNumber, '' ''), 20) AS DocNumber, ''' + @UserId + ''' AS UserId, LEFT(EM.ModuleDescription, 50) AS Module, 0
	FROM GPCustom.dbo.View_EscrowTransactions ET
	INNER JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId 
	INNER JOIN EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
	INNER JOIN Dynamics.dbo.View_AllCompanies CO ON ET.CompanyID = CO.InterID 
	INNER JOIN OOS_PayrollDrivers PYD ON ET.VendorId = PYD.VendorId AND ET.CompanyId = PYD.Company AND PYD.UserId = ''' + @UserId + '''
	LEFT JOIN ' + @Company + '.dbo.PM10100 P0 ON ET.VoucherNumber = P0.Vchrnmbr AND ET.AccountType = P0.DistType AND ET.ItemNumber = P0.DstSqNum AND EA.AccountIndex = P0.DstIndx
	LEFT JOIN ' + @Company + '.dbo.PM20000 P1 ON P0.Vchrnmbr = P1.Vchrnmbr AND (P0.VendorId = P1.VendorId OR ET.VendorId = P1.VendorId)
	LEFT JOIN ' + @Company + '.dbo.PM30600 P3 ON ET.VoucherNumber = P3.Vchrnmbr AND ET.AccountType = P3.DistType AND ET.ItemNumber = P3.DstSqNum
	LEFT JOIN ' + @Company + '.dbo.PM30200 P2 ON P3.Vchrnmbr = P2.Vchrnmbr AND (P3.VendorId = P2.VendorId OR ET.VendorId = P2.VendorId) AND P3.TrxSorce = P2.TrxSorce
	LEFT JOIN ' + @Company + '.dbo.GL30000 G0 ON ET.VoucherNumber = CAST(G0.JrnEntry AS Varchar(20)) AND G0.SourcDoc <> ''PMTRX'' AND EA.AccountIndex = G0.ActIndx AND ET.ItemNumber = G0.SeqNumbr
	LEFT JOIN ' + @Company + '.dbo.GL00100 GL ON EA.AccountIndex = GL.ActIndx 
	FULL OUTER JOIN (' + @Query3 + ') BA ON ET.AccountNumber = BA.AccountNumber AND ET.VendorId = BA.VendorId WHERE '
	
SET @Query		= @Query + 'ET.CompanyId = ''' + @Company + ''' AND ET.DeletedOn IS Null AND ET.Fk_EscrowModuleId = 1 AND ' +
	'ET.PostingDate BETWEEN ''' + @IniDate + ''' AND ''' + @EndDate + ''' AND ET.PostingDate IS NOT Null ORDER BY ET.AccountNumber, ET.VendorId, ET.PostingDate, ET.VoucherNumber'
	
EXECUTE (@Query)

SET	@Query3		= 'INSERT INTO GPCustom.dbo.EscrowBalancesReport (TransDescription, CompanyId, ClaimNumber, AccountNumber, VendorId, VendName, UserId, Balance, Module, CompanyName)
	SELECT DISTINCT ''BALANCE'', ''' + @Company + ''', ''BALANCE'' + ET.VendorId, ET.AccountNumber, ET.VendorId, PYD.VendName, ''' + @UserId + ''', SUM(ET.Amount) AS Balance, EM.ModuleDescription, ''' + @CompanyName + '''
	FROM GPCustom.dbo.View_EscrowTransactions ET
	LEFT JOIN EscrowModules EM ON ET.Fk_EscrowModuleId = EM.EscrowModuleId
	LEFT JOIN EscrowBalancesReport EB ON ET.AccountNumber = EB.AccountNumber AND ET.VendorId = EB.VendorId AND EB.UserId = ''' + @UserId + '''
	INNER JOIN OOS_PayrollDrivers PYD ON ET.VendorId = PYD.VendorId AND ET.CompanyId = PYD.Company AND PYD.UserId = ''' + @UserId + '''
	LEFT JOIN ' + @Company + '.dbo.PM20000 P1 ON ET.VoucherNumber = P1.Vchrnmbr 
	LEFT JOIN ' + @Company + '.dbo.PM10000 P2 ON ET.VoucherNumber = P2.VchnumWk 
	WHERE ' + 'ET.CompanyId = ''' + @Company + ''' AND ET.DeletedOn IS Null AND ET.PostingDate IS NOT Null AND ET.Fk_EscrowModuleId = 1 ' + 
	'AND ET.PostingDate < ''' + @IniDate + ''' AND EB.AccountNumber IS NULL 
	GROUP BY ET.AccountNumber, ET.VendorId, PYD.VendName, EM.ModuleDescription'

EXECUTE (@Query3)

SELECT 	DISTINCT *
		,CAST(dbo.ExtractInteger(ER.VendorId) AS Int) AS VendorNumber
		,VEM.HireDate
		,VEM.TerminationDate
		,CASE WHEN VEM.SubType = 1 THEN 'CO' ELSE 'MYT' END AS DriverType
FROM 	EscrowBalancesReport ER
		LEFT JOIN VendorMaster VEM ON ER.CompanyId = VEM.Company AND ER.VendorId = VEM.VendorId
WHERE 	ER.UserId = @UserId
		AND (SELECT COUNT(VoucherNumber) FROM EscrowBalancesReport E2 WHERE E2.UserId = @UserId AND E2.VendorId = ER.VendorId AND VoucherNumber IS NOT Null AND LEFT(VoucherNumber, 4) <> 'CESC') > 0
ORDER BY 
		ER.VendorId, 
		ER.PostingDate, 
		ER.EscrowTransactionId