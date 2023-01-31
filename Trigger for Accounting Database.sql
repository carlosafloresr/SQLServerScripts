DECLARE	@InvoiceNumber	Int
SET		@InvoiceNumber = 16

SELECT	* 
FROM	View_LineItemDistributions
WHERE	InvoiceNum = @InvoiceNumber