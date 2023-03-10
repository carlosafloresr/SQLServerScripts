USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CashReceiveRCCL]    Script Date: 10/01/2009 12:56:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_CashReceiveRCCL]
		@Company	Varchar(5),
		@BatchId	Varchar(25),
		@UserId		Varchar(25)
AS
DECLARE	@RunDate	DateTime,
		@ChrDate	Char(8),
		@WkEndDate	DateTime
		
SET		@RunDate	= GETDATE()

IF NOT EXISTS(SELECT TOP 1 BatchId FROM CashReceiptRCCL WHERE BatchId = @BatchId AND Processed = 2)
BEGIN
	DELETE CashReceipt WHERE BatchId = @BatchId
	DELETE CashReceiptBatches WHERE BatchId = @BatchId
				
	SELECT	CH.*,
			VM.RCCLAccount
	INTO	#tmpRecords
	FROM	CashReceiptRCCL CH
			INNER JOIN VendorMaster VM ON CH.Company = VM.Company AND CH.VendorId = VM.VendorId
	WHERE	BatchId = @BatchId
	
	SET		@WkEndDate	= (SELECT TOP 1 WeekEndDate FROM #tmpRecords)
	SET		@ChrDate	= REPLACE(CONVERT(Char(10), @WkEndDate, 101), '/', '')
	SET		@ChrDate	= SUBSTRING(@ChrDate, 1, 4) + SUBSTRING(@ChrDate, 7, 2)

	INSERT INTO CashReceipt
				(InvoiceNumber
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
				,Inv_Batch)
		SELECT	RTRIM(VendorId) + '_' + @ChrDate
				,Amount
				,WeekEndDate
				,Null
				,Null
				,RTRIM(Company) + 'MYTRK'
				,@BatchId
				,@Company
				,1
				,0
				,''
				,Null
				,Amount
				,WeekEndDate
				,Null
				,Null
				,Null
				,RCCLAccount
				,0
				,Amount
				,1
				,Null
				,@BatchId
				,@BatchId
		FROM	#tmpRecords
		
		UPDATE	CashReceiptRCCL 
		SET		Processed = 1
		WHERE	BatchId = @BatchId
		
	INSERT INTO CashReceiptBatches
				(Company
				,BatchId
				,UploadDate
				,BatchStatus
				,UserId
				,PaymentDate
				,IsSummaryBatch)
	VALUES		(@Company
				,@BatchId
				,@RunDate
				,1
				,@UserId
				,@RunDate
				,0)
				
	DROP TABLE #tmpRecords
	
	EXECUTE ILSINT01.Integrations.dbo.USP_ReceivedIntegrations 'CSH', @Company, @BatchId, 2
END

/*
EXECUTE USP_CashReceiveRCCL 'RCCL','AIS_CSH_09242009','CFLORES'

SELECT * FROM RCCL.dbo.RM20101

SELECT	CH.*
		,RM.DocNumbr
		,RM.CurTrxAm
		,RM.DocDate
		,CN.Counter
FROM	CashReceipt CH
		INNER JOIN RCCL.dbo.RM20101 RM ON CH.CustomerNumber = RM.CustNmbr AND RM.CurTrxAm > 0 AND RM.RmdTypal = 1
		INNER JOIN (SELECT CustNmbr, COUNT(DocNumbr) AS Counter FROM RCCL.dbo.RM20101 WHERE CurTrxAm > 0 AND RmdTypal = 1 GROUP BY CustNmbr) CN ON CH.CustomerNumber = CN.CustNmbr 
WHERE	BatchId = 'AIS_CSH_09242009'
ORDER BY
		CH.CustomerNumber
		,RM.DocDate 
*/