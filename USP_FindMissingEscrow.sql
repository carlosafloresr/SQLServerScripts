ALTER PROCEDURE USP_FindMissingEscrow
	@CompanY	Char(6),
	@Account 	Char(15) =  Null
AS
IF @Account IS Null
BEGIN
	SELECT 	DISTINCT CAST(0 AS Bit) AS Selector,
		'AP' AS Source,
		PH.VchrNmbr,
		PD.DstSqNum,
		@CompanY AS CompanyId,
		EM.ModuleDescription AS Module,
		EA.AccountNumber AS Account,
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
		ET.VoucherNumber,
		EA.Fk_EscrowModuleId
	FROM 	PM30600 PD
		INNER JOIN PM30200 PH ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce
		INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = @CompanY
		INNER JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
		INNER JOIN GL00100 GL ON PD.DstIndx = GL.ACTINDX
		LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(PD.VchrNmbr) = RTRIM(ET.VoucherNumber) AND PD.DstSqNum = ET.ItemNumber AND PD.DistType = ET.AccountType AND ET.Source = 'AP'
	WHERE 	PH.Voided = 0 AND
		ET.VoucherNumber IS NULL
	UNION
	SELECT 	DISTINCT CAST(0 AS Bit) AS Selector,
		'AR' AS Source,
		RH.DocNumbr AS VchrNmbr,
		RD.SeqNumbr AS DstSqNum,
		@CompanY AS CompanyId,
		EM.ModuleDescription AS Module,
		EA.AccountNumber AS Account,
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
		ET.VoucherNumber,
		EA.Fk_EscrowModuleId
	FROM 	RM10101 RD
		INNER JOIN GPCustom.dbo.EscrowAccounts EA ON RD.DstIndx = EA.AccountIndex AND EA.CompanyId = @CompanY
		INNER JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
		INNER JOIN GL00100 GL ON RD.DstIndx = GL.ACTINDX
		LEFT JOIN RM20101 RH ON RD.DocNumbr = RH.DocNumbr AND RD.TrxSorce = RH.TrxSorce
		LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(RD.DocNumbr) = RTRIM(ET.VoucherNumber) AND RD.SeqNumbr = ET.ItemNumber AND RD.DistType = ET.AccountType AND ET.Source = 'AR'
	WHERE	RH.VoidStts = 0 AND
		ET.VoucherNumber IS NULL
	UNION
	SELECT	DISTINCT CAST(0 AS Bit) AS Selector,
		'GL' AS Source,
		CAST(TD.JrnEntry AS Char(20)) AS VchrNmbr,
		TD.SeqNumbr AS DstSqNum,
		@CompanY AS CompanyId,
		EM.ModuleDescription AS Module,
		EA.AccountNumber AS Account,
		99 AS DistType,
		'' AS VendorId,
		CASE WHEN EA.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9, 10) THEN CASE WHEN TD.CrdTAmnt <> 0 THEN TD.CrdTAmnt ELSE TD.DebitAmt * -1 END
		ELSE CASE WHEN TD.CrdTAmnt <> 0 THEN TD.CrdTAmnt * -1 ELSE TD.DebitAmt END END AS Amount,
		TD.TrxDate AS DocDate,
		TD.OrPstDdt AS PstgDate,
		TD.Refrence AS Description,
		TD.UsWhPstd AS EnteredBy,
		TD.LstDtEdt AS EnteredOn,
		TD.UsWhPstd AS ModifyBy,
		TD.LstDtEdt AS ModifyOn,
		ET.VoucherNumber,
		EA.Fk_EscrowModuleId
	FROM	GL30000 TD
		INNER JOIN GPCustom.dbo.EscrowAccounts EA ON TD.ActIndx = EA.AccountIndex AND EA.CompanyId = @CompanY
		INNER JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
		INNER JOIN GL00100 GL ON TD.ActIndx = GL.ActIndx
		LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON TD.JrnEntry = ET.VoucherNumber AND TD.SeqNumbr = ET.ItemNumber AND ET.AccountType  =99 AND ET.Source = 'GL'
	WHERE	LEFT(TrxSorce, 5) = 'GLTRX' AND
		TD.Voided = 0 AND
		ET.VoucherNumber IS NULL
	ORDER BY 6,7,3,4
