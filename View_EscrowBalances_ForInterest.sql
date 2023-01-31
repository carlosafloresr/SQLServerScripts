ALTER VIEW View_EscrowBalances_ForInterest
AS
SELECT 	CompanyId,
	VendorId,
	AccountNumber,
	SUM(CASE WHEN Source = 'AR' THEN Amount * -1
	ELSE Amount END) AS Balance
FROM 	EscrowTransactions
WHERE	Fk_EscrowModuleId IN (1,2,5)
GROUP BY 
	CompanyId,
	VendorId,
	AccountNumber
HAVING 	SUM(CASE WHEN Source = 'AR' THEN Amount * -1
	ELSE Amount END) > 0

SELECT * FROM View_EscrowBalances_ForInterest