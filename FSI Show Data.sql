SELECT	InvoiceNumber, CustomerNumber, InvoiceTotal, PrePay, RecordType, RecordCode, Reference, ChargeAmount1, PrePayType, AccCode, PrepayReference, VendorDocument
FROM	View_Integration_FSI_Full
WHERE	BatchId = '9FSI20230126_1006'
		AND ((RecordType = 'ACC' AND AccCode = 'DEM')
		OR (RecordType = 'VND' AND AccCode = 'DEM' OR PrePayType IN ('A','P')))
		--InvoiceNumber = '95-258453'

SELECT	*
FROM	FSI_TransactionDetails
WHERE	BatchId = '9FSI20230126_1006'
		AND IntegrationType = 'FSIG'
		--InvoiceNumber = '95-258453'
