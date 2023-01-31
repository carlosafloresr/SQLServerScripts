/*
EXECUTE USP_FindUnprocessedTIP
*/
ALTER PROCEDURE USP_FindUnprocessedTIP
AS
DECLARE	@Company		Varchar(5),
		@BatchId		Varchar(25),
		@WeekEndDate	Date = dbo.DayFwdBack(GETDATE(),'P','Saturday')

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
GO