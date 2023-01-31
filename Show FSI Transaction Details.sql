USE [Integrations]
GO

SELECT [Company]
      ,[BatchId]
      ,[WeekendDate]
      ,[InvoiceNumber]
      ,[InvoiceDate]
      ,[VndCustId]
      ,[VndCustName]
      ,[Amount]
      ,[RefDocument]
      ,[VoucherNumber]
      ,[TransType]
      ,[CreditAccount]
      ,[DebitAccount]
      ,[IntegrationType]
      ,[SourceType]
FROM	FSI_TransactionDetails
WHERE	BatchId = '9FSI20210709_1551'
ORDER BY IntegrationType, TransType, SourceType, InvoiceNumber

-- execute USP_FSI_NonSalesRecords '1FSI20210630_0956'