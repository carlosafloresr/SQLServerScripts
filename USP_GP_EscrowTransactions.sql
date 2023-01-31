-- EXECUTE USP_GP_EscrowTransactions 'AIS', '09/30/2007', '11/03/2007', 0, 3, NULL, 'AP', 'A0094'

ALTER PROCEDURE USP_GP_EscrowTransactions
	@Company	Char(6),
	@DateIni	Datetime,
	@DateEnd	Datetime,
	@Voucher	Int = 0,
	@EscrowId	Int = Null,
	@Account	Char(15) = Null,
	@Source		Char(2) = Null,
	@VendorId	Char(10) = Null
AS
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
	GPCustom.dbo.Proper(CASE WHEN PD.DistRef = '' THEN PH.TrxDscrn ELSE PD.DistRef END) AS Description,
	PH.PTDUsrId AS EnteredBy,
	PH.ModifDt AS EnteredOn,
	PH.PTDUsrId AS ModifyBy,
	PH.ModifDt AS ModifyOn,
	ET.EscrowTransactionId,
	EA.Fk_EscrowModuleId,
	CASE WHEN ET.EscrowTransactionId IS Null THEN 'NO' ELSE 'YES' END AS Existent
FROM 	PM30600 PD
	INNER JOIN PM30200 PH ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = @Company
	INNER JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
	INNER JOIN GL00100 GL ON PD.DstIndx = GL.ACTINDX
	LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(PD.VchrNmbr) = RTRIM(ET.VoucherNumber) AND PD.DstSqNum = ET.ItemNumber AND PD.DistType = ET.AccountType AND ET.Source = 'AP'
WHERE 	PH.Voided = 0 AND
	PH.PstgDate BETWEEN @DateIni AND @DateEnd AND
	((@Voucher = 2 AND ET.VoucherNumber IS NULL) OR
	(@Voucher = 1 AND ET.VoucherNumber IS NOT NULL) OR
	(@Voucher = 0 AND (ET.VoucherNumber <> '9-9-9') OR ET.VoucherNumber IS NULL)) AND
	((@Account IS Null AND EA.AccountNumber <> '9-9-9') OR
	(@Account IS NOT Null AND EA.AccountNumber = @Account)) AND
	((@VendorId IS Null AND PD.VendorId <> '9-9-9') OR
	(@VendorId IS NOT Null AND PD.VendorId = @VendorId)) AND
	((@EscrowId IS Null AND EA.Fk_EscrowModuleId <> -999) OR
	(@EscrowId IS NOT Null AND EA.Fk_EscrowModuleId = @EscrowId)) AND
	((@Source IS Null AND PH.TrxSorce <> '9-9-9') OR
	(@Source = 'AP' AND LEFT(PH.TrxSorce, 5) = 'PMTRX'))
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
	GPCustom.dbo.Proper(CASE WHEN RD.DistRef = '' THEN RH.TrxDscrn ELSE RD.DistRef END) AS Description,
	RH.PstUsrId AS EnteredBy,
	RH.LstEdtDt AS EnteredOn,
	RH.PstUsrId AS ModifyBy,
	RH.LstEdtDt AS ModifyOn,
	ET.EscrowTransactionId,
	EA.Fk_EscrowModuleId,
	CASE WHEN ET.EscrowTransactionId IS Null THEN 'NO' ELSE 'YES' END AS Existent
FROM 	RM10101 RD
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON RD.DstIndx = EA.AccountIndex AND EA.CompanyId = @CompanY
	INNER JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
	INNER JOIN GL00100 GL ON RD.DstIndx = GL.ACTINDX
	LEFT JOIN RM20101 RH ON RD.DocNumbr = RH.DocNumbr AND RD.TrxSorce = RH.TrxSorce
	LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(RD.DocNumbr) = RTRIM(ET.VoucherNumber) AND RD.SeqNumbr = ET.ItemNumber AND RD.DistType = ET.AccountType AND ET.Source = 'AR'
WHERE	RH.VoidStts = 0 AND
	RH.PostDate BETWEEN @DateIni AND @DateEnd AND
	((@Voucher = 2 AND ET.VoucherNumber IS NULL) OR
	(@Voucher = 1 AND ET.VoucherNumber IS NOT NULL) OR
	(@Voucher = 0 AND (ET.VoucherNumber <> '9-9-9') OR ET.VoucherNumber IS NULL)) AND
	((@Account IS Null AND EA.AccountNumber <> '9-9-9') OR
	(@Account IS NOT Null AND EA.AccountNumber = @Account)) AND
	((@EscrowId IS Null AND EA.Fk_EscrowModuleId <> -999) OR
	(@EscrowId IS NOT Null AND EA.Fk_EscrowModuleId = @EscrowId)) AND
	((@Source IS Null AND RH.TrxSorce <> '9-9-9') OR
	(@Source = 'AR' AND LEFT(RH.TrxSorce, 5) = 'RMSLS'))
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
	TD.TrxDate AS PstgDate,
	GPCustom.dbo.Proper(TD.Refrence) AS Description,
	TD.UsWhPstd AS EnteredBy,
	TD.LstDtEdt AS EnteredOn,
	TD.UsWhPstd AS ModifyBy,
	TD.LstDtEdt AS ModifyOn,
	ET.EscrowTransactionId,
	EA.Fk_EscrowModuleId,
	CASE WHEN ET.EscrowTransactionId IS Null THEN 'NO' ELSE 'YES' END AS Existent
