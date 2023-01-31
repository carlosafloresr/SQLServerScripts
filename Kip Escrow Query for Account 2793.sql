SELECT	CompanyId,
		Source,
		VoucherNumber,
		VendorId,
		Amount,
		ISNULL(LEFT(Comments, 200), '') AS Comments,
		TransactionDate,
		PostingDate,
		ISNULL(BatchId, '') AS BatchId,
		UPPER(EnteredBy) AS EnteredBy,
		EnteredOn
FROM	EscrowTransactions
WHERE	AccountNumber LIKE '%-2793'
		AND PostingDate IS NOT NULL
		AND DeletedOn IS NULL
		AND Amount > 0
		AND PostingDate BETWEEN '01/01/2012' AND '09/30/2013'
		AND VoucherNumber LIKE 'TKMR%'
ORDER BY
		CompanyId,
		PostingDate,
		VoucherNumber