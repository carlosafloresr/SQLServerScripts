USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CashReceiptBatch]    Script Date: 3/14/2019 10:21:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_CashReceiptBatch 'AIS', 'LCKBX022819094244'
*/
ALTER PROCEDURE [dbo].[USP_CashReceiptBatch] 
		@Company	Varchar(5), 
		@BatchId	Varchar(20), 
		@RecordId	Int = Null
AS
DECLARE	@IsInvSum	Bit,
		@DateIni	Datetime,
		@DateEnd	Datetime,
		@WriteOff	Numeric(10,2),
		@Query		Varchar(Max)

SET @WriteOff = ISNULL((SELECT TOP 1 VarN FROM Parameters WHERE ParameterCode = 'AR_WRITEOFF' AND Company = @Company OR Company = 'ALL'), 1)

DECLARE @tblRecords	Table (
		CashReceiptId	int NOT NULL,
		InvoiceNumber	varchar(25) NULL,
		Amount			numeric(18, 2) NULL,
		InvoiceDate		date NULL,
		NationalAccount varchar(12) NULL,
		BatchId			varchar(16) NOT NULL,
		Company			varchar(5) NOT NULL,
		MatchedRecord	int NOT NULL,
		Processed		int NOT NULL,
		FromFile		varchar(50) NULL,
		CustomerNumber	varchar(15) NULL,
		InvBalance		numeric(19, 5) NULL,
		InvAmount		numeric(19, 5) NULL,
		PayAmount		numeric(38, 2) NULL,
		DocNumbr		varchar(21) NULL,
		CprcstNm		varchar(15) NULL,
		CustNmbr		varchar(15) NULL)

SET @Query = N'SELECT * FROM (
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
					,LB.Amount AS PayAmount
					,INV.DocNumbr
					,INV.CprcstNm
					,INV.CustNmbr
			FROM	CashReceipt CR
					INNER JOIN View_CashReceipts_Lockbox_Summay LB ON CR.Company = LB.Company AND CR.BatchId = LB.BatchNumber AND CR.InvoiceNumber = LB.InvoiceNumber
					LEFT JOIN (SELECT	RM.DocNumbr
										,RM.CustNmbr
										,RM.DocDate
										,RM.CurTrxAm
										,RM.OrTrxAmt
										,CM.CprcstNm
								FROM	' + @Company + '.dbo.RM20101 RM
										INNER JOIN ' + RTRIM(@Company) + '.dbo.RM00101 CM ON RM.CustNmbr = CM.CustNmbr
								WHERE	DocNumbr IN (SELECT	InvoiceNumber FROM CashReceipt WHERE Company = ''' + RTRIM(@Company) + ''' AND BatchId = ''' + RTRIM(@BatchId) + ''' AND InvoiceNumber IS NOT Null' + IIF(@RecordId IS Null, '', ' AND CashReceiptId = ' + CAST(@RecordId AS Varchar)) + ') 
										OR REPLACE(DocNumbr, ''-'', '''') IN (SELECT	InvoiceNumber FROM CashReceipt WHERE Company = ''' + RTRIM(@Company) + ''' AND BatchId = ''' + RTRIM(@BatchId) + ''' AND InvoiceNumber IS NOT Null' + IIF(@RecordId IS Null, '', ' AND CashReceiptId = ' + CAST(@RecordId AS Varchar)) + ') 
								UNION
								SELECT	RM.DocNumbr
										,RM.CustNmbr
										,RM.DocDate
										,RM.CurTrxAm
										,RM.OrTrxAmt
										,CM.CprcstNm
								FROM	' + @Company + '.dbo.RM30101 RM
										INNER JOIN ' + RTRIM(@Company) + '.dbo.RM00101 CM ON RM.CustNmbr = CM.CustNmbr
								WHERE	DocNumbr IN (SELECT	InvoiceNumber FROM CashReceipt WHERE Company = ''' + RTRIM(@Company) + ''' AND BatchId = ''' + RTRIM(@BatchId) + ''' AND InvoiceNumber IS NOT Null' + IIF(@RecordId IS Null, '', ' AND CashReceiptId = ' + CAST(@RecordId AS Varchar)) + ') 
										OR REPLACE(DocNumbr, ''-'', '''') IN (SELECT	InvoiceNumber FROM CashReceipt WHERE Company = ''' + RTRIM(@Company) + ''' AND BatchId = ''' + RTRIM(@BatchId) + ''' AND InvoiceNumber IS NOT Null' + IIF(@RecordId IS Null, '', ' AND CashReceiptId = ' + CAST(@RecordId AS Varchar)) + ')
								) INV ON CR.InvoiceNumber = INV.DocNumbr
			WHERE	CR.BatchId = ''' + RTRIM(@BatchId) + '''
					AND CR.InvoiceNumber IS NOT Null
					AND (CR.Status <> 9 OR CR.Status IS NULL)'

IF @RecordId IS NOT Null
	SET @Query = @Query + 'AND CR.CashReceiptId = ' + CAST(@RecordId AS Varchar)

SET @Query = @Query + ') RECS'
PRINT @Query
INSERT INTO @tblRecords
EXECUTE(@Query)

UPDATE	CashReceipt
SET		CashReceipt.CustomerNumber	= RECS.CustomerNumber
		,CashReceipt.InvoiceDate	= RECS.InvoiceDate
		,CashReceipt.InvBalance		= RECS.InvBalance
		,CashReceipt.InvAmount		= RECS.InvAmount
		,CashReceipt.Status			= RECS.Status
FROM	(SELECT	CashReceiptId
				,RTRIM(InvoiceNumber) AS InvoiceNumber
				,CAST(InvoiceDate AS Date) AS InvoiceDate
				,CustomerNumber
				,InvBalance
				,InvAmount
				,PayAmount
				,CASE	WHEN CustomerNumber <> CustNmbr AND NationalAccount <> CprcstNm THEN 8 --Invoice not for this customer
						WHEN DocNumbr IS Null THEN 2 -- The invoice is unmatched
						WHEN InvBalance = 0 THEN 3 -- The invoice is fully paid already
						WHEN PayAmount = InvBalance THEN 4 -- Perfect match
						WHEN PayAmount > InvBalance THEN 5 -- Payment grather than current balance
						WHEN PayAmount < InvBalance - 1 THEN 6 -- Underpaid
						WHEN PayAmount < InvBalance AND PayAmount >= InvBalance - @WriteOff THEN 7 -- Writeoff
						ELSE 1 END AS Status -- Undefined
		FROM	@tblRecords
		) RECS
WHERE	CashReceipt.CashReceiptId = RECS.CashReceiptId

UPDATE	CashReceiptBatches 
SET		BatchStatus = 1 
WHERE	BatchId = @BatchId