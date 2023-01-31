USE [Integrations]
GO

/****** Object:  View [dbo].[FSI_NonSalesRecords]    Script Date: 9/29/2022 2:49:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[FSI_NonSalesRecords]
AS
SELECT	[RecordId]
		,[Company]
		,[BatchId]
		,[GL_BatchId]
		,[InvoiceNumber]
		,[VndCustId] AS [VendorId]
		,[VndCustName] AS [VendorName]
		,[Amount]
		,[RefDocument] AS [Reference]
		,[TransType]
		,[CreditAccount]
		,[DebitAccount]
		,[IntegrationType]
		,[GPBatch]
FROM	[Integrations].[dbo].[FSI_TransactionDetails]
WHERE	SourceType = 'AP'
GO