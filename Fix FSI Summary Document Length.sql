DECLARE @tblDocs Table (BatchId Varchar(30), InvoiceNumber Varchar(30), NewDocNumber Varchar(20))

INSERT INTO @tblDocs
SELECT	BatchId, InvoiceNumber, REPLACE(REPLACE(InvoiceNumber, 'DRAYAGE', 'DRAY'), ' ', '')
FROM	FSI_ReceivedDetails
WHERE	BatchId IN (
SELECT	BatchId
FROM	ReceivedIntegrations
WHERE	Integration = 'FSI'
		AND BatchId LIKE '%_SUM%'
		AND Company = 'AIS'
		AND ReceivedOn > '01/12/2022')
		AND DetailId = 1
		AND LEN(InvoiceNumber) > 17

UPDATE	FSI_ReceivedDetails
SET		FSI_ReceivedDetails.VoucherNumber	= DATA.NewDocNumber,
		FSI_ReceivedDetails.InvoiceNumber	= DATA.NewDocNumber,
		FSI_ReceivedDetails.ApplyTo			= DATA.NewDocNumber,
		FSI_ReceivedDetails.Processed		= 0
FROM	(
		SELECT	FSI.BatchId,
				FSI.DetailId,
				FIX.NewDocNumber
		FROM	FSI_ReceivedDetails FSI
				INNER JOIN @tblDocs FIX ON FSI.BatchId = FIX.BatchId AND FSI.InvoiceNumber = FIX.InvoiceNumber
		) DATA
WHERE	FSI_ReceivedDetails.BatchId = DATA.BatchId
		AND FSI_ReceivedDetails.DetailId = DATA.DetailId

SELECT	*
FROM	@tblDocs