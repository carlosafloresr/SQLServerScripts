USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CashReceiptGreatPlains]    Script Date: 08/28/2009 11:38:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_CashReceiptGreatPlains] (@BatchId Varchar(20))
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
		,RTRIM(BatchId) + '_' + NationalAccount
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
		AND Status NOT IN (1, 2, 3, 5, 8)
ORDER BY 11, 10

-- EXECUTE USP_CashReceivePayment 'T00051631'
-- EXECUTE USP_CashReceiptGreatPlains 'T00051631'