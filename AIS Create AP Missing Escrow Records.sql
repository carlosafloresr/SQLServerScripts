/*

SELECT 	PH.VchrNmbr,
	PD.VendorId,
	PH.DocType,
	PH.DocDate,
	PH.DocAmnt,
	PH.TrxDscrn,
	PH.PstgDate,
	PH.PTDUsrId,
	PH.ModifDt,
	PD.DstSqNum,
	PD.DistType,
	PD.CrdTAmnt,
	PD.DebitAmt,
	PD.DistRef,
	PD.DstIndx,
	RTRIM(GL.ACTNUMBR_1) + '-' + RTRIM(GL.ACTNUMBR_2) + '-' + RTRIM(GL.ACTNUMBR_3) AS Account,
	ET.VoucherNumber
FROM 	AIS.dbo.PM30600 PD
	INNER JOIN AIS.dbo.PM30200 PH ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce
	INNER JOIN EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'
	LEFT JOIN AIS.dbo.GL00100 GL ON PD.DstIndx = GL.ACTINDX
	LEFT JOIN EscrowTransactions ET ON PH.VchrNmbr = ET.VoucherNumber AND PD.DstSqNum = ET.ItemNumber
WHERE 	PH.Voided = 0 AND
	EA.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9) AND
	PD.DistRef <> 'Mthly Insurance Payment' AND
	ET.VoucherNumber IS NULL

SELECT * FROM AIS.dbo.PM30200 WHERE VchrNmbr = '00000000000000374'
SELECT * FROM AIS.dbo.PM30600 WHERE VchrNmbr = '00000000000000374'
*/

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
	'AIS' AS CompanyId,
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
FROM 	AIS.dbo.PM30600 PD
	INNER JOIN AIS.dbo.PM30200 PH ON PH.VchrNmbr = PD.VchrNmbr AND PH.TrxSorce = PD.TrxSorce
	INNER JOIN EscrowAccounts EA ON PD.DstIndx = EA.AccountIndex AND EA.CompanyId = 'AIS'
	LEFT JOIN AIS.dbo.GL00100 GL ON PD.DstIndx = GL.ACTINDX
	LEFT JOIN EscrowTransactions ET ON RTRIM(PD.VchrNmbr) = RTRIM(ET.VoucherNumber) AND PD.DstSqNum = ET.ItemNumber AND PD.DistType = ET.AccountType
WHERE 	PH.Voided = 0 AND
	EA.Fk_EscrowModuleId IN (1, 2, 3, 4, 7, 8, 9) AND
	PD.DistRef <> 'Mthly Insurance Payment' AND
	ET.VoucherNumber IS NULL and pd.vendorid = 'A0018'

--SELECT top 5 * FROM GPCustom.dbo.EscrowTransactions
SELECT TOP 10 * FROM AIS.dbo.PM30200

select * from AIS.dbo.PM30200 where VchrNmbr = 'OOSA0018101107011'
select * from AIS.dbo.PM30600 where VchrNmbr = 'OOSA0018101107011'
SELECT * FROM EscrowTransactions WHERE VoucherNumber = 'OOSA0018101107011'
UPDATE EscrowTransactions SET AMOUNT = AMOUNT * -1 WHERE VoucherNumber = 'OOSA0018101107011' AND ItemNumber = 16384
DELETE EscrowTransactions WHERE ACCOUNTNUMBER = '0' AND LEN(RTRIM(ACCOUNTNUMBER)) = 1
	