SELECT	*
FROM	EscrowTransactions
WHERE	CompanyId = 'AIS'
		AND AccountNumber = '0-00-2795'
		AND PostingDate = '05/27/2009'
		AND Comments = 'VOIDED TRANS'
		AND DeletedBy IS NULL
		AND Amount > 0
		
UPDATE	EscrowTransactions
SET		Amount = Amount * -1,
		VoucherNumber = RTRIM(VoucherNumber) + '_B'
WHERE	CompanyId = 'AIS'
		AND AccountNumber = '0-00-2795'
		AND PostingDate = '05/27/2009'
		AND Comments = 'VOIDED TRANS'
		AND DeletedBy IS NULL
		AND Amount > 0