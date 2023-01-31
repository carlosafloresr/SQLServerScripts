/*
SELECT	*
FROM	EscrowTransactions
WHERE	CompanyId = 'GIS'
		AND VendorId = 'G00001'
*/		

SELECT	VET.Fk_EscrowModuleId
		,ESM.ModuleDescription
		,SUM(VET.Amount) AS Balance
FROM	View_EscrowTransactions VET
		INNER JOIN EscrowModules ESM ON ESM.EscrowModuleId = VET.Fk_EscrowModuleId
WHERE	VET.CompanyId = 'GIS'
		AND VET.VendorId = 'G0008'
GROUP BY 
		VET.Fk_EscrowModuleId
		,ESM.ModuleDescription

/*	
SELECT	*
FROM	View_OOS_Transactions
WHERE	Company = 'GIS'
		AND VendorId = 'G00008'
ORDER BY
		DeductionDate
*/