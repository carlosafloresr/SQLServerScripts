DECLARE	@OTRNumber Int = 6153

SELECT	*
FROM	RSA_Invoice
WHERE	IdRepairNumber = @OTRNumber

SELECT	*
FROM	RSA_InvoiceDetail
WHERE	IdInvoice IN (SELECT id FROM RSA_Invoice WHERE IdRepairNumber = @OTRNumber)

UPDATE	RSA_Invoice
SET		Approved = Null,
		ApprovedBy = Null
WHERE	IdRepairNumber = @OTRNumber