CREATE VIEW View_CashReceipt
AS
SELECT	CashReceiptId
		,InvoiceNumber
		,Amount
		,InvoiceDate
		,Equipment
		,WorkOrder
		,NationalAccount
		,BatchId
		,Company
		,MatchedRecord
		,Processed
		,CustomerNumber
		,InvBalance
		,InvAmount
		,dbo.CashReceiptStatus(Status) AS TextStatus
		,Status
FROM	CashReceipt