/*
SELECT	*
FROM	EscrowTransactions
WHERE	VendorId = 'G0154'
*/

SELECT	Fk_EscrowModuleId
		,SUM(Amount) AS Amount
FROM	View_EscrowTransactions
WHERE	VendorId = 'G0154'
		AND DeletedBy IS NULL
GROUP BY Fk_EscrowModuleId