SELECT	*
FROM	EscrowTransactions 
WHERE	AccountNumber = '0-00-1102' 
		AND CompanyId = 'IMC'
		AND VoucherNumber = '808300'
		
DELETE EscrowTransactions WHERE EscrowTransactionId IN (408603)