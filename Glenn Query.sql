SELECT	InvoiceNumber,
		RecordCode,
		ChargeAmount1,
		Equipment,
		VendorDocument
FROM	View_Integration_FSI_Full
WHERE	--InvoiceNumber = '10-128519'
		BatchId = '1FSI20170524_1129'
		AND RecordType = 'VND'