SELECT	*
FROM	FSI_ReceivedSubDetails
WHERE	BatchId = '3FSI20190710_1009'
		AND RecordType = 'VND'
		AND RecordCode = 'REGION'
		AND PrePay = 1
		AND AccCode IN ('','322')

UPDATE	FSI_ReceivedSubDetails
SET		PrePay = 1
		--,AccCode = '401'
WHERE	BatchId = '3FSI20190710_1009'
		AND RecordType = 'VND'
		AND RecordCode = 'REGION'
		AND AccCode IN ('','')