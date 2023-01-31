-- EXECUTE USP_Report_EscrowDetailTrialBalance 'IMC', 3, '0-00-2795', '3/1/2008', '5/20/2008', NULL, 'CFLORES', 1, 1
/*
SELECT	E1.AccountNumber, E1.VendorId, SUM(E1.Amount) AS Balance 
FROM	EscrowTransactions E1 WHERE E1.AccountNumber = '0-00-2795' AND CompanyId = 'IMC' AND Fk_EscrowModuleId = 3 AND E1.PostingDate < '03/01/2008' GROUP BY E1.AccountNumber, E1.VendorId
*/
SELECT	DISTINCT ET.*, 
		COALESCE(G0.Refrence, P0.DistRef, P1.TrxDscrn, P2.TrxDscrn, ET.Comments, ' ') AS TransDescription, 
		CmpnyNam AS CompanyName, 
		VendName, 
		ISNULL(BA.Balance, 0.00) AS Balance, 
		UPPER(GL.ActDescr) AS ActDescr, 
		PV.ProNumber AS ProNumberMain, 
		PV.ChassisNumber, 
		PV.TrailerNumber, 
		COALESCE(P1.DocNumbr, P2.DocNumbr, ET.InvoiceNumber, ' ') AS DocNumber, 
		ET.PostingDate, 
		'CFLORES' AS UserId, 
		EM.ModuleDescription AS Module
FROM	EscrowTransactions ET
		LEFT JOIN EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId 
		LEFT JOIN Purchasing_Vouchers PV ON ET.CompanyId = PV.CompanyId AND ET.VoucherNumber = PV.VoucherNumber 
		LEFT JOIN EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
		LEFT JOIN IMC.dbo.PM30600 P0 ON ET.VoucherNumber = P0.Vchrnmbr AND ET.AccountType = P0.DistType AND ET.ItemNumber = P0.DstSqNum
		LEFT JOIN IMC.dbo.PM20000 P1 ON P0.Vchrnmbr = P1.Vchrnmbr AND (P0.VendorId = P1.VendorId OR ET.VendorId = P1.VendorId)
		LEFT JOIN IMC.dbo.PM30200 P2 ON P0.Vchrnmbr = P2.Vchrnmbr AND (P0.VendorId = P2.VendorId OR ET.VendorId = P2.VendorId)
		LEFT JOIN IMC.dbo.GL30000 G0 ON ET.VoucherNumber = CAST(G0.JrnEntry AS Char(20)) AND G0.SourcDoc <> 'PMTRX'
		LEFT JOIN IMC.dbo.PM00200 VE ON ET.VendorId = VE.VendorId
		LEFT JOIN IMC.dbo.GL00100 GL ON EA.AccountIndex = GL.ActIndx 
		LEFT JOIN Dynamics.dbo.View_AllCompanies CO ON ET.CompanyID = CO.InterID
		FULL OUTER JOIN (	SELECT	E1.AccountNumber, 
									E1.VendorId, 
									SUM(E1.Amount) AS Balance 
							FROM	EscrowTransactions E1 
							WHERE	E1.AccountNumber = '0-00-2795' AND	
									CompanyId = 'IMC' AND 
									Fk_EscrowModuleId = 3 AND 
									E1.PostingDate < '03/01/2008' 
							GROUP BY E1.AccountNumber, E1.VendorId) BA ON ET.AccountNumber = BA.AccountNumber AND ET.VendorId = BA.VendorId 
WHERE	ET.AccountNumber = '0-00-2795' AND 
		ET.CompanyId = 'IMC' AND 
		ET.Fk_EscrowModuleId = 3 AND 
		ET.PostingDate BETWEEN '03/01/2008' AND '05/20/2008 11:59:59 PM' AND 
		ET.PostingDate IS NOT Null 
ORDER BY 
		ET.AccountNumber, 
		ET.VendorId, 
		ET.PostingDate, 
		ET.VoucherNumber

DECLARE	@CompanyName	Varchar(50)
SET		@CompanyName = (SELECT CmpnyNam FROM Dynamics.dbo.View_AllCompanies where InterID = 'IMC')

SELECT	'BALANCE', 
		'IMC', 
		'BALANCE' + ET.VendorId, 
		ET.AccountNumber, 
		ET.VendorId, 
		VE.VendName, 
		'CFLORES', 
		SUM(ET.Amount) AS Balance, 
		EM.ModuleDescription, 
		@CompanyName AS CmpnyNam
FROM	EscrowTransactions ET
		INNER JOIN EscrowModules EM ON ET.Fk_EscrowModuleId = EM.EscrowModuleId
		INNER JOIN IMC.dbo.PM00200 VE ON ET.VendorId = VE.VendorId
		LEFT JOIN EscrowBalancesReport EB ON ET.AccountNumber = EB.AccountNumber AND ET.VendorId = EB.VendorId AND EB.UserId = 'CFLORES'
WHERE	ET.AccountNumber = '0-00-2795' AND 
		ET.CompanyId = 'IMC' AND 
		ET.PostingDate IS NOT Null AND 
		ET.Fk_EscrowModuleId = 3 AND 
		ET.PostingDate < '03/01/2008' AND 
		EB.AccountNumber IS NULL
GROUP BY 
		ET.AccountNumber, 
		ET.VendorId,
		VE.VendName,
		EM.ModuleDescription

SELECT	ET.*
FROM	EscrowTransactions ET
		INNER JOIN EscrowModules EM ON ET.Fk_EscrowModuleId = EM.EscrowModuleId
WHERE	ET.AccountNumber = '0-00-2795' AND 
		ET.CompanyId = 'IMC' AND 
		ET.PostingDate IS NOT Null AND 
		ET.Fk_EscrowModuleId = 3 AND 
		ET.PostingDate < '03/01/2008' 
		--ET.AccountNumber + ET.VendorId NOT IN (SELECT AccountNumber + VendorId FROM EscrowBalancesReport WHERE UserId = 'CFLORES') 
GROUP BY 
		ET.AccountNumber, 
		ET.VendorId,
		VendName
		EM.ModuleDescription

SELECT	AccountNumber,
		VendorId,
		SUM(Amount) AS Balance
FROM	EscrowTransactions 
WHERE	CompanyId = 'IMC' AND 
		Fk_EscrowModuleId = 3 AND 
		AccountNumber = '0-00-2795' AND
		AccountNumber + VendorId NOT IN (SELECT AccountNumber + VendorId FROM EscrowBalancesReport WHERE UserId = 'CFLORES')
GROUP BY
		AccountNumber,
		VendorId

truncate table EscrowBalancesReport