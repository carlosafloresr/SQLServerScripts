SELECT	CompanyId,
		Fk_EscrowModuleId,
		AccountNumber,
		SUM(Amount) AS Total
FROM	EscrowTransactions
WHERE	PostingDate IS NOT Null
		AND DeletedBy IS Null
GROUP BY
		CompanyId,
		Fk_EscrowModuleId,
		AccountNumber
ORDER BY
		CompanyId,
		Fk_EscrowModuleId,
		AccountNumber