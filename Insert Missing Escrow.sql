-- SELECT * FROM EscrowTransactions WHERE ChangedBy = 'APP_RECOVER'
-- SELECT * FROM EscrowAccounts
-- SELECT * FROM IMC.dbo.GL20000 WHERE ActIndx = 1705
-- SELECT * FROM IMC.dbo.PM00200

INSERT INTO EscrowTransactions (
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
SELECT	'AP' AS Source,
		VchrNmbr,
		OrigSeqNum,
		'IMC',
		Fk_EscrowModuleId,
		AccountNumber,
		DistType,
		VendorId,
		CASE WHEN CrdtAmnt > 0 THEN CrdtAmnt ELSE DebitAmt * -1 END AS Amount,
		TrxDate,
		OrPstDDT,
		MdfUsrId,
		ModifDt,
		'APP_RECOVER',
		GETDATE()
FROM	(
SELECT	GL2.JrnEntry,
		GL2.OrgnTsrc,
		GL2.ActIndx,
		ESA.AccountNumber,
		PMH.VchrNmbr,
		GL2.OrigSeqNum,
		GL2.CrdtAmnt,
		GL2.DebitAmt,
		PMH.VendorId,
		GL2.TrxDate,
		GL2.OrPstDDT,
		ESA.Fk_EscrowModuleId,
		PMD.DistType,
		PMH.MdfUsrId,
		PMH.ModifDt
FROM	IMC.dbo.GL20000 GL2
		INNER JOIN EscrowAccounts ESA ON GL2.ActIndx = ESA.AccountIndex AND ESA.CompanyId = 'IMC'
		INNER JOIN IMC.dbo.PM30200 PMH ON GL2.OrgnTsrc = PMH.TrxSorce AND GL2.OrctrNum = PMH.VchrNmbr
		INNER JOIN IMC.dbo.PM30600 PMD ON GL2.OrgnTsrc = PMD.TrxSorce AND GL2.OrctrNum = PMD.VchrNmbr AND GL2.ActIndx = PMD.DstIndx
		INNER JOIN IMC.dbo.PM00200 VEN ON PMH.VendorId = VEN.VendorId AND VEN.VndClsId = 'DRV'
		LEFT JOIN EscrowTransactions EST ON GL2.OrctrNum = EST.VoucherNumber AND GL2.OrigSeqNum = EST.ItemNumber AND ESA.AccountNumber = EST.AccountNumber
WHERE	GL2.SourcDoc = 'PMTRX'
		AND MONTH(GL2.OrPstDDT) = 6
		AND PMH.TrxSorce = 'PMTRX00000424'
		AND ESA.AccountNumber = '0-00-2784'
		AND EST.VoucherNumber IS Null) ESC
/*
ESA.AccountNumber = '0-00-2784'

SELECT	* FROM IMC.DBO.PM30600 WHERE VchrNmbr = 'OOS_0605080026       '
SELECT	*
FROM	IMC.dbo.PM30200
WHERE	VendorId = '7263' AND
		DocDate = '6/5/2008'
*/