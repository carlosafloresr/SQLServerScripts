ALTER PROCEDURE [dbo].[USP_SummaryBatchesSender]
		@Company	Varchar(5),
		@UserId		Varchar(25),
		@Customers	Varchar(1000) = Null
AS
DECLARE	@BatchId	Varchar(25),
		@RunDate	DateTime

SET		@RunDate	= GETDATE()
SET		@BatchId	= 'SUM_' + @Company + '_' + REPLACE(CONVERT(Char(10), @RunDate, 101), '/', '')

IF EXISTS(SELECT TOP 1 Inv_No FROM SummaryBatches WHERE 'I' + Inv_No + Company NOT IN (SELECT InvoiceNumber + Company FROM ILSGP01.GPCustom.dbo.CashReceipt WHERE Company = @Company))
BEGIN
	DELETE ILSGP01.GPCustom.dbo.CashReceipt WHERE BatchId = @BatchId
	DELETE ILSGP01.GPCustom.dbo.CashReceiptBatches WHERE BatchId = @BatchId

	INSERT INTO ILSGP01.GPCustom.dbo.CashReceiptBatches
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
				,0
				,@UserId
				,@RunDate
				,1)

	INSERT INTO ILSGP01.GPCustom.dbo.CashReceipt
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
		SELECT	'I' + Inv_No
				,Inv_Total
				,Inv_Date
				,CASE WHEN Chassis = '' THEN Container ELSE Chassis END
				,Null
				,Acct_No
				,@BatchId
				,@Company
				,0
				,0
				,''
				,Null
				,0
				,Inv_Date
				,Null
				,Null
				,Null
				,Acct_No
				,0
				,0
				,1
				,Null
				,Acct_No
				,'B' + Inv_Batch
		FROM	SummaryBatches
		WHERE	'I' + Inv_No + Company NOT IN (SELECT InvoiceNumber + Company FROM ILSGP01.GPCustom.dbo.CashReceipt WHERE Company = 'FI')
				AND (@Customers IS Null OR (@Customers IS NOT Null AND dbo.AT(Acct_No, @Customers, 1) > 0))
		
		UPDATE	SummaryBatches 
		SET		SummaryBatches.Processed = 1
		FROM	ILSGP01.GPCustom.dbo.CashReceipt CSH
		WHERE	'I' + SummaryBatches.Inv_No = CSH.InvoiceNumber
				AND SummaryBatches.Company = CSH.InvoiceNumber 
				AND SummaryBatches.Company = @Company
END