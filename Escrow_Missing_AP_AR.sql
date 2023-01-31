SELECT	ET.EscrowTransactionId,
		ISNULL(P1.DocNumbr, P2.DocNumbr) AS Vchrnmbr,
		ISNULL(P1.PostEddt, P2.PostEddt) AS PstgDate,
		ISNULL(P1.SeqNumbr, P2.SeqNumbr) AS DstSqNum
	FROM 	GPCustom.dbo.EscrowTransactions ET
		LEFT JOIN GPCustom.dbo.EscrowAccounts EA ON ET.AccountNumber = EA.AccountNumber AND ET.CompanyId = EA.CompanyId AND ET.Fk_EscrowModuleId = EA.Fk_EscrowModuleId 
		LEFT JOIN AIS.dbo.RM10101 P1 ON VoucherNumber = P1.DocNumbr AND EA.AccountIndex = P1.DstIndx
		LEFT JOIN AIS.dbo.RM30301 P2 ON VoucherNumber = P2.DocNumbr AND EA.AccountIndex = P2.DstIndx
	WHERE 	ET.CompanyID = 'AIS' AND
		ISNULL(P1.DocNumbr, P2.DocNumbr) IS NOT Null AND
		ET.Source = 'AR'
SELECT * FROM RM20101

SELECT 	DISTINCT CAST(0 AS Bit) AS Selector,
	'AP' AS Source,
	PH.VchrNmbr,
	PD.DstSqNum,
	'AIS' AS CompanyId,
	EA.Fk_EscrowModuleId,
	RTRIM(GL.ACTNUMBR_1) + '-' + RTRIM(GL.ACTNUMBR_2) + '-' + RTRIM(GL.ACTNUMBR_3) AS Account,
	PD.DistType,
	PD.VendorId,
	CASE WHEN EA.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9, 10) THEN CASE WHEN PD.CrdTAmnt <> 0 THEN PD.CrdTAmnt ELSE PD.DebitAmt * -1 END
	ELSE CASE WHEN PD.CrdTAmnt <> 0 THEN PD.CrdTAmnt * -1 ELSE PD.DebitAmt END END AS Amount,
	PH.DocDate,
	PH.PstgDate,
	CASE WHEN PD.DistRef = '' THEN PH.TrxDscrn ELSE PD.DistRef END AS Description,
	PH.PTDUsrId AS EnteredBy,
	PH.ModifDt AS EnteredOn,
	PH.PTDUsrId AS ModifyBy,
	PH.ModifDt AS ModifyOn,
	ET.VoucherNumber
FROM 	PM30600 PD
	INNER JOIN PM30200 PH ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'
	INNER JOIN GL00100 GL ON PD.DstIndx = GL.ACTINDX
	LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(PD.VchrNmbr) = RTRIM(ET.VoucherNumber) AND PD.DstSqNum = ET.ItemNumber AND PD.DistType = ET.AccountType AND ET.Source = 'AP'
WHERE 	PH.Voided = 0 AND
	ET.VoucherNumber IS NULL
UNION
SELECT 	DISTINCT CAST(0 AS Bit) AS Selector,
	'AR' AS Source,
	RH.DocNumbr AS VchrNmbr,
	RD.SeqNumbr AS DstSqNum,
	'AIS' AS CompanyId,
	EA.Fk_EscrowModuleId,
	RTRIM(GL.ACTNUMBR_1) + '-' + RTRIM(GL.ACTNUMBR_2) + '-' + RTRIM(GL.ACTNUMBR_3) AS Account,
	RD.DistType,
	'' AS VendorId,
	CASE WHEN EA.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9, 10) THEN CASE WHEN RD.CrdTAmnt <> 0 THEN RD.CrdTAmnt * -1 ELSE RD.DebitAmt END
	ELSE CASE WHEN RD.CrdTAmnt <> 0 THEN RD.CrdTAmnt ELSE RD.DebitAmt * -1 END END AS Amount,
	RH.DocDate,
	RH.PostDate AS PstgDate,
	CASE WHEN RD.DistRef = '' THEN RH.TrxDscrn ELSE RD.DistRef END AS Description,
	RH.PstUsrId AS EnteredBy,
	RH.LstEdtDt AS EnteredOn,
	RH.PstUsrId AS ModifyBy,
	RH.LstEdtDt AS ModifyOn,
	ET.VoucherNumber 
FROM 	RM10101 RD
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON RD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'
	INNER JOIN GL00100 GL ON RD.DstIndx = GL.ACTINDX
	LEFT JOIN RM20101 RH ON RD.DocNumbr = RH.DocNumbr AND RD.TrxSorce = RH.TrxSorce
	LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(RD.DocNumbr) = RTRIM(ET.VoucherNumber) AND RD.SeqNumbr = ET.ItemNumber AND RD.DistType = ET.AccountType AND ET.Source = 'AR'
WHERE	RH.VoidStts = 0 AND
	ET.VoucherNumber IS NULL