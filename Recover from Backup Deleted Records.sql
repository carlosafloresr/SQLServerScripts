---- SELECT * FROM EscrowTransactions WHERE CompanyId = 'GIS' AND PostingDate = '04/06/2010' AND AccountNumber = '0-01-2794'

INSERT INTO [GPCustom].[dbo].[EscrowTransactions]
           ([Source]
           ,[VoucherNumber]
           ,[ItemNumber]
           ,[CompanyId]
           ,[Fk_EscrowModuleId]
           ,[AccountNumber]
           ,[AccountType]
           ,[VendorId]
           ,[DriverId]
           ,[Division]
           ,[Amount]
           ,[ClaimNumber]
           ,[DriverClass]
           ,[AccidentType]
           ,[Status]
           ,[DMSubmitted]
           ,[DeductionPlan]
           ,[Comments]
           ,[ProNumber]
           ,[TransactionDate]
           ,[PostingDate]
           ,[EnteredBy]
           ,[EnteredOn]
           ,[ChangedBy]
           ,[ChangedOn]
           ,[Void]
           ,[InvoiceNumber]
           ,[OtherStatus]
           ,[DeletedBy]
           ,[DeletedOn])
SELECT		[Source]
           ,[VoucherNumber]
           ,[ItemNumber]
           ,[CompanyId]
           ,[Fk_EscrowModuleId]
           ,[AccountNumber]
           ,[AccountType]
           ,[VendorId]
           ,[DriverId]
           ,[Division]
           ,[Amount]
           ,[ClaimNumber]
           ,[DriverClass]
           ,[AccidentType]
           ,[Status]
           ,[DMSubmitted]
           ,[DeductionPlan]
           ,[Comments]
           ,[ProNumber]
           ,[TransactionDate]
           ,[PostingDate]
           ,[EnteredBy]
           ,[EnteredOn]
           ,[ChangedBy]
           ,[ChangedOn]
           ,[Void]
           ,[InvoiceNumber]
           ,[OtherStatus]
           ,[DeletedBy]
           ,[DeletedOn]
FROM	EscrowTransactions 
WHERE	CompanyId = 'IMC' AND AccountNumber = '0-01-2794' AND PostingDate > '4/1/2010' AND VoucherNumber = '00000000000049803'



CompanyId = 'GIS' 
		AND PostingDate > '4/1/2010' 
		--AND Amount = 50
		AND AccountNumber = '0-00-2790'
		AND VoucherNumber not IN (SELECT VoucherNumber
				FROM	GPCustom.dbo.EscrowTransactions 
				WHERE	CompanyId = 'GIS' 
						AND PostingDate > '4/1/2010'
						--AND Amount = 50
						AND AccountNumber = '0-00-2790')