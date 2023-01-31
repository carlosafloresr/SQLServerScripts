UPDATE	GPCustom.dbo.EscrowTransactions
SET		PostingDate = DATA.TRXDATE
FROM	(
SELECT	EST.VoucherNumber,
		EST.Amount,
		GL2.TRXDATE,
		GL2.CRDTAMNT,
		GL2.DEBITAMT,
		EST.EscrowTransactionId AS RecordId
FROM	GPCustom.dbo.EscrowTransactions EST
		INNER JOIN GL00105 GL5 ON EST.AccountNumber = GL5.ACTNUMST
		INNER JOIN GL20000 GL2 ON GL5.ACTINDX = GL2.ACTINDX AND EST.VoucherNumber = GL2.JRNENTRY AND EST.ItemNumber = GL2.SEQNUMBR
WHERE	EST.CompanyId = DB_NAME()
		AND EST.PostingDate IS Null
		AND EST.EnteredOn > DATEADD(dd, -3, GETDATE())
		AND EST.Source = 'GL'
		) DATA
WHERE	EscrowTransactionId = RecordId