DECLARE	@VendorId		Varchar(15), 
		@DocumentNo		Varchar(30), 
		@Amount			Numeric(10,2), 
		@Invoice		Varchar(30), 
		@InvoiceAmount	Numeric(10,2)

SET NOCOUNT ON

DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CustomerVendor,
		RTRIM(ApplyFrom) AS ApplyFrom,
		SUM(IIF(ApplyAmount > 0, ApplyAmount, 0)) AS TotalAmountFrom,
		RTRIM(ApplyFrom) + 'D' AS ApplyInvoice,
		SUM(IIF(ApplyAmount < 0, ABS(ApplyAmount), 0)) AS TotalAmountInvoice
FROM	IntegrationsDB.[Integrations].[dbo].[Integrations_ApplyTo]
WHERE	ApplyFrom IN ('TIP0417181134','TIP0417181240','TIP0417181248','TIP0417181255','TIP0417181259','TIP0426180946','TIP0501181704','TIP0504181046','TIP0518181422','TIP0518181500','TIP0621181325')
		AND RecordType = 'AP'
GROUP BY 
		CustomerVendor, ApplyFrom

OPEN curTransactions 
FETCH FROM curTransactions INTO @VendorId, @DocumentNo, @Amount, @Invoice, @InvoiceAmount

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Credit Memo: ' + @DocumentNo

	EXECUTE USP_FIX_TIPTransactions @VendorId, @DocumentNo, @Amount, @Invoice, @InvoiceAmount

	FETCH FROM curTransactions INTO @VendorId, @DocumentNo, @Amount, @Invoice, @InvoiceAmount
END

CLOSE curTransactions
DEALLOCATE curTransactions