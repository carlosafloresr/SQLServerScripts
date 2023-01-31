USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_TIPIntegration]    Script Date: 1/20/2023 6:53:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
EXECUTE USP_TIPIntegration '6FSI20221110_1618', 1
*/
ALTER PROCEDURE [dbo].[USP_TIPIntegration]
	@BatchId	Varchar(25),
	@Processed	Bit = 0
AS
-- [AccountNumber = Credit/InterAccount = Debit]
IF @BatchId LIKE '%FSI%'
BEGIN
	SELECT	DISTINCT FSI.RecordId,
			FSI.Company,
			FSI.BooksAccount,
			FSI.Description,
			FSI.InvoiceNumber,
			FSI.InvoiceDate,
			FSI.Amount,
			FSI.LinkType,
			FSI.InterAccount, --CASE WHEN FSI.Amount > 0 THEN FSI.InterAccount ELSE FSI.AccountNumber END AS InterAccount, -- Debit
			FSI.AccountNumber, --CASE WHEN FSI.Amount > 0 THEN FSI.AccountNumber ELSE FSI.InterAccount END AS AccountNumber, -- Credit
			IIF(FSI.PrePay = 1 AND FSI.ICB = 1, 0, 1) AS PrePay,
			FSI.ICB,
			RCV.ReverseBatch,
			RCV.Reprocess,
			FSI.Parameter,
			FSI.AR_PrePayType,
			FSI.MappingValidation,
			FSI.Equipment,
			FSI.ExternalId
	FROM	View_FSI_Intercompany FSI
			LEFT JOIN TIP_IntegrationRecords TIP ON FSI.RecordId = TIP.TIPIntegrationId
			LEFT JOIN ReceivedIntegrations RCV ON FSI.Company = RCV.Company AND FSI.OriginalBatchId = RCV.BatchId AND RCV.Integration = 'TIP'
	WHERE	FSI.FSIBatchId = @BatchId
			AND ((TIP.TIPIntegrationId IS Null AND FSI.TipProcessed = @Processed)
			OR FSI.TipProcessed = @Processed)
	ORDER BY FSI.LinkType, FSI.Description
END
ELSE
BEGIN
	SELECT	FSI.RecordId,
			FSI.Company,
			FSI.BooksAccount,
			FSI.Description,
			FSI.InvoiceDate,
			FSI.Amount,
			FSI.LinkType,
			FSI.AccountNumber,
			FSI.InterAccount
	FROM	View_FSI_Intercompany FSI
			LEFT JOIN TIP_IntegrationRecords TIP ON FSI.RecordId = TIP.TIPIntegrationId
	WHERE	FSI.BatchId = @BatchId
			AND TIP.TIPIntegrationId IS Null
			AND FSI.TipProcessed = @Processed
	ORDER BY FSI.LinkType, FSI.Description
END
