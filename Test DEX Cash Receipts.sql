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
		,FromFile
		,Orig_InvoiceNumber
		,Orig_Amount
		,Orig_InvoiceDate
		,Orig_Equipment
		,Orig_WorkOrder
		,Orig_NationalAccount
		,CustomerNumber
		,InvBalance
		,InvAmount
		,Status
		,Comments
		,Payment
		,Inv_Batch
		,Fk_CheckId
FROM	CashReceipt
WHERE	Company = 'AIS'

SELECT	* 
FROM	CashReceiptBatches 
WHERE	Company = 'AIS'
/*
DELETE CashReceipt WHERE Company = 'AIS'
DELETE CashReceiptBatches WHERE Company = 'AIS'

SELECT * FROM CashReceiptBatches WHERE Company = 'AIS'
select * from View_CashReceipt WHERE Company = 'IMC'
*/