SELECT	OOS.CrdAccounts
		,OOS.CreditAccount
		,OOS.CrdAcctIndex
		,GL1.ACTINDX
		,OOS.CreditAccount2
		,OOS.CrdAcctIndex2
		,GL2.ACTINDX
FROM	OOS_DeductionTypes OOS
		LEFT JOIN GIS.DBO.GL00105 GL1 ON OOS.CreditAccount = GL1.ACTNUMST
		LEFT JOIN GIS.DBO.GL00105 GL2 ON OOS.CreditAccount2 = GL2.ACTNUMST
WHERE	OOS.Company = 'GIS'

