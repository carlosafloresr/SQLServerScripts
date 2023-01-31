/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [Customer]
		,AccountType
		,CASE [AccountType] WHEN 1 THEN 'TIRE REPLACEMENT' WHEN 2 THEN 'TIRE REPAIR' ELSE 'MECHANICAL' END AS AccountTypeDesc
		,[AccountNumber]
		,[Limit]
		,[Intercompany]
FROM	[Integrations].[dbo].[MSR_Accounts]
WHERE	Company = 'FI'
		AND Customer IN 
		(SELECT Account
		FROM	FSI_Intercompany_ARAP
		WHERE	Company = 'FI' 
				AND RecordType = 'C')
order by 1, 2