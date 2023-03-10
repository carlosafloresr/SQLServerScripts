/*
EXECUTE USP_CashReceiptGreatPlainsDEX DEX111121160000
*/
ALTER PROCEDURE [dbo].[USP_CashReceiptGreatPlainsDEX] (@BatchId Varchar(20))
AS DEXPAY000151372
SELECT	*
FROM	(
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
				,PaymentDate
				,Payment
				,Status
				,Inv_Batch
				,'' AS RowNumber
				,CashReceiptId
		FROM	View_CashReceipt
		WHERE	BatchId = @BatchId
				AND Status IN (1, 2, 3, 8)
				AND Processed = 0
		--UNION
		--SELECT	ISNULL(CustomerNumber, NationalAccount) AS CustomerNumber
		--		,NationalAccount
		--		,PaymentDate AS InvoiceDate
		--		,BatchId
		--		,RTRIM(Payment) + '_OP' + CAST(ROW_NUMBER() OVER (ORDER BY ISNULL(CustomerNumber, NationalAccount)) AS Varchar(3)) AS InvoiceNumber
		--		,NULL AS Equipment
		--		,NULL AS WorkOrder
		--		,SUM(Amount - ISNULL(InvBalance, 0)) AS Amount
		--		,0 AS WriteOff
		--		,TextStatus
		--		,1 AS RecordType
		--		,UploadDate
		--		,BatchStatus
		--		,UserId
		--		,PaymentDate
		--		,Payment
		--		,Status
		--		,Inv_Batch
		--		,'' AS RowNumber
		--		,CashReceiptId
		--FROM	View_CashReceipt
		--WHERE	BatchId = @BatchId
		--		AND Status = 5
		--		AND Processed = 0
		--GROUP BY
		--		ISNULL(CustomerNumber, NationalAccount)
		--		,NationalAccount
		--		,BatchId
		--		,TextStatus
		--		,UploadDate
		--		,BatchStatus
		--		,UserId
		--		,PaymentDate
		--		,Payment
		--		,Status
		--		,Inv_Batch
		--		,CashReceiptId
		--UNION
		--SELECT	NationalAccount AS CustomerNumber
		--		,NationalAccount
		--		,PaymentDate
		--		,BatchId
		--		,RTRIM(BatchId) + '_' + NationalAccount + '-' + CAST(ROW_NUMBER() OVER (ORDER BY NationalAccount) AS Varchar(3))
		--		,Null
		--		,Null
		--		,SUM(CASE WHEN Status IN (1, 2, 3, 8) THEN Amount
		--				ELSE Amount - ISNULL(InvBalance, 0) END) AS Amount
		--		,0 AS WriteOff
		--		,Null
		--		,2 AS RecordType
		--		,UploadDate
		--		,BatchStatus
		--		,UserId
		--		,PaymentDate
		--		,Payment
		--		,Status
		--		,Inv_Batch
		--		,'' AS RowNumber
		--		,CashReceiptId
		--FROM	View_CashReceipt
		--WHERE	BatchId = @BatchId
		--		AND Status IN (1, 2, 3, 5, 8)
		--		AND Processed = 0
		--GROUP BY
		--		NationalAccount
		--		,BatchId
		--		,UploadDate
		--		,BatchStatus
		--		,UserId
		--		,PaymentDate
		--		,Payment
		--		,Status
		--		,Inv_Batch
		--		,CashReceiptId
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
				,PaymentDate
				,Payment
				,Status
				,Inv_Batch
				,'' AS RowNumber
				,CashReceiptId
		FROM	View_CashReceipt
		WHERE	BatchId = @BatchId
				AND Status NOT IN (2, 3, 8)
				AND Processed = 0
		) RECORDS
WHERE	Amount <> 0
ORDER BY 10, 9

/*
EXECUTE USP_CashReceivePayment 'T00051631'
EXECUTE USP_CashReceiptGreatPlains 'GIS_CSH_090111'
EXECUTE USP_CashReceiptGreatPlains 'DNJ_CSH_090111'
SELECT * FROM View_CashReceipt WHERE BatchId = 'T00058610A1'
*/