SELECT	InvoiceNumber,
		InvoiceTotal,
		RecordCode,
		ChargeAmount1,
		Reference,
		DemurrageAdminFee
FROM	View_Integration_FSI_Full
WHERE	BatchId = '9FSI20210806_1117'
		AND RecordCode = '395'

SELECT	InvoiceNumber,
		InvoiceTotal,
		RecordCode,
		ChargeAmount1,
		Reference
FROM	View_Integration_FSI_Full
WHERE	BatchId = '9FSI20210806_1117'
		AND RecordType = 'VND'
		--AND AccCode = '395'
		AND InvoiceNumber not IN (
SELECT	InvoiceNumber
FROM	View_Integration_FSI_Full
WHERE	BatchId = '9FSI20210806_1117'
		AND RecordCode = '395')