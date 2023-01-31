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
		AND MONTH(GL2.OrPstDDT) = MONTH(GETDATE())
		AND EST.VoucherNumber IS Null

SELECT * FROM EscrowTransactions WHERE CompanyId = 'IMC' AND AccountNumber = '0-00-2790' AND EnteredOn > '7/1/2008'