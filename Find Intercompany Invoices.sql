DECLARE	@Invoice Varchar(25)
SET	@Invoice = '15-15474'

SELECT	* 
FROM	FSI_ReceivedDetails 
WHERE	InvoiceNumber = @Invoice
		OR BillToRef = @Invoice

SELECT	* 
FROM	FSI_ReceivedSubDetails 
WHERE	BatchId + DetailId IN (SELECT BatchId + DetailId FROM FSI_ReceivedDetails WHERE InvoiceNumber = @Invoice)
		AND RecordType = 'VND'