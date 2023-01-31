USE [GPCustom]
GO

/****** Object:  View [dbo].[View_CashReceipt]    Script Date: 3/26/2019 12:13:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_CashReceipt]
AS
SELECT	DISTINCT CashReceiptId
		,CASE WHEN CAD.InvoiceNumber IN ('0','00','000') THEN 'NO_INVOICE' ELSE CAD.InvoiceNumber END AS InvoiceNumber
		,CAD.Amount
		,CAD.InvoiceDate
		,CAD.Equipment
		,CAD.WorkOrder
		,CAD.NationalAccount
		,CAD.BatchId
		,CAD.Company
		,CAD.MatchedRecord
		,CAD.Processed
		,CAD.CustomerNumber
		,CAD.InvBalance
		,CAD.InvAmount
		,dbo.CashReceiptStatus(CAD.Status) AS TextStatus
		,CAD.Status
		--,dbo.CashReceiptStatus(CASE WHEN CAD.Company = 'RCCL' AND CAD.MatchedRecord = 1 THEN 4 ELSE CAD.Status END) AS TextStatus
		--,CASE WHEN CAD.Company = 'RCCL' AND CAD.MatchedRecord = 1 THEN 4 ELSE CAD.Status END AS Status
		,CAD.Comments
		,CAH.UploadDate
		,CAH.BatchStatus
		,CAH.PaymentDate
		,CAH.UserId
		,LOC.INV_Number AS Payment
		,RTRIM(LOC.SerialNumber) AS CheckNumber
		,CAD.Inv_Batch
		,CAD.InvBalance - (SELECT SUM(INV_Number) FROM CashReceipts_Lockbox VCL WHERE CAD.Company = VCL.Company AND CAD.BatchId = VCL.BatchNumber AND CAD.InvoiceNumber = VCL.InvoiceNumber) AS [Difference]
		,CAD.CreditAmount
		,LOC.RecordId
		,CAD.Orig_InvoiceNumber 
FROM	CashReceipt CAD
		INNER JOIN CashReceiptBatches CAH ON CAD.BatchId = CAH.BatchId
		LEFT JOIN CashReceipts_Lockbox LOC ON CAD.SourceId = LOC.RecordId
		--INNER JOIN View_CashReceipts_Lockbox_Summay VCL ON CAD.Company = VCL.Company AND CAD.BatchId = VCL.BatchNumber AND CAD.InvoiceNumber = VCL.InvoiceNumber
GO