END
ELSE
BEGIN
	SELECT 	DISTINCT CAST(0 AS Bit) AS Selector,
		'AP' AS Source,
		PH.VchrNmbr,
		PD.DstSqNum,
		'AIS' AS CompanyId,
		EM.ModuleDescription AS Module,
		EA.AccountNumber AS Account,
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
		ET.VoucherNumber,
		EA.Fk_EscrowModuleId
	FROM 	PM30600 PD
		INNER JOIN PM30200 PH ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce
		INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS' AND EA.AccountNumber = @Account
		INNER JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
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
		EM.ModuleDescription AS Module,
		EA.AccountNumber AS Account,
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
		ET.VoucherNumber,
		EA.Fk_EscrowModuleId
	FROM 	RM10101 RD
		INNER JOIN GPCustom.dbo.EscrowAccounts EA ON RD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS' AND EA.AccountNumber = @Account
		INNER JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
		INNER JOIN GL00100 GL ON RD.DstIndx = GL.ACTINDX
		LEFT JOIN RM20101 RH ON RD.DocNumbr = RH.DocNumbr AND RD.TrxSorce = RH.TrxSorce
		LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(RD.DocNumbr) = RTRIM(ET.VoucherNumber) AND RD.SeqNumbr = ET.ItemNumber AND RD.DistType = ET.AccountType AND ET.Source = 'AR'
	WHERE	RH.VoidStts = 0 AND
		ET.VoucherNumber IS NULL
	UNION
	SELECT	DISTINCT CAST(0 AS Bit) AS Selector,
		'GL' AS Source,
		CAST(TD.JrnEntry AS Char(20)) AS VchrNmbr,
		TD.SeqNumbr AS DstSqNum,
		@CompanY AS CompanyId,
		EM.ModuleDescription AS Module,
		EA.AccountNumber AS Account,
		99 AS DistType,
		'' AS VendorId,
		CASE WHEN EA.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9, 10) THEN CASE WHEN TD.CrdTAmnt <> 0 THEN TD.CrdTAmnt ELSE TD.DebitAmt * -1 END
		ELSE CASE WHEN TD.CrdTAmnt <> 0 THEN TD.CrdTAmnt * -1 ELSE TD.DebitAmt END END AS Amount,
		TD.TrxDate AS DocDate,
		TD.OrPstDdt AS PstgDate,
		TD.Refrence AS Description,
		TD.UsWhPstd AS EnteredBy,
		TD.LstDtEdt AS EnteredOn,
		TD.UsWhPstd AS ModifyBy,
		TD.LstDtEdt AS ModifyOn,
		ET.VoucherNumber,
		EA.Fk_EscrowModuleId
	FROM	GL30000 TD
		INNER JOIN GPCustom.dbo.EscrowAccounts EA ON TD.ActIndx = EA.AccountIndex AND EA.CompanyId = @CompanY AND EA.AccountNumber = @Account
		INNER JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
		INNER JOIN GL00100 GL ON TD.ActIndx = GL.ActIndx
		LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON TD.JrnEntry = ET.VoucherNumber AND TD.SeqNumbr = ET.ItemNumber AND ET.AccountType  =99 AND ET.Source = 'GL'
	WHERE	LEFT(TrxSorce, 5) = 'GLTRX' AND
		TD.Voided = 0 AND
		ET.VoucherNumber IS NULL
	ORDER BY 6,7,3,4
END

GO

-- EXECUTE USP_FindMissingEscrow 'AIS','0-00-2781'