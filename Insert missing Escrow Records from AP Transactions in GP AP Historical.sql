DECLARE @BatchId Varchar(20) = 'EFSMC_03292021'

INSERT INTO GPCustom.dbo.EscrowTransactions
		(Source, 
		VoucherNumber, 
		ItemNumber, 
		CompanyId, 
		Fk_EscrowModuleId, 
		AccountNumber, 
		AccountType, 
		VendorId, 
		Amount, 
		Comments, 
		TransactionDate, 
		PostingDate, 
		EnteredBy, 
		EnteredOn, 
		ChangedBy, 
		ChangedOn,
		BatchId)
SELECT	'AP',
		RTRIM(HDR.VCHRNMBR),
		DET.DSTSQNUM,
		DB_NAME(),
		ESA.Fk_EscrowModuleId,
		GL5.ACTNUMST,
		DET.DISTTYPE,
		HDR.VENDORID,
		IIF(DET.DEBITAMT > 0, DET.DEBITAMT * - 1, DET.CRDTAMNT),
		HDR.TRXDSCRN,
		HDR.DOCDATE,
		HDR.PSTGDATE,
		HDR.PTDUSRID,
		GETDATE(),
		HDR.PTDUSRID,
		GETDATE(),
		BACHNUMB
FROM	PM30200 HDR
		INNER JOIN PM30600 DET ON HDR.VENDORID = DET.VENDORID AND HDR.VCHRNMBR = DET.VCHRNMBR
		INNER JOIN GL00105 GL5 ON DET.DSTINDX = GL5.ACTINDX
		INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON GL5.ACTNUMST = ESA.AccountNumber AND ESA.CompanyId = DB_NAME()
WHERE	BACHNUMB = @BatchId
		AND ESA.Fk_EscrowModuleId = 2

/*
SELECT * FROM PM20000 WHERE	BACHNUMB = 'OOSPTS_112819'
SELECT * FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = DB_NAME()
*/