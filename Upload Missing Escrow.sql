SELECT	*
FROM	PASO

INSERT INTO EscrowTransactions (Source, VoucherNumber, ItemNumber, CompanyId, Fk_EscrowModuleId, AccountNumber, AccountType, VendorId, Amount, Comments, TransactionDate, PostingDate, EnteredBy, EnteredOn, ChangedBy, ChangedOn)
SELECT	'GL',
	Voucher,
	1,
	'AIS',
	Fk_EscrowModuleId,
	Account,
	2,
	SUBSTRING(MasterName, PATINDEX('%#%', MasterName) + 1, 5),
	Credit,
	Reference,
	TrxDate,
	TrxDate,
	'UPLOADER',
	GETDATE(),
	'UPLOADER',
	GETDATE()
FROM	PASO
	LEFT JOIN EscrowAccounts ON Paso.Account = EscrowAccounts.AccountNumber AND CompanyId = 'AIS'