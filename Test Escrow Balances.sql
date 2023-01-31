SELECT 	OTR.Fk_OOS_DeductionId,
		EST.Fk_EscrowModuleId, 
		ODT.EscrowBalance,
		MAX(OTR.BatchId) AS BatchId,
		SUM(OTR.DeductionAmount) AS DeductionAmount,
		MAX(OTR.Period) AS Period,
		MAX(OTR.DeductionNumber) AS DeductionNumber,
		CASE WHEN ODT.MaintainBalance = 1 AND ODT.EscrowBalance = 1 THEN ISNULL(EST.Balance, 0.0) ELSE 0.0 END AS Balance
FROM	OOS_Transactions OTR
		INNER JOIN OOS_Deductions ODE ON OTR.Fk_OOS_DeductionId = ODE.OOS_DeductionId
		INNER JOIN OOS_DeductionTypes ODT ON ODE.Fk_OOS_DeductionTypeId = ODT.OOS_DeductionTypeId
		INNER JOIN EscrowAccounts ESA ON ODT.Company = ESA.CompanyId AND ODT.CrdAcctIndex = ESA.AccountIndex
		LEFT JOIN View_EscrowAccountsBalance EST ON ESA.CompanyId = EST.CompanyId AND ESA.AccountNumber = EST.AccountNumber AND ODE.VendorId = EST.VendorId AND ESA.Fk_EscrowModuleId = EST.Fk_EscrowModuleId
WHERE	ESA.Fk_EscrowModuleId <> 10
		AND ODE.VendorId = '9699'
GROUP BY 
		OTR.Fk_OOS_DeductionId
		,EST.Fk_EscrowModuleId
		,ODT.EscrowBalance
		,CASE WHEN ODT.MaintainBalance = 1 AND ODT.EscrowBalance = 1 THEN ISNULL(EST.Balance, 0.0) ELSE 0.0 END