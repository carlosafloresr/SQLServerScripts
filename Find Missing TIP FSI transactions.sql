DECLARE	@Company		Varchar(5),
		@BatchId		Varchar(25),
		@WeekEndDate	Date = '11/18/2017'

SELECT	Company, FSIBatchId, InvoiceNumber, RecordId
FROM	View_FSI_Intercompany 
WHERE	WeekEndDate = @WeekEndDate
		AND RecordId NOT IN (SELECT * FROM TIP_IntegrationRecords)
ORDER BY Company, BatchId

DECLARE curBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT Company, 
		FSIBatchId
FROM	View_FSI_Intercompany 
WHERE	WeekEndDate = @WeekEndDate
		AND RecordId NOT IN (SELECT * FROM TIP_IntegrationRecords)

OPEN curBatches 
FETCH FROM curBatches INTO @Company, @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF @Company IS NOT Null
	BEGIN
		PRINT @Company

		UPDATE	FSI_ReceivedSubDetails
		SET		Processed = 0
		WHERE	BatchId = @BatchId
				AND RecordType = 'VND'
				AND VndIntercompany = 1
		
		UPDATE	FSI_ReceivedDetails
		SET		Processed = 0,
				TipProcessed = 0
		WHERE	BatchId = @BatchId
				AND Intercompany = 1

		EXECUTE USP_ReceivedIntegrations 'TIP', @Company, @BatchId, 0
	END

	FETCH FROM curBatches INTO @Company, @BatchId
END

CLOSE curBatches
DEALLOCATE curBatches

/*
DELETE	TIP_IntegrationRecords
WHERE	TIPIntegrationId IN (19728063,19728064,19728071,19728072,19728078,19728079)

SELECT	*
FROM	View_Integration_FSI_Full
WHERE	InvoiceNumber = '10-128572'
		--BatchId = '1TIP1706011606'
*/