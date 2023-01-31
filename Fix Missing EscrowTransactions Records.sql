
SELECT	*
FROM	EscrowTransactions
WHERE	CompanyID = 'IMC'
		and enteredby = 'AWALKER'
		and VoucherNumber = '1214967'
		--and enteredon > '11/16/2011'
		--and deletedon is null
/*

INSERT INTO [GPCustom].[dbo].[EscrowTransactions]
           ([Source]
           ,[VoucherNumber]
           ,[ItemNumber]
           ,[CompanyId]
           ,[Fk_EscrowModuleId]
           ,[AccountNumber]
           ,[AccountType]
           ,[VendorId]
           ,[Amount]
           ,[Comments]
           ,[ProNumber]
           ,[TransactionDate]
           ,[PostingDate]
           ,[EnteredBy]
           ,[EnteredOn]
           ,[ChangedBy]
           ,[ChangedOn])
           
SELECT	Source
		,VoucherNumber
		,ItemNumber
		,CompanyId
		,Fk_EscrowModuleId
		,AccountNumber
		,AccountType
		,VendorId
		,Amount * -1 AS Amount
		,Comments
		,ProNumber
		,'11/17/2011'
		,'11/17/2011'
		,'AWALKER'
		,GETDATE()
		,'CFLORES'
		,GETDATE()
FROM	EscrowTransactions
WHERE	CompanyID = 'IMC'
		and enteredby = 'AWALKER'
		and VoucherNumber = '1214967'
		and enteredon > '11/16/2011'
		and deletedon is null

UPDATE	EscrowTransactions
SET		DeletedBy = 'CFLORES',
		DeletedOn = GETDATE()
WHERE	EscrowTransactionId = 571393
*/