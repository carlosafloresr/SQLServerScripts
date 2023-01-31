declare	@BatchId Varchar(20), 
		@RecordId Int

SET @BatchId	= 'T00051463'
SET	@RecordId	= Null

SELECT	*
INTO	#tmpRecords
FROM	(
SELECT	CR.CashReceiptId
		,'I' + CR.InvoiceNumber AS InvoiceNumber
		,CR.Amount
		,CR.InvoiceDate
		,COALESCE(CR.Equipment, INV.Chassis, INV.Container) AS Equipment
		,ISNULL(CR.WorkOrder, INV.WorkOrder) AS WorkOrder
		,CR.NationalAccount
		,CR.BatchId
		,CR.Company
		,CR.MatchedRecord
		,CR.Processed
		,CR.FromFile
FROM	CashReceipt CR
		LEFT JOIN ILSINT01.FI_Data.dbo.Invoices INV ON CR.InvoiceNumber = INV.Inv_No
WHERE	CR.BatchId = @BatchId
		AND CR.InvoiceNumber IS NOT Null
		AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CR.CashReceiptId = @RecordId))
UNION
SELECT	CR.CashReceiptId
		,'I' + CAST(INV.Inv_No AS Varchar(10)) AS InvoiceNumber
		,CR.Amount
		,CR.InvoiceDate
		,CR.Equipment
		,CR.WorkOrder
		,CR.NationalAccount
		,CR.BatchId
		,CR.Company
		,CR.MatchedRecord
		,CR.Processed
		,CR.FromFile
FROM	CashReceipt CR
		LEFT JOIN ILSINT01.FI_Data.dbo.Invoices INV ON CR.WorkOrder = INV.WorkOrder OR (CR.Equipment = INV.Chassis AND INV.Inv_Date BETWEEN CR.InvoiceDate - 3 AND CR.InvoiceDate + 3 AND CR.Amount = INV.Inv_Total)
WHERE	CR.BatchId = @BatchId
		AND CR.InvoiceNumber IS Null
		AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CR.CashReceiptId = @RecordId))) RECS

UPDATE	CashReceipt
SET		CashReceipt.InvoiceNumber	= CASE WHEN CashReceipt.InvoiceNumber IS Null THEN RECS.InvoiceNumber ELSE CashReceipt.InvoiceNumber END
		,CashReceipt.Equipment		= CASE WHEN CashReceipt.Equipment IS Null THEN RECS.Equipment ELSE CashReceipt.Equipment END
		,CashReceipt.WorkOrder		= CASE WHEN CashReceipt.WorkOrder IS Null THEN RECS.WorkOrder ELSE CashReceipt.WorkOrder END
		,CashReceipt.CustomerNumber	= RECS.CustomerNumber
		,CashReceipt.InvBalance		= RECS.InvBalance
		,CashReceipt.InvAmount		= RECS.InvAmount
		,CashReceipt.Status			= RECS.Status
FROM	(
		SELECT	CR.CashReceiptId
				,CR.InvoiceNumber
				,CR.Amount
				,CR.InvoiceDate
				,CR.Equipment
				,CR.WorkOrder
				,CR.NationalAccount
				,CR.BatchId
				,CR.Company
				,CR.MatchedRecord
				,CR.Processed
				,CR.FromFile
				,ISNULL(RM1.CustNmbr, RM2.CustNmbr) AS CustomerNumber
				,ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) AS InvBalance
				,ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) AS InvAmount
				,CASE	WHEN ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) IS Null AND CR.InvoiceNumber IS Null THEN 1
						WHEN ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) IS Null AND CR.InvoiceNumber IS NOT Null THEN 2
						WHEN ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) = 0 THEN 3
						WHEN CR.Amount = COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) THEN 4
						WHEN CR.Amount > COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) THEN 5
						WHEN CR.Amount < COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) - 1 THEN 6
						WHEN CR.Amount < COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) AND CR.Amount >= COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) - 1 THEN 7 END AS Status
		FROM	#tmpRecords CR
				LEFT JOIN FI.dbo.RM20101 RM1 ON RM1.DocNumbr = CR.InvoiceNumber
				LEFT JOIN FI.dbo.RM30101 RM2 ON RM2.DocNumbr = CR.InvoiceNumber) RECS
WHERE	CashReceipt.CashReceiptId = RECS.CashReceiptId

DROP TABLE #tmpRecords