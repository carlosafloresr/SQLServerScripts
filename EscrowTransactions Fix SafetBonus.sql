INSERT INTO EscrowTransactions
		(Source,
		VoucherNumber,
		ItemNumber,
		CompanyId,
		Fk_EscrowModuleId,
		AccountNumber, 
		AccountType,
		VendorId,
		Division,
		Amount,
		Status,
		DMSubmitted,
		Comments,
		TransactionDate,
		EnteredBy,
		EnteredOn,
		ChangedBy,
		ChangedOn,
		InvoiceNumber,
		BatchId)
SELECT	Source,
		'1546751' AS VoucherNumber,
		ItemNumber,
		CompanyId,
		Fk_EscrowModuleId,
		AccountNumber, 
		AccountType,
		VendorId,
		Division,
		Amount * -1 AS Amount,
		Status,
		DMSubmitted,
		Comments,
		TransactionDate,
		EnteredBy,
		GETDATE() AS EnteredOn,
		ChangedBy,
		GETDATE() AS ChangedOn,
		'SF_CORRECTION' AS InvoiceNumber,
		'SF_CORRECTION' AS BatchId
FROM	EscrowTransactions
WHERE	CompanyId = 'AIS'
		AND BatchId = 'SBA_20220929'
ORDER BY Amount, VendorId
		--AND VendorId = 'A52332'
		--AND Comments LIKE 'Safety Bonus Accrual%'

-- DELETE EscrowTransactions WHERE PostingDate IS NULL AND EnteredOn < '10/05/2022'