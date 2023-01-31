/*
SELECT * FROM KarmakIntegration WHERE BatchId = 'SLSWE100910'
SELECT * FROM View_KarmakIntegration WHERE KIMBatchId = 'KM1105051415' AND Processed = 5 ORDER BY InvoiceNumber
SELECT * FROM View_KarmakIntegration WHERE KIMBatchId = 'KM1105051415' AND (Account1 = '1-04-6315')

UPDATE	KarmakIntegration
SET		Account1 = '0-00-1100',
		Processed = 5,
		AcctApproved = 1
WHERE	KIMBatchId = 'KM1105051415'
		AND Account1 = '1-04-6315'
*/
UPDATE	KarmakIntegration
SET		Account1 = REPLACE(Account1, '-DD-', '-09-'),
		Account2 = REPLACE(Account2, '-DD-', '-09-'),
		Account3 = REPLACE(Account3, '-DD-', '-09-'),
		Processed = 5,
		AcctApproved = 1
WHERE	BatchId = 'SLSWE100910'