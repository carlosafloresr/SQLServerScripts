DECLARE	@RecordId	Int = 0,
		@Company	Varchar(5),
		@BatchId	Varchar(25) = '1FSI20190311_1609'

SELECT	*
FROM	View_Integration_FSI_Full --View_FSI_Intercompany --
WHERE	BatchId = @BatchId
		AND ((RecordType = 'VND' AND VndIntercompany = 1)
		OR Intercompany = 1)
		--InvoiceNumber IN ('35-130709','35-130710','35-130711','35-130712','35-130713','35-130714','35-130715','35-130716','35-130717','35-130718','35-130719','35-130720','35-130743')

SELECT	@Company	= MAX(Company),
		@BatchId	= MAX(BatchId)
FROM	View_Integration_FSI_Full
WHERE	BatchId = @BatchId
		AND ((RecordType = 'VND' AND VndIntercompany = 1)
		OR Intercompany = 1)

IF @Company IS NOT Null
BEGIN
	PRINT @Company

	UPDATE	FSI_ReceivedSubDetails
	SET		Processed = 0
	WHERE	BatchId = @BatchId
			AND RecordType = 'VND'
			AND VndIntercompany = 1
			--FSI_ReceivedSubDetailId = @RecordId
		
	UPDATE	FSI_ReceivedDetails
	SET		Processed = 0,
			TipProcessed = 0
	WHERE	BatchId = @BatchId
			AND Intercompany = 1
--			AND InvoiceNumber IN ('10-138691','38-362003')

	DELETE	TIP_IntegrationRecords
	WHERE	TIPIntegrationId IN (
			SELECT	FSI_ReceivedDetailId
			FROM	FSI_ReceivedDetails
			WHERE	BatchId = @BatchId
					AND Intercompany = 1
			)

	DELETE	TIP_IntegrationRecords
	WHERE	TIPIntegrationId IN (
			SELECT	FSI_ReceivedSubDetailId
			FROM	FSI_ReceivedSubDetails
			WHERE	BatchId = @BatchId
					AND RecordType = 'VND'
					AND VndIntercompany = 1
			)

	EXECUTE USP_ReceivedIntegrations @Integration = 'TIP', @Company = @Company, @BatchId = @BatchId, @Status = 0, @GPServer = 'PRISQL01P'
END

/*
SELECT	*
FROM	View_FSI_Intercompany
WHERE	InvoiceNumber IN ('8-616994','8-616792')
WHERE	WeekEndDate = '06/10/2017'
		AND RecordId NOT IN (SELECT * FROM TIP_IntegrationRecords)
ORDER BY BatchId
*/