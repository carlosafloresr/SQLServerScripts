DECLARE	@BatchId	Varchar(25) = '9FSI20190925_1657'

SELECT	InvoiceNumber,
		RecordCode,
		ChargeAmount1,
		BatchId,
		GPBatchId,
		VendorDocument,
		Equipment,
		PrePay,
		VndIntercompany,
		PrePayType,
		AccCode
FROM	View_Integration_FSI_Full
WHERE	BatchId = @BatchId
		AND RecordType = 'VND'
		AND SubProcessed = 0
		--AND InvoiceNumber IN ('95-148256')

/*
UPDATE	FSI_ReceivedSubDetails
SET		Processed = 0
WHERE	FSI_ReceivedSubDetailId = 27661750
*/