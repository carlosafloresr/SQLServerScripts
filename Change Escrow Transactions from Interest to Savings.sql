SELECT	*
FROM	EscrowTransactions
WHERE	CompanyId = 'HMIS'
		AND AccountNumber = '0-02-2790'
		AND VendorId IN ('H50021','53341')
		AND VoucherNumber LIKE 'MC_012819_00%'

UPDATE	EscrowTransactions
SET		Fk_EscrowModuleId = 2
WHERE	CompanyId = 'HMIS'
		AND AccountNumber = '0-02-2790'
		AND VendorId IN ('H50021','53341')
		AND VoucherNumber LIKE 'MC_012819_00%'
