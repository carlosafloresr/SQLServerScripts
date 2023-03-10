ALTER PROCEDURE [dbo].[USP_CashReceiptGreatPlainsSummary] (@BatchId Varchar(20))
AS
SELECT	NationalAccount AS CustomerNumber
		,NationalAccount
		,PaymentDate
		,BatchId
		,'B' + RTRIM(BatchId) + '_DBT' AS InvoiceNumber
		,Null AS Equipment
		,Null AS WorkOrder
		,SUM(InvBalance) AS Amount
		,0 AS WriteOff
		,Null AS TextStatus
		,0 AS RecordType
		,UploadDate
		,BatchStatus
		,UserId
		,NationalAccount
		,PaymentDate
		,Payment
		,8 AS [Status]
		,'B' + RTRIM(BatchId) + '_DBT' AS Inv_Batch
FROM	View_CashReceipt
WHERE	BatchId = @BatchId
GROUP BY
		NationalAccount
		,BatchId
		,UploadDate
		,BatchStatus
		,UserId
		,NationalAccount
		,PaymentDate
		,Payment
		,Inv_Batch
UNION		
SELECT	NationalAccount AS CustomerNumber
		,NationalAccount
		,PaymentDate
		,BatchId
		,'B' + RTRIM(BatchId) + '_SUM' AS InvoiceNumber
		,Null
		,Null
		,SUM(InvBalance) AS Amount
		,0 AS WriteOff
		,Null
		,2 AS RecordType
		,UploadDate
		,BatchStatus
		,UserId
		,NationalAccount
		,PaymentDate
		,Payment
		,8
		,Inv_Batch
FROM	View_CashReceipt
WHERE	BatchId = @BatchId
GROUP BY
		NationalAccount
		,BatchId
		,UploadDate
		,BatchStatus
		,UserId
		,NationalAccount
		,PaymentDate
		,Payment
		,Inv_Batch
UNION
SELECT	ISNULL(CustomerNumber, NationalAccount) AS CustomerNumber
		,NationalAccount
		,InvoiceDate
		,BatchId
		,InvoiceNumber
		,Equipment
		,WorkOrder
		,CASE WHEN Status = 5 THEN InvBalance ELSE Amount END AS Amount
		,CASE WHEN Status = 7 THEN InvBalance - Amount ELSE 0 END AS PayOff
		,TextStatus
		,3 AS RecordType
		,UploadDate
		,BatchStatus
		,UserId
		,NationalAccount
		,PaymentDate
		,Payment
		,Status
		,Inv_Batch
FROM	View_CashReceipt
WHERE	BatchId = @BatchId
		AND Status NOT IN (1, 2, 3, 8)
ORDER BY 11, 10

-- EXECUTE USP_CashReceivePayment 'T00051631'
-- EXECUTE USP_CashReceiptGreatPlains 'T00051631'
-- USP_CashReceiptGreatPlainsSummary '41916'