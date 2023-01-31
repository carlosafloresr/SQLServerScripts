/*
SELECT * FROM EscrowTransactions WHERE RIGHT(RTRIM(VoucherNumber), 4) = '2208'
SELECT * FROM AISEscrowFeb08

*/
--select rowline/2.00, CAST(rowline/2.00 AS INT), * from AISEscrowFeb08 where rowline/2.00 <> CAST(rowline/2.00 AS INT) AND ROWLINE>1
--update AISEscrowFeb08 set RowLine = RowLine - 1 where rowline/2.00 <> CAST(rowline/2.00 AS INT) AND ROWLINE>1

INSERT INTO EscrowTransactionS
	   (Source,
		VoucherNumber,
		ItemNumber,
		CompanyId,
		Fk_EscrowModuleId,
		AccountNumber,
		AccountType,
		ES.VendorId,
		Amount,
		Comments,
		TransactionDate,
		PostingDate,
		EnteredBy,
		EnteredOn,
		ChangedBy,
		ChangedOn)
SELECT	Source,
		VoucherNumber,
		RowLine * 16384 AS ItemNumber,
		CompanyId,
		Fk_EscrowModuleId,
		AccountNumber,
		AccountType,
		ES.VendorId,
		ES.Debit * -1 AS Amount,
		Comments,
		TransactionDate,
		PostingDate,
		EnteredBy,
		EnteredOn,
		ChangedBy,
		ChangedOn
FROM	AISEscrowFeb08 ES
		INNER JOIN EscrowTransactions ET ON ET.Amount = (ES.Debit * -1)
WHERE	EscrowTransactionId = 22740