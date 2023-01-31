USE DNJ
GO

DECLARE @BatchId varchar(20) = '7OOS071622'

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
SELECT	'AP' AS [Source],
		RTRIM(HDR.VCHRNMBR),
		DET.DSTSQNUM,
		DB_NAME() AS CompanyId,
		ESA.Fk_EscrowModuleId,
		GL5.ACTNUMST,
		DET.DISTTYPE,
		HDR.VENDORID,
		DET.CRDTAMNT + DET.DEBITAMT AS Amount,
		HDR.TRXDSCRN,
		HDR.DOCDATE,
		HDR.PSTGDATE,
		HDR.PTDUSRID,
		GETDATE() AS EnteredOn,
		HDR.PTDUSRID,
		GETDATE() AS ChangedOn,
		BACHNUMB
FROM	PM20000 HDR
		INNER JOIN PM10100 DET ON HDR.VENDORID = DET.VENDORID AND HDR.VCHRNMBR = DET.VCHRNMBR
		INNER JOIN GL00105 GL5 ON DET.DSTINDX = GL5.ACTINDX
		INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON GL5.ACTNUMST = ESA.AccountNumber AND ESA.CompanyId = DB_NAME()
WHERE	BACHNUMB = @BatchId
		AND ESA.Fk_EscrowModuleId <> 10
		AND TRXDSCRN LIKE 'TINS REFUND%'
UNION
SELECT	'AP' AS [Source],
		RTRIM(HDR.VCHRNMBR),
		DET.DSTSQNUM,
		DB_NAME() AS CompanyId,
		ESA.Fk_EscrowModuleId,
		GL5.ACTNUMST,
		DET.DISTTYPE,
		HDR.VENDORID,
		DET.CRDTAMNT + DET.DEBITAMT AS Amount,
		HDR.TRXDSCRN,
		HDR.DOCDATE,
		HDR.PSTGDATE,
		HDR.PTDUSRID,
		GETDATE() AS EnteredOn,
		HDR.PTDUSRID,
		GETDATE() AS ChangedOn,
		BACHNUMB
FROM	PM30200 HDR
		INNER JOIN PM30600 DET ON HDR.VENDORID = DET.VENDORID AND HDR.VCHRNMBR = DET.VCHRNMBR
		INNER JOIN GL00105 GL5 ON DET.DSTINDX = GL5.ACTINDX
		INNER JOIN GPCustom.dbo.EscrowAccounts ESA ON GL5.ACTNUMST = ESA.AccountNumber AND ESA.CompanyId = DB_NAME()
WHERE	BACHNUMB = @BatchId
		AND ESA.Fk_EscrowModuleId <> 10
		AND TRXDSCRN LIKE 'TINS REFUND%'
ORDER BY 8, 2

--SELECT * FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = DB_NAME()
/*
SELECT * FROM PM20000 WHERE	BACHNUMB = 'OOSPTS_112819'
SELECT * FROM GPCustom.dbo.EscrowAccounts WHERE CompanyId = DB_NAME()
*/