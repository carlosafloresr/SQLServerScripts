UPDATE 	GPCustom.dbo.OOS_DeductionTypes
SET 	CrdAcctIndex = GL00105.ActIndx
FROM	GL00105
WHERE	GPCustom.dbo.OOS_DeductionTypes.CreditAccount = GL00105.ACTNUMST
		AND GPCustom.dbo.OOS_DeductionTypes.Company = 'DNJ'