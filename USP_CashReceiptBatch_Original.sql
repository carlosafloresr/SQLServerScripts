USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CashReceiptBatch]    Script Date: 5/17/2018 3:14:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_CashReceiptBatch 'AIS', 'AIS_TEST_02'
*/
ALTER PROCEDURE [dbo].[USP_CashReceiptBatch] (@Company Varchar(5), @BatchId Varchar(20), @RecordId Int = Null)
AS
DECLARE	@IsInvSum	Bit,
		@DateIni	Datetime,
		@DateEnd	Datetime

IF @Company = 'FI'
BEGIN
	SELECT	@IsInvSum = IsSummaryBatch
	FROM	CashReceiptBatches
	WHERE	Company = @Company
			AND BatchId = @BatchId
END
ELSE
BEGIN
	SET @IsInvSum = 0
END

IF @Company IN ('FI','RCMR')
BEGIN
	UPDATE	CashReceipt 
	SET		InvoiceNumber = REPLACE(InvoiceNumber, 'I', '') 
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CashReceiptId = @RecordId))
			
	SELECT	@DateIni = MIN(InvoiceDate),
			@DateEnd = MAX(InvoiceDate)
	FROM	CashReceipt 
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CashReceiptId = @RecordId))
END

IF @Company = 'FI'
BEGIN
	IF @IsInvSum = 0
	BEGIN -- CASH RECEIPTS
		SELECT	* 
		INTO	#tmpInvoicesFI
		FROM	ILSINT01.FI_Data.dbo.Invoices 
		WHERE	Inv_Date BETWEEN @DateIni - 3 AND @DateEnd + 3

		SELECT	*
		INTO	#tmpRecordsFI
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
				,ISNULL(CR.CustomerNumber, INV.Acct_No) AS CustomerNumber
		FROM	CashReceipt CR
				LEFT JOIN #tmpInvoicesFI INV ON CR.InvoiceNumber = INV.Inv_No
		WHERE	CR.BatchId = @BatchId
				AND CR.InvoiceNumber IS NOT Null
				AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CR.CashReceiptId = @RecordId))
		UNION
		SELECT	CR.CashReceiptId
				,'I' + CAST(INV.Inv_No AS Varchar(10))
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
				,ISNULL(CR.CustomerNumber, INV.Acct_No) AS CustomerNumber
		FROM	CashReceipt CR
				LEFT JOIN #tmpInvoicesFI INV ON CR.WorkOrder = INV.WorkOrder OR (CR.Equipment = INV.Chassis AND INV.Inv_Date BETWEEN CR.InvoiceDate - 3 AND CR.InvoiceDate + 3 AND CR.Amount = INV.Inv_Total)
		WHERE	CR.BatchId = @BatchId
				AND CR.InvoiceNumber IS Null
				AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CR.CashReceiptId = @RecordId))) RECS

		UPDATE	CashReceipt
		SET		CashReceipt.InvoiceNumber	= RECS.InvoiceNumber
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
						,COALESCE(CR.CustomerNumber, RM1.CustNmbr, RM2.CustNmbr) AS CustomerNumber
						,ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) AS InvBalance
						,ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) AS InvAmount
						,CASE	WHEN COALESCE(CR.CustomerNumber, RM1.CustNmbr, RM2.CustNmbr) NOT IN (SELECT CustNmbr FROM FI.dbo.RM00101 WHERE CprcstNm = CR.NationalAccount OR CustNmbr = CR.NationalAccount) THEN 8
								WHEN ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) IS Null AND CR.InvoiceNumber IS Null THEN 1
								WHEN ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) IS Null AND CR.InvoiceNumber IS NOT Null THEN 2
								WHEN ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) = 0 THEN 3
								WHEN CR.Amount = COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) THEN 4
								WHEN CR.Amount > COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) THEN 5
								WHEN CR.Amount < COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) - 1 THEN 6
								WHEN CR.Amount < COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) AND CR.Amount >= COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) - 1 THEN 7 END AS Status
				FROM	#tmpRecordsFI CR
						LEFT JOIN FI.dbo.RM20101 RM1 ON RM1.DocNumbr = CR.InvoiceNumber
						LEFT JOIN FI.dbo.RM30101 RM2 ON RM2.DocNumbr = CR.InvoiceNumber) RECS
		WHERE	CashReceipt.CashReceiptId = RECS.CashReceiptId

		DROP TABLE #tmpInvoicesFI
		DROP TABLE #tmpRecordsFI
	END
	ELSE
	BEGIN -- SUMMARY INVOICING
		SELECT	CashReceiptId
				,'I' + InvoiceNumber AS InvoiceNumber
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
				,CustomerNumber
		INTO	#tmpRecordsFIS
		FROM	CashReceipt
		WHERE	Company = @Company
				AND BatchId = @BatchId

		UPDATE	CashReceipt
		SET		CashReceipt.InvoiceNumber	= RECS.InvoiceNumber
				,CashReceipt.InvBalance		= RECS.InvBalance
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
						,COALESCE(CR.CustomerNumber, RM1.CustNmbr, RM2.CustNmbr) AS CustomerNumber
						,ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) AS InvBalance
						,ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) AS InvAmount
						,CASE	WHEN COALESCE(CR.CustomerNumber, RM1.CustNmbr, RM2.CustNmbr) NOT IN (SELECT CustNmbr FROM FI.dbo.RM00101 WHERE CprcstNm = CR.NationalAccount OR CustNmbr = CR.NationalAccount) THEN 8
								WHEN ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) IS Null AND CR.InvoiceNumber IS Null THEN 1
								WHEN ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) IS Null AND CR.InvoiceNumber IS NOT Null THEN 2
								WHEN ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) = 0 THEN 3
								WHEN CR.Amount = COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) THEN 4
								WHEN CR.Amount > COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) THEN 5
								WHEN CR.Amount < COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) - 1 THEN 6
								WHEN CR.Amount < COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) AND CR.Amount >= COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) - 1 THEN 7 END AS Status
				FROM	#tmpRecordsFIS CR
						LEFT JOIN FI.dbo.RM20101 RM1 ON RM1.DocNumbr = CR.InvoiceNumber
						LEFT JOIN FI.dbo.RM30101 RM2 ON RM2.DocNumbr = CR.InvoiceNumber) RECS
		WHERE	CashReceipt.CashReceiptId = RECS.CashReceiptId

		DROP TABLE #tmpRecordsFIS
	END
