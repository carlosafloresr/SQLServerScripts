/*
EXECUTE USP_IntercompanyInvoice '1801587'
*/
ALTER PROCEDURE USP_IntercompanyInvoice
	@Invoice	Varchar(15)
AS
SELECT	DISTINCT REPLACE(MSR.Inv_no, 'I', '') AS InvoiceNumber, Null AS FIInvoice, inv_total
FROM	Staging.MSR_Import MSR
WHERE	MSR.inv_no = 'I' + @Invoice
ORDER BY 1