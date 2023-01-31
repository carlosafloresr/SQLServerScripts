ALTER PROCEDURE USP_FixEscrowTransactions
AS
INSERT INTO GPCustom.dbo.EscrowTransactions (
	Source, 
	VoucherNumber, 
	ItemNumber,
	CompanyId,
	Fk_EscrowModuleId, 
	AccountNumber, 
	AccountType, 
	VendorId, 
	Amount, 
	TransactionDate, 
	PostingDate, 
	EnteredBy, 
	EnteredOn, 
	ChangedBy, 
	ChangedOn)
SELECT 	DISTINCT 'AP' AS Source,
	PH.VchrNmbr,
	PD.DstSqNum,
	'AISTE' AS CompanyId,
	EA.Fk_EscrowModuleId,
	RTRIM(GL.ACTNUMBR_1) + '-' + RTRIM(GL.ACTNUMBR_2) + '-' + RTRIM(GL.ACTNUMBR_3) AS Account,
	PD.DistType,
	PD.VendorId,
	CASE WHEN PD.CrdTAmnt <> 0 THEN PD.CrdTAmnt ELSE PD.DebitAmt * -1 END AS Amount,
	PH.DocDate,
	PH.PstgDate,
	PH.PTDUsrId,
	PH.ModifDt,
	PH.PTDUsrId,
	PH.ModifDt
FROM 	PM30600 PD
	INNER JOIN PM30200 PH ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'
	INNER JOIN GL00100 GL ON PD.DstIndx = GL.ACTINDX
	LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(PD.VchrNmbr) = RTRIM(ET.VoucherNumber) AND PD.DstSqNum = ET.ItemNumber AND PD.DistType = ET.AccountType
WHERE 	PH.Voided = 0 AND
	EA.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9) AND
	PD.DistRef <> 'Mthly Insurance Payment' AND
	ET.VoucherNumber IS NULL AND
	LEFT(PD.VendorId, 1) = 'A'
UNION
SELECT 	DISTINCT 'AP' AS Source,
	PH.VchrNmbr,
	PD.DstSqNum,
	'AISTE' AS CompanyId,
	EA.Fk_EscrowModuleId,
	RTRIM(GL.ACTNUMBR_1) + '-' + RTRIM(GL.ACTNUMBR_2) + '-' + RTRIM(GL.ACTNUMBR_3) AS Account,
	PD.DistType,
	PD.VendorId,
	CASE WHEN PD.CrdTAmnt <> 0 THEN PD.CrdTAmnt ELSE PD.DebitAmt * -1 END AS Amount,
	PH.DocDate,
	PH.PstgDate,
	PH.PTDUsrId,
	PH.ModifDt,
	PH.PTDUsrId,
	PH.ModifDt
FROM 	PM10100 PD
	INNER JOIN PM20000 PH ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'
	INNER JOIN GL00100 GL ON PD.DstIndx = GL.ACTINDX
	LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(PD.VchrNmbr) = RTRIM(ET.VoucherNumber) AND PD.DstSqNum = ET.ItemNumber AND PD.DistType = ET.AccountType
WHERE 	PH.Voided = 0 AND
	EA.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9) AND
	PD.DistRef <> 'Mthly Insurance Payment' AND
	ET.VoucherNumber IS NULL AND
	LEFT(PD.VendorId, 1) = 'A'
GO