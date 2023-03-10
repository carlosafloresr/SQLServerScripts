ALTER PROCEDURE [dbo].[USP_SummaryBatchGreatPlains] (@BatchId Varchar(20))
AS
SELECT	ISNULL(CustomerNumber, NationalAccount) AS CustomerNumber
		,NationalAccount
		,InvoiceDate
		,BatchId
		,InvoiceNumber
		,Equipment
		,WorkOrder
		,CASE	WHEN Status IN (1, 2, 3, 8) THEN Amount
				ELSE Amount - ISNULL(InvBalance, 0) END AS Amount
		,0 AS WriteOff
		,TextStatus
		,1 AS RecordType
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
		AND Status IN (1, 2, 3, 5, 8)
UNION
SELECT	NationalAccount AS CustomerNumber
		,NationalAccount
		,PaymentDate
		,BatchId
		,Inv_Batch
		,Null
		,Null
		,SUM(CASE	WHEN Status IN (1, 2, 3, 8) THEN Amount
				ELSE Amount - ISNULL(InvBalance, 0) END) AS Amount
		,0 AS WriteOff
		,Null
		,2 AS RecordType
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
		AND Status IN (1, 2, 3, 5, 8)
GROUP BY
		NationalAccount
		,BatchId
		,UploadDate
		,BatchStatus
		,UserId
		,NationalAccount
		,PaymentDate
		,Payment
		,Status
		,Inv_Batch
ORDER BY 11, 10

-- EXECUTE USP_SummaryBatchGreatPlains 'SUM_FI_08262009'