
SELECT	TBL1.*
FROM	EscrowTransactions TBL1
		INNER JOIN (
					SELECT	CompanyId,
							VoucherNumber,
							VendorId,
							AccountNumber,
							Amount,
							COUNT(Amount) AS Counter,
							MIN(EscrowTransactionId) AS EscrowTransactionId
					FROM	EscrowTransactions
					WHERE	PostingDate > '11/20/2014'
					GROUP BY
							CompanyId,
							VoucherNumber,
							VendorId,
							AccountNumber,
							Amount
					HAVING	COUNT(Amount) > 1) TBL2 ON TBL1.VoucherNumber = TBL2.VoucherNumber AND TBL1.VendorId = TBL2.VendorId AND TBL1.AccountNumber = TBL2.AccountNumber
WHERE	TBL1.EscrowTransactionId > TBL2.EscrowTransactionId
ORDER BY
		VoucherNumber

/*
DELETE	EscrowTransactions
FROM	(SELECT	CompanyId,
				VoucherNumber,
				VendorId,
				AccountNumber,
				Amount,
				COUNT(Amount) AS Counter,
				MIN(EscrowTransactionId) AS EscrowTransactionId
		FROM	EscrowTransactions
		WHERE	PostingDate > '3/31/2008'
		GROUP BY
				CompanyId,
				VoucherNumber,
				VendorId,
				AccountNumber,
				Amount
		HAVING	COUNT(Amount) > 1) TBL2 
WHERE	EscrowTransactions.EscrowTransactionId > TBL2.EscrowTransactionId AND
		EscrowTransactions.VoucherNumber = TBL2.VoucherNumber AND
		EscrowTransactions.VendorId = TBL2.VendorId AND 
		EscrowTransactions.AccountNumber = TBL2.AccountNumber
*/