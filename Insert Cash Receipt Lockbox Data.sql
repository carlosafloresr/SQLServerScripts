--SELECT	*
--FROM	CashReceipts_Lockbox
--WHERE	InvoiceNumber IN (SELECT DOCNUMBR FROM AIS.DBO.RM00401)

-- DELETE CashReceipt WHERE BatchId = 'AIS_TEST_02'

DECLARE	@BatchId Varchar(15) = 'AIS_TEST_02'

INSERT INTO CashReceipt (BatchId, InvoiceNumber, Amount, InvAmount, InvoiceDate, Company)
SELECT	@BatchId AS BatchId,
		CASE WHEN InvoiceNumber NOT LIKE '%-%' AND (LEN(InvoiceNumber) < 7 OR LEN(InvoiceNumber) > 8) THEN InvoiceNumber 
			 WHEN InvoiceNumber NOT LIKE '%-%' AND LEN(InvoiceNumber) BETWEEN 7 AND 8  THEN LEFT(InvoiceNumber, CASE WHEN LEN(InvoiceNumber) = 7 THEN 1 ELSE 2 END) + '-' + RIGHT(RTRIM(InvoiceNumber), 6) 
		ELSE InvoiceNumber END AS InvoiceNumber ,
		Amount,
		Amount,
		ProcessingDate,
		'AIS' AS Company
FROM	CashReceipts_Lockbox
WHERE	RecordId > 11

INSERT INTO CashReceiptBatches (Company, BatchId, UserId) VALUES ('AIS', @BatchId, 'CFLORES')

--WHERE	_Invoice_Number_ IN (SELECT DOCNUMBR FROM AIS.DBO.RM00401)
