ALTER PROCEDURE [dbo].[USP_CashReceiptGreatPlainsRCCL] (@BatchId Varchar(25), @Status Int = 1)
AS
SELECT	ISNULL(CH.CustomerNumber, CH.NationalAccount) AS CustomerNumber
		,CH.NationalAccount
		,CH.InvoiceDate
		,CH.BatchId
		,CH.InvoiceNumber
		,CH.Equipment
		,CH.WorkOrder
		,CH.Amount
		,0 AS WriteOff
		,CH.TextStatus
		,3 AS RecordType
		,CH.UploadDate
		,CH.BatchStatus
		,CH.UserId
		,CH.NationalAccount AS Orig_NationalAccount
		,CH.PaymentDate
		,RM.DocNumbr AS Payment
		,CH.[Status]
		,CH.Inv_Batch
		,RM.CurTrxAm
		,RM.DocDate
		,CN.Counter
		,CAST(RTRIM(CH.InvoiceNumber) + 'D' AS Varchar(30)) AS RMDocNumber
INTO	#TempCursorRCCL
FROM	View_CashReceipt CH
		INNER JOIN RCCL.dbo.RM20101 RM ON CH.CustomerNumber = RM.CustNmbr AND RM.CurTrxAm > 0 AND RM.RmdTypal = 1
		INNER JOIN (SELECT CustNmbr, COUNT(DocNumbr) AS Counter FROM RCCL.dbo.RM20101 WHERE CurTrxAm > 0 AND RmdTypal = 1 GROUP BY CustNmbr) CN ON CH.CustomerNumber = CN.CustNmbr 
WHERE	BatchId = @BatchId
		AND CN.Counter = 1

SELECT	ROW_NUMBER() OVER (ORDER BY CustomerNumber, DocDate) AS 'RowNumber'
		,ISNULL(CH.CustomerNumber, CH.NationalAccount) AS CustomerNumber
		,CH.NationalAccount
		,CH.InvoiceDate
		,CH.BatchId
		,CH.InvoiceNumber
		,CH.Equipment
		,CH.WorkOrder
		,CH.Amount
		,0 AS WriteOff
		,CH.TextStatus
		,3 AS RecordType
		,CH.UploadDate
		,CH.BatchStatus
		,CH.UserId
		,CH.NationalAccount AS Orig_NationalAccount
		,CH.PaymentDate
		,RM.DocNumbr AS Payment
		,CH.[Status]
		,CH.Inv_Batch
		,RM.CurTrxAm
		,RM.DocDate
		,CN.Counter
		,CAST(RTRIM(CH.InvoiceNumber) + 'D' AS Varchar(30)) AS RMDocNumber
INTO	#TempCursorRCCL2
FROM	View_CashReceipt CH
		INNER JOIN RCCL.dbo.RM20101 RM ON CH.CustomerNumber = RM.CustNmbr AND RM.CurTrxAm > 0 AND RM.RmdTypal = 1
		INNER JOIN (SELECT CustNmbr, COUNT(DocNumbr) AS Counter FROM RCCL.dbo.RM20101 WHERE CurTrxAm > 0 AND RmdTypal = 1 GROUP BY CustNmbr) CN ON CH.CustomerNumber = CN.CustNmbr 
WHERE	BatchId = @BatchId
		AND CN.Counter > 1
		
DECLARE	@CustomerNumber	Varchar(25),
		@RowNumber		Int,
		@Amount			Numeric(18,2),
		@CurTrxAm		Numeric(18,2),
		@ApplyTo		Numeric(18,2),
		@Balance		Numeric(18,2),
		@CustNo			Varchar(25),
		@RMDocNumber	Varchar(30)

SET		@CustNo = '-*-*-'

DECLARE Deductions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CustomerNumber
		,RowNumber
		,Amount
		,CurTrxAm
		,RMDocNumber
FROM	#TempCursorRCCL2
ORDER BY CustomerNumber, DocDate

