DECLARE	@OTRNumber	Int = 7295
DELETE RSA_InvoiceDetail WHERE IdInvoice IN (SELECT Id FROM RSA_Invoice WHERE IdRepairNumber = @OTRNumber)
DELETE RSA_Invoice WHERE IdRepairNumber = @OTRNumber