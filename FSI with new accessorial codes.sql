SELECT	Company, BatchId, InvoiceDate, InvoiceNumber, CustomerNumber, InvoiceTotal, RecordType, RecordCode, PrePay, AccCode, Equipment, PrepayReference AS Reference, ExternalId
FROM	View_Integration_FSI_Full
WHERE	FSI_ReceivedSubDetailId > 40785456
		AND AccCode IN ('CTF','CTT')
ORDER BY Company, BatchId, InvoiceNumber
