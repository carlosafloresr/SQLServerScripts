ALTER VIEW [dbo].[View_CashReceipt]
AS
SELECT	DISTINCT CashReceiptId
		,CAD.InvoiceNumber
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
FROM	CashReceipt CAD
		INNER JOIN CashReceipts_Lockbox LOC ON CAD.SourceId = LOC.RecordId
		INNER JOIN CashReceiptBatches CAH ON CAD.BatchId = CAH.BatchId
		--INNER JOIN View_CashReceipts_Lockbox_Summay VCL ON CAD.Company = VCL.Company AND CAD.BatchId = VCL.BatchNumber AND CAD.InvoiceNumber = VCL.InvoiceNumber
GO


