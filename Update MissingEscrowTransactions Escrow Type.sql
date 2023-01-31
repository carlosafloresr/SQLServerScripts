-- SELECT * FROM MissingEscrowTransactions WHERE Fk_EscrowModuleId = 0

UPDATE	MissingEscrowTransactions 
SET		MissingEscrowTransactions.Fk_EscrowModuleId = EscrowAccounts.Fk_EscrowModuleId
FROM	EscrowAccounts
WHERE	MissingEscrowTransactions.Fk_EscrowModuleId IS Null
		AND EscrowAccounts.CompanyId = 'AIS'
		AND MissingEscrowTransactions.CompanyId = EscrowAccounts.CompanyId
		AND MissingEscrowTransactions.AccountNumber = EscrowAccounts.AccountNumber

-- DELETE MissingEscrowTransactions WHERE Source IS Null