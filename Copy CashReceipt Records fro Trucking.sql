INSERT INTO CashReceipt
		(InvoiceNumber
		,Amount
		,NationalAccount
		,BatchId
		,Company
		,Processed)
SELECT	InvoiceNumber
		,Payment
		,NationalAccount
		,BatchId
		,Company
		,0
FROM	GPCustom.dbo.CashReceiptTrucking