OPEN Deductions 
FETCH FROM Deductions INTO @CustomerNumber, @RowNumber, @Amount, @CurTrxAm, @RMDocNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF @CustomerNumber <> @CustNo
	BEGIN
		SET @CustNo		= @CustomerNumber
		SET	@Balance	= @Amount
	END
	
	IF @Balance > 0
	BEGIN
		SET	@ApplyTo = CASE WHEN @Balance <= @CurTrxAm THEN @Balance
							ELSE @CurTrxAm END
		SET	@Balance = @Balance - @ApplyTo
		
		INSERT INTO #TempCursorRCCL
		SELECT	CustomerNumber
				,NationalAccount
				,InvoiceDate
				,BatchId
				,InvoiceNumber
				,Equipment
				,WorkOrder
				,@ApplyTo AS Amount
				,WriteOff
				,TextStatus
				,RecordType
				,UploadDate
				,BatchStatus
				,UserId
				,Orig_NationalAccount
				,PaymentDate
				,Payment
				,[Status]
				,Inv_Batch
				,CurTrxAm
				,DocDate
				,[Counter]
				,@RMDocNumber
		FROM	#TempCursorRCCL2
		WHERE	CustomerNumber = @CustomerNumber
				AND RowNumber= @RowNumber
	END
	
	FETCH FROM Deductions INTO @CustomerNumber, @RowNumber, @Amount, @CurTrxAm, @RMDocNumber
END

DROP TABLE #TempCursorRCCL2

CLOSE Deductions
DEALLOCATE Deductions

SELECT	*
INTO	#TempCursorRCCL3
FROM	(
SELECT	CustomerNumber
		,NationalAccount
		,InvoiceDate
		,BatchId
		,InvoiceNumber
		,Equipment
		,WorkOrder
		,Amount
		,WriteOff
		,TextStatus
		,RecordType
		,UploadDate
		,BatchStatus
		,UserId
		,Orig_NationalAccount
		,PaymentDate
		,Payment
		,[Status]
		,Null AS Inv_Batch
		,CurTrxAm
		,DocDate
		,ROW_NUMBER() OVER (ORDER BY CustomerNumber) AS RowNumber
		,RecCounter = (SELECT COUNT(InvoiceNumber) FROM #TempCursorRCCL)
		,RMDocNumber + dbo.PADL(ROW_NUMBER() OVER (ORDER BY CustomerNumber), 3, '0') AS RMDocNumber
FROM	#TempCursorRCCL 
WHERE	@Status = 10
UNION
SELECT	CustomerNumber
		,NationalAccount
		,InvoiceDate
		,BatchId
		,RTRIM(InvoiceNumber) + 'D' + dbo.PADL(ROW_NUMBER() OVER (ORDER BY CustomerNumber), 3, '0') AS InvoiceNumber
		,Equipment
		,WorkOrder
		,Amount
		,WriteOff
		,TextStatus
		,1 AS RecordType
		,UploadDate
		,BatchStatus
		,UserId
		,Orig_NationalAccount
		,PaymentDate
		,Payment
		,[Status]
		,Null AS Inv_Batch
		,CurTrxAm
		,DocDate
		,ROW_NUMBER() OVER (ORDER BY CustomerNumber) AS RowNumber
		,0 AS RecCounter
		,Null AS RMDocNumber
FROM	#TempCursorRCCL) RECS
ORDER BY RecordType, RowNumber

DROP TABLE #TempCursorRCCL
--SELECT RMDocNumber, InvoiceNumber INTO CarlosTemp FROM #TempCursorRCCL3

SELECT	*,
		RecPosted = (SELECT COUNT(BatchId) FROM #TempCursorRCCL3 WHERE RMDocNumber IS NOT Null AND RMDocNumber IN (SELECT DocNumbr FROM RCCL.dbo.RM20101 WHERE BachNumb = @BatchId))
FROM	#TempCursorRCCL3

DROP TABLE #TempCursorRCCL3

/*
SELECT	CH.*
		,RM.DocNumbr
		,RM.CurTrxAm
		,RM.DocDate
		,CN.Counter
FROM	View_CashReceipt CH
		INNER JOIN RCCL.dbo.RM20101 RM ON CH.CustomerNumber = RM.CustNmbr AND RM.CurTrxAm > 0 AND RM.RmdTypal = 1
		INNER JOIN (SELECT CustNmbr, COUNT(DocNumbr) AS Counter FROM RCCL.dbo.RM20101 WHERE CurTrxAm > 0 AND RmdTypal = 1 GROUP BY CustNmbr) CN ON CH.CustomerNumber = CN.CustNmbr 
WHERE	BatchId = 'AIS_CSH_09242009'
ORDER BY
		CH.CustomerNumber
		,RM.DocDate 
		
EXECUTE USP_CashReceiveRCCL 'RCCL','AIS_CSH_100109','CFLORES'

EXECUTE USP_CashReceiptGreatPlainsRCCL 'AIS_CSH_100109'

EXECUTE USP_CashReceiptBatchDelete 'RCCL','AIS_CSH_10012009'

SELECT * FROM RCCL.dbo.RM20101 WHERE BachNumb = 'AIS_CSH_10012009'
*/