FROM	GL20000 TD
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON TD.ActIndx = EA.AccountIndex AND EA.CompanyId = @Company
	INNER JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
	INNER JOIN GL00100 GL ON TD.ActIndx = GL.ActIndx
	LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON TD.JrnEntry = ET.VoucherNumber AND TD.SeqNumbr = ET.ItemNumber AND ET.AccountType  =99 AND ET.Source = 'GL'
WHERE	LEFT(TrxSorce, 5) = 'GLTRX' AND
	TD.Voided = 0 AND
	TD.TrxDate BETWEEN @DateIni AND @DateEnd AND
	((@Voucher = 2 AND ET.VoucherNumber IS NULL) OR
	(@Voucher = 1 AND ET.VoucherNumber IS NOT NULL) OR
	(@Voucher = 0 AND (ET.VoucherNumber <> '9-9-9') OR ET.VoucherNumber IS NULL)) AND
	((@Account IS Null AND EA.AccountNumber <> '9-9-9') OR
	(@Account IS NOT Null AND EA.AccountNumber = @Account)) AND
	((@EscrowId IS Null AND EA.Fk_EscrowModuleId <> -999) OR
	(@EscrowId IS NOT Null AND EA.Fk_EscrowModuleId = @EscrowId)) AND
	((@Source IS Null AND TD.TrxSorce <> '9-9-9') OR
	(@Source = 'GL' AND LEFT(TD.TrxSorce, 5) = 'GLTRX'))
UNION
SELECT	DISTINCT CAST(0 AS Bit) AS Selector,
	'SO' AS Source,
	SD.SopNumbe AS VchrNmbr,
	SD.SeqNumbr AS DstSqNum,
	@CompanY AS CompanyId,
	EM.ModuleDescription AS Module,
	EA.AccountNumber AS Account,
	SD.DistType,
	'' AS VendorId,
	CASE WHEN EA.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9, 10) THEN CASE WHEN SD.CrdTAmnt <> 0 THEN SD.CrdTAmnt ELSE SD.DebitAmt * -1 END
	ELSE CASE WHEN SD.CrdTAmnt <> 0 THEN SD.CrdTAmnt * -1 ELSE SD.DebitAmt END END AS Amount,
	SH.DocDate,
	SH.GLPostdt AS PstgDate,
	GPCustom.dbo.Proper(SD.DistRef) AS Description,
	SH.User2Ent AS EnteredBy,
	SH.CreatDdt AS EnteredOn,
	SH.User2Ent AS ModifyBy,
	SH.ModifDt AS ModifyOn,
	ET.EscrowTransactionId,
	EA.Fk_EscrowModuleId,
	CASE WHEN ET.EscrowTransactionId IS Null THEN 'NO' ELSE 'YES' END AS Existent
FROM	SOP10102 SD
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON SD.ActIndx = EA.AccountIndex AND EA.CompanyId = @CompanY
	INNER JOIN GPCustom.dbo.EscrowModules EM ON EA.Fk_EscrowModuleId = EM.EscrowModuleId
	INNER JOIN GL00100 GL ON SD.ActIndx = GL.ActIndx
	LEFT JOIN SOP10100 SH ON SD.SopNumbe = SH.SopNumbe
	LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(SD.SopNumbe) = RTRIM(ET.VoucherNumber) AND SD.SeqNumbr = ET.ItemNumber AND SD.DistType = ET.AccountType AND ET.Source = 'SO'
WHERE	SH.VoidStts = 0 AND
	SH.GLPostdt BETWEEN @DateIni AND @DateEnd AND
	((@Voucher = 2 AND ET.VoucherNumber IS NULL) OR
	(@Voucher = 1 AND ET.VoucherNumber IS NOT NULL) OR
	(@Voucher = 0 AND (ET.VoucherNumber <> '9-9-9') OR ET.VoucherNumber IS NULL)) AND
	((@Account IS Null AND EA.AccountNumber <> '9-9-9') OR
	(@Account IS NOT Null AND EA.AccountNumber = @Account)) AND
	((@EscrowId IS Null AND EA.Fk_EscrowModuleId <> -999) OR
	(@EscrowId IS NOT Null AND EA.Fk_EscrowModuleId = @EscrowId)) AND
	((@Source IS Null AND SH.TrxSorce <> '9-9-9') OR
	(@Source = 'SO'))
ORDER BY 6,7,13,3,4

GO
