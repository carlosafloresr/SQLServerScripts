SELECT	InvoiceNumber
FROM	[dbo].[FSI_ReceivedDetails]
WHERE	BatchId = '7FSI20161212_1632'

SELECT	TrxDscrn, VendorDocument
FROM	View_Integration_FSI_Vendors
WHERE	BatchId = '7FSI20161212_1632'