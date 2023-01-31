CREATE VIEW View_EscrowMissing
AS
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
	PH.PTDUsrId AS EnteredBy,
	PH.ModifDt AS EnteredOn,
	PH.PTDUsrId AS ModifyBy,
	PH.ModifDt AS ModifyOn
FROM 	PM30600 PD
	INNER JOIN PM30200 PH ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'
	INNER JOIN GL00100 GL ON PD.DstIndx = GL.ACTINDX
	LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(PD.VchrNmbr) = RTRIM(ET.VoucherNumber) AND PD.DstSqNum = ET.ItemNumber AND PD.DistType = ET.AccountType
WHERE 	PH.Voided = 0 AND
	LEFT(PD.VendorId, 1) <> 'A' AND
	ET.VoucherNumber IS NULL
UNION
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
	PH.PTDUsrId AS EnteredBy,
	PH.ModifDt AS EnteredOn,
	PH.PTDUsrId AS ModifyBy,
	PH.ModifDt AS ModifyOn
FROM 	PM10100 PD
	INNER JOIN PM20000 PH ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce
	INNER JOIN GPCustom.dbo.EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'
	INNER JOIN GL00100 GL ON PD.DstIndx = GL.ACTINDX
	LEFT JOIN GPCustom.dbo.EscrowTransactions ET ON RTRIM(PD.VchrNmbr) = RTRIM(ET.VoucherNumber) AND PD.DstSqNum = ET.ItemNumber AND PD.DistType = ET.AccountType
WHERE 	PH.Voided = 0 AND
	LEFT(PD.VendorId, 1) <> 'A' AND
	ET.VoucherNumber IS NULL
ORDER BY 2,3


-- select * from GPCustom.dbo.EscrowTransactions where VoucherNumber = '00000000000000826' accountnumber = '0-00-2795'
-- select * from PM30200 where VchrNmbr = '00000000000000826'

SELECT VendorId, RTRIM(VendorId) + ' - ' + VendName AS VendName FROM AIS.dbo.PM00200 ORDER BY VendorId