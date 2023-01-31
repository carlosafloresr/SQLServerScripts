SELECT	[ERPBatchID]
		,[PaymentNumber]
		,[VendorID]
		,[CheckNumber]
		,CAST([CheckDate] AS Date) AS [CheckDate]
		,[InvoiceNumber]
		,[CheckComment]
		,CAST([DueDate] AS Date) AS [DueDate]
		,CAST([InvoiceDate] AS Date) AS [InvoiceDate]
		,CAST([NetAmount] AS Numeric(10,2)) AS [NetAmount]
		,[TRXStatus]
		,[Cleared]
		,[InvoiceDescription]
		,[PaymentType]
		,CASE WHEN [PaymentType] = 'DXPCHK' AND [ERPBatchID] LIKE '%CK%' THEN 'YES'
			  WHEN [PaymentType] = 'ACH' AND [ERPBatchID] LIKE '%EFT%' THEN 'YES'
			  ELSE 'NO' END AS Valid
		,[AddressCode]
		,[CheckBookID]
		,[PaymentFileName]		
FROM	[RegalPay_OIS].[dbo].[PaymentTransactions]		
WHERE	TRXStatus IN (0,9)
		AND [CheckDate] = CAST(GETDATE() AS Date)
