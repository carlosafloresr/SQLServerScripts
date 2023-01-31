SELECT	Company,
		BatchId,
		InvoiceNumber,
		RecordType,
		RecordCode, 
		ChargeAmount1,
		--VendorDocument,
		COUNT(ChargeAmount1) AS Counter
FROM	View_Integration_FSI_Full
WHERE	WeekEndDate >= '01/01/2016'
		AND RecordType = 'VND'
GROUP BY Company,
		BatchId,
		InvoiceNumber,
		RecordType,
		RecordCode, 
		ChargeAmount1
		--VendorDocument
HAVING COUNT(ChargeAmount1) > 1

--SELECT	*
--FROM	View_Integration_FSI_Full
--WHERE	InvoiceNumber = '10-123345'

--SELECT	* 
--FROM	View_FSI_Intercompany 
--WHERE	OriginalBatchId = '1FSI20160223_1804' 
--		AND Company = 'IMC'
--		AND InvoiceNumber = '10-123345'