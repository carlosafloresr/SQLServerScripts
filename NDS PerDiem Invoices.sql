SELECT	DISTINCT [Customer]
		,[Invoice]
		,CASE WHEN [WithInvoice] = 1 THEN 'YES' ELSE 'NO' END AS WithInvoice
FROM	[GPCustom].[dbo].[NDS_PerDiem]
where	withinvoice = 0