END

IF @Company = 'RCMR'
BEGIN
	SELECT	* 
	INTO	#tmpInvoicesRCMR
	FROM	ILSINT01.RCMR_Data.dbo.Invoices 
	WHERE	Inv_Date BETWEEN @DateIni - 3 AND @DateEnd + 3
		
	SELECT	*
	INTO	#tmpRecordsRCMR
	FROM	(
	SELECT	CR.CashReceiptId
			,CR.InvoiceNumber
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
			,ISNULL(CR.CustomerNumber, INV.Acct_No) AS CustomerNumber
	FROM	CashReceipt CR
			LEFT JOIN #tmpInvoicesRCMR INV ON CR.InvoiceNumber = INV.Inv_No
	WHERE	CR.BatchId = @BatchId
			AND CR.InvoiceNumber IS NOT Null
			AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CR.CashReceiptId = @RecordId))
	UNION
	SELECT	CR.CashReceiptId
			,CAST(INV.Inv_No AS Varchar(10))
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
			,ISNULL(CR.CustomerNumber, INV.Acct_No) AS CustomerNumber
	FROM	CashReceipt CR
			LEFT JOIN #tmpInvoicesRCMR INV ON CR.WorkOrder = INV.WorkOrder OR (CR.Equipment = INV.Chassis AND INV.Inv_Date BETWEEN CR.InvoiceDate - 3 AND CR.InvoiceDate + 3 AND CR.Amount = INV.Inv_Total)
	WHERE	CR.BatchId = @BatchId
			AND CR.InvoiceNumber IS Null
			AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CR.CashReceiptId = @RecordId))) RECS

	UPDATE	CashReceipt
	SET		CashReceipt.InvoiceNumber	= RECS.InvoiceNumber
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
					,COALESCE(CR.CustomerNumber, RM1.CustNmbr, RM2.CustNmbr) AS CustomerNumber
					,ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) AS InvBalance
					,ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) AS InvAmount
					,CASE	WHEN COALESCE(CR.CustomerNumber, RM1.CustNmbr, RM2.CustNmbr) NOT IN (SELECT CustNmbr FROM RCMR.dbo.RM00101 WHERE CprcstNm = CR.NationalAccount OR CustNmbr = CR.NationalAccount) THEN 8
							WHEN ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) IS Null AND CR.InvoiceNumber IS Null THEN 1
							WHEN ISNULL(RM1.OrTrxAmt, RM2.OrTrxAmt) IS Null AND CR.InvoiceNumber IS NOT Null THEN 2
							WHEN ISNULL(RM1.CurTrxAm, RM2.CurTrxAm) = 0 THEN 3
							WHEN CR.Amount = COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) THEN 4
							WHEN CR.Amount > COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) THEN 5
							WHEN CR.Amount < COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) - 1 THEN 6
							WHEN CR.Amount < COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) AND CR.Amount >= COALESCE(RM1.CurTrxAm, RM2.CurTrxAm, 0) - 1 THEN 7 END AS Status
			FROM	#tmpRecordsRCMR CR
					LEFT JOIN RCMR.dbo.RM20101 RM1 ON RM1.DocNumbr = CR.InvoiceNumber
					LEFT JOIN RCMR.dbo.RM30101 RM2 ON RM2.DocNumbr = CR.InvoiceNumber) RECS
	WHERE	CashReceipt.CashReceiptId = RECS.CashReceiptId

	DROP TABLE #tmpInvoicesRCMR
	DROP TABLE #tmpRecordsRCMR
END

IF @Company = 'AIS'
BEGIN
	SELECT	*
	INTO	#tmpRecordsAIS
	FROM	(
			SELECT	CR.CashReceiptId
					,CR.InvoiceNumber
					,CR.Amount
					,INV.DocDate AS InvoiceDate
					,CR.NationalAccount
					,CR.BatchId
					,CR.Company
					,CASE WHEN INV.DocNumbr IS Null THEN 0 ELSE 1 END AS MatchedRecord
					,CR.Processed
					,CR.FromFile
					,ISNULL(CR.CustomerNumber, INV.CustNmbr) AS CustomerNumber
					,INV.CurTrxAm AS InvBalance
					,INV.OrTrxAmt AS InvAmount
					,INV.DocNumbr
					,INV.CprcstNm
					,INV.CustNmbr
			FROM	CashReceipt CR
					LEFT JOIN (SELECT	RM.DocNumbr
										,RM.CustNmbr
										,RM.DocDate
										,RM.CurTrxAm
										,RM.OrTrxAmt
										,CM.CprcstNm
								FROM	AIS.dbo.RM20101 RM
										INNER JOIN AIS.dbo.RM00101 CM ON RM.CustNmbr = CM.CustNmbr
								WHERE	DocNumbr IN (SELECT	InvoiceNumber FROM CashReceipt WHERE BatchId = @BatchId AND InvoiceNumber IS NOT Null AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CashReceiptId = @RecordId)))
								UNION
								SELECT	RM.DocNumbr
										,RM.CustNmbr
										,RM.DocDate
										,RM.CurTrxAm
										,RM.OrTrxAmt
										,CM.CprcstNm
								FROM	AIS.dbo.RM30101 RM
										INNER JOIN AIS.dbo.RM00101 CM ON RM.CustNmbr = CM.CustNmbr
								WHERE	DocNumbr IN (SELECT	InvoiceNumber FROM CashReceipt WHERE BatchId = @BatchId AND InvoiceNumber IS NOT Null AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CashReceiptId = @RecordId)))) INV ON CR.InvoiceNumber = INV.DocNumbr
			WHERE	CR.BatchId = @BatchId
					AND CR.InvoiceNumber IS NOT Null
					AND (CR.Status <> 9 OR CR.Status IS NULL) -- Exclude records with invalid date or amount
					AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CR.CashReceiptId = @RecordId))
			) RECS

	UPDATE	CashReceipt
	SET		CashReceipt.CustomerNumber	= RECS.CustomerNumber
			,CashReceipt.InvoiceDate	= RECS.InvoiceDate
			,CashReceipt.InvBalance		= RECS.InvBalance
			,CashReceipt.InvAmount		= RECS.InvAmount
			,CashReceipt.Status			= RECS.Status
	FROM	(SELECT	CashReceiptId
					,InvoiceDate
					,CustomerNumber
					,InvBalance
					,InvAmount
					,CASE	WHEN CustomerNumber <> CustNmbr AND NationalAccount <> CprcstNm THEN 8
							WHEN DocNumbr IS Null THEN 2
							WHEN InvBalance = 0 THEN 3
							WHEN Amount = InvBalance THEN 4
							WHEN Amount > InvBalance THEN 5
							WHEN Amount < InvBalance - 1 THEN 6
							WHEN Amount < InvBalance AND Amount >= InvBalance - 1 THEN 7 END AS Status
			FROM	#tmpRecordsAIS) RECS
	WHERE	CashReceipt.CashReceiptId = RECS.CashReceiptId

	DROP TABLE #tmpRecordsAIS
END

IF @Company = 'GIS'
BEGIN
	SELECT	*
	INTO	#tmpRecordsGIS
	FROM	(
	SELECT	CR.CashReceiptId
			,CR.InvoiceNumber
			,CR.Amount
			,INV.DocDate AS InvoiceDate
			,CR.NationalAccount
			,CR.BatchId
			,CR.Company
			,CASE WHEN INV.DocNumbr IS Null THEN 0 ELSE 1 END AS MatchedRecord
			,CR.Processed
			,CR.FromFile
			,ISNULL(CR.CustomerNumber, INV.CustNmbr) AS CustomerNumber
			,INV.CurTrxAm AS InvBalance
			,INV.OrTrxAmt AS InvAmount
			,INV.DocNumbr
			,INV.CprcstNm
			,INV.CustNmbr
	FROM	CashReceipt CR
			LEFT JOIN (SELECT	RM.DocNumbr
								,RM.CustNmbr
								,RM.DocDate
								,RM.CurTrxAm
								,RM.OrTrxAmt
								,CM.CprcstNm
						FROM	GIS.dbo.RM20101 RM
								INNER JOIN GIS.dbo.RM00101 CM ON RM.CustNmbr = CM.CustNmbr
						WHERE	DocNumbr IN (SELECT	InvoiceNumber FROM CashReceipt WHERE BatchId = @BatchId AND InvoiceNumber IS NOT Null AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CashReceiptId = @RecordId)))
						UNION
						SELECT	RM.DocNumbr
								,RM.CustNmbr
								,RM.DocDate
								,RM.CurTrxAm
								,RM.OrTrxAmt
								,CM.CprcstNm
						FROM	GIS.dbo.RM30101 RM
								INNER JOIN GIS.dbo.RM00101 CM ON RM.CustNmbr = CM.CustNmbr
						WHERE	DocNumbr IN (SELECT	InvoiceNumber FROM CashReceipt WHERE BatchId = @BatchId AND InvoiceNumber IS NOT Null AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CashReceiptId = @RecordId)))) INV ON CR.InvoiceNumber = INV.DocNumbr
	WHERE	CR.BatchId = @BatchId
			AND CR.InvoiceNumber IS NOT Null
			AND (CR.Status <> 9 OR CR.Status IS NULL) -- Exclude records with invalid date or amount
			AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CR.CashReceiptId = @RecordId))) RECS

	UPDATE	CashReceipt
	SET		CashReceipt.CustomerNumber	= RECS.CustomerNumber
			,CashReceipt.InvoiceDate	= RECS.InvoiceDate
			,CashReceipt.InvBalance		= RECS.InvBalance
			,CashReceipt.InvAmount		= RECS.InvAmount
			,CashReceipt.Status			= RECS.Status
	FROM	(SELECT	CashReceiptId
					,InvoiceDate
					,CustomerNumber
					,InvBalance
					,InvAmount
					,CASE	WHEN CustomerNumber <> CustNmbr AND NationalAccount <> CprcstNm THEN 8
							WHEN DocNumbr IS Null THEN 2
							WHEN InvBalance = 0 THEN 3
							WHEN Amount = InvBalance THEN 4
							WHEN Amount > InvBalance THEN 5
							WHEN Amount < InvBalance - 1 THEN 6
							WHEN Amount < InvBalance AND Amount >= InvBalance - 1 THEN 7 END AS Status
			FROM	#tmpRecordsGIS) RECS
	WHERE	CashReceipt.CashReceiptId = RECS.CashReceiptId

	DROP TABLE #tmpRecordsGIS
END

IF @Company = 'IMC'
BEGIN
	SELECT	*
	INTO	#tmpRecordsIMC
	FROM	(
	SELECT	CR.CashReceiptId
			,CR.InvoiceNumber
			,CR.Amount
			,INV.DocDate AS InvoiceDate
			,CR.NationalAccount
			,CR.BatchId
			,CR.Company
			,CASE WHEN INV.DocNumbr IS Null THEN 0 ELSE 1 END AS MatchedRecord
			,CR.Processed
			,CR.FromFile
			,ISNULL(CR.CustomerNumber, INV.CustNmbr) AS CustomerNumber
			,INV.CurTrxAm AS InvBalance
			,INV.OrTrxAmt AS InvAmount
			,INV.DocNumbr
			,INV.CprcstNm
			,INV.CustNmbr
	FROM	CashReceipt CR
			LEFT JOIN (SELECT	RM.DocNumbr
								,RM.CustNmbr
								,RM.DocDate
								,RM.CurTrxAm
								,RM.OrTrxAmt
								,CM.CprcstNm
						FROM	IMC.dbo.RM20101 RM
								INNER JOIN IMC.dbo.RM00101 CM ON RM.CustNmbr = CM.CustNmbr
						WHERE	DocNumbr IN (SELECT	InvoiceNumber FROM CashReceipt WHERE BatchId = @BatchId AND InvoiceNumber IS NOT Null AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CashReceiptId = @RecordId)))
						UNION
						SELECT	RM.DocNumbr
								,RM.CustNmbr
								,RM.DocDate
								,RM.CurTrxAm
								,RM.OrTrxAmt
								,CM.CprcstNm
						FROM	IMC.dbo.RM30101 RM
								INNER JOIN IMC.dbo.RM00101 CM ON RM.CustNmbr = CM.CustNmbr
						WHERE	DocNumbr IN (SELECT	InvoiceNumber FROM CashReceipt WHERE BatchId = @BatchId AND InvoiceNumber IS NOT Null AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CashReceiptId = @RecordId)))) INV ON CR.InvoiceNumber = INV.DocNumbr
	WHERE	CR.BatchId = @BatchId
			AND CR.InvoiceNumber IS NOT Null
			AND (CR.Status <> 9 OR CR.Status IS NULL) -- Exclude records with invalid date or amount
			AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CR.CashReceiptId = @RecordId))) RECS

	UPDATE	CashReceipt
	SET		CashReceipt.CustomerNumber	= RECS.CustomerNumber
			,CashReceipt.InvoiceDate	= RECS.InvoiceDate
			,CashReceipt.InvBalance		= RECS.InvBalance
			,CashReceipt.InvAmount		= RECS.InvAmount
			,CashReceipt.Status			= RECS.Status
	FROM	(SELECT	CashReceiptId
					,InvoiceDate
					,CustomerNumber
					,InvBalance
					,InvAmount
					,CASE	WHEN CustomerNumber <> CustNmbr AND NationalAccount <> CprcstNm THEN 8
							WHEN DocNumbr IS Null THEN 2
							WHEN InvBalance = 0 THEN 3
							WHEN Amount = InvBalance THEN 4
							WHEN Amount > InvBalance THEN 5
							WHEN Amount < InvBalance - 1 THEN 6
							WHEN Amount < InvBalance AND Amount >= InvBalance - 1 THEN 7 END AS Status
			FROM	#tmpRecordsIMC) RECS
	WHERE	CashReceipt.CashReceiptId = RECS.CashReceiptId

	DROP TABLE #tmpRecordsIMC
END

IF @Company = 'NDS'
BEGIN
	SELECT	*
	INTO	#tmpRecordsNDS
	FROM	(
	SELECT	CR.CashReceiptId
			,CR.InvoiceNumber
			,CR.Amount
			,INV.DocDate AS InvoiceDate
			,CR.NationalAccount
			,CR.BatchId
			,CR.Company
			,CASE WHEN INV.DocNumbr IS Null THEN 0 ELSE 1 END AS MatchedRecord
			,CR.Processed
			,CR.FromFile
			,ISNULL(CR.CustomerNumber, INV.CustNmbr) AS CustomerNumber
			,INV.CurTrxAm AS InvBalance
			,INV.OrTrxAmt AS InvAmount
			,INV.DocNumbr
			,INV.CprcstNm
			,INV.CustNmbr
	FROM	CashReceipt CR
			LEFT JOIN (SELECT	RM.DocNumbr
								,RM.CustNmbr
								,RM.DocDate
								,RM.CurTrxAm
								,RM.OrTrxAmt
								,CM.CprcstNm
						FROM	NDS.dbo.RM20101 RM
								INNER JOIN NDS.dbo.RM00101 CM ON RM.CustNmbr = CM.CustNmbr
						WHERE	DocNumbr IN (SELECT	InvoiceNumber FROM CashReceipt WHERE BatchId = @BatchId AND InvoiceNumber IS NOT Null AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CashReceiptId = @RecordId)))
						UNION
						SELECT	RM.DocNumbr
								,RM.CustNmbr
								,RM.DocDate
								,RM.CurTrxAm
								,RM.OrTrxAmt
								,CM.CprcstNm
						FROM	NDS.dbo.RM30101 RM
								INNER JOIN NDS.dbo.RM00101 CM ON RM.CustNmbr = CM.CustNmbr
						WHERE	DocNumbr IN (SELECT	InvoiceNumber FROM CashReceipt WHERE BatchId = @BatchId AND InvoiceNumber IS NOT Null AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CashReceiptId = @RecordId)))) INV ON CR.InvoiceNumber = INV.DocNumbr
	WHERE	CR.BatchId = @BatchId
			AND CR.InvoiceNumber IS NOT Null
			AND (CR.Status <> 9 OR CR.Status IS NULL) -- Exclude records with invalid date or amount
			AND (@RecordId IS Null OR (@RecordId IS NOT Null AND CR.CashReceiptId = @RecordId))) RECS

	UPDATE	CashReceipt
	SET		CashReceipt.CustomerNumber	= RECS.CustomerNumber
			,CashReceipt.InvoiceDate	= RECS.InvoiceDate
			,CashReceipt.InvBalance		= RECS.InvBalance
			,CashReceipt.InvAmount		= RECS.InvAmount
			,CashReceipt.Status			= RECS.Status
	FROM	(SELECT	CashReceiptId
					,InvoiceDate
					,CustomerNumber
					,InvBalance
					,InvAmount
					,CASE	WHEN CustomerNumber <> CustNmbr AND NationalAccount <> CprcstNm THEN 8
							WHEN DocNumbr IS Null THEN 2
							WHEN InvBalance = 0 THEN 3
							WHEN Amount = InvBalance THEN 4
							WHEN Amount > InvBalance THEN 5
							WHEN Amount < InvBalance - 1 THEN 6
							WHEN Amount < InvBalance AND Amount >= InvBalance - 1 THEN 7 END AS Status
			FROM	#tmpRecordsNDS) RECS
	WHERE	CashReceipt.CashReceiptId = RECS.CashReceiptId

	DROP TABLE #tmpRecordsNDS
END

UPDATE	CashReceiptBatches 
SET		BatchStatus = 1 
WHERE	BatchId = @BatchId

/*
SELECT CustNmbr FROM FI.dbo.RM00101 WHERE CustNmbr = '19500'
UNION
SELECT CprcstNm FROM FI.dbo.RM00105 WHERE CprcstNm = '19500'

SELECT * FROM ILSINT01.FI_Data.dbo.Invoices WHERE Chassis IN (SELECT Equipment FROM #tmpRecords WHERE InvoiceNumber IS Null)
SELECT * FROM #tmpRecords
TRUNCATE TABLE CashReceiptBatches
SELECT * FROM ILSINT01.FI_Data.dbo.Invoices WHERE Chassis = 'LSFZ535800'

EXECUTE USP_CashReceiptBatch 'ACH072109MAE'

DELETE CashReceipt WHERE BatchId = 'ACH072109MAE'

UPDATE CashReceipt SET InvoiceNumber = REPLACE(InvoiceNumber, 'I', '') WHERE BatchId = 'ACH072109MAE'

SELECT * FROM View_CashReceipt WHERE BatchId = 'ACH072109MAE' ORDER BY Status, InvoiceNumber

SELECT BatchId, MAX(InvoiceDate) FROM CashReceipt GROUP BY BatchId ORDER BY 2 DESC
SELECT * FROM FI.dbo.RM20101 WHERE DocNumbr LIKE '%371422%'
SELECT * FROM FI.dbo.RM30101 WHERE DocNumbr LIKE '%399461%'
*/