SELECT	CompanyId,
		CompanyNumber,
		Fk_EscrowModuleId,
		ModuleDescription,
		AccountNumber,
		AccountAlias
FROM	GPCustom.dbo.View_EscrowAccounts
WHERE	BalanceInquiry = 1 
		AND RemittanceAdvise = 1
		AND CompanyId NOT IN ('ATEST','NDS')
ORDER BY CompanyId, ModuleDescription, AccountNumber

/*
UPDATE	EscrowAccounts
SET		AccountAlias = 'Medical Insurance'
WHERE	AccountNumber = '0-00-2781'
		AND Fk_EscrowModuleId = 3
*/