DECLARE	@BatchId Varchar(25)
SET		@BatchId = 'GCCP3418'

SELECT	* 
FROM	CashReceipt 
WHERE	BatchId = @BatchId
		AND InvoiceNumber in (
							SELECT	InvoiceNumber
							FROM	(
									SELECT	InvoiceNumber, 
											COUNT(InvoiceNumber) AS Counter 
									FROM	CashReceipt 
									WHERE	BatchId = @BatchId
									GROUP BY InvoiceNumber 
									HAVING COUNT(InvoiceNumber) > 1) RECS)
ORDER BY InvoiceNumber