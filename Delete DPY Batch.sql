USE [GPCustom]
GO

SET NOCOUNT OFF

DECLARE	@Company		Varchar(5) = 'DNJ',
		@BatchId		Varchar(25) = '7_DPY_20221112', -- DPY_20221112
		@WeekEndDate	Date = NULL, --'12/23/2017',
		@ProcessType	Char(1) = 'D'

IF @ProcessType = 'S'
BEGIN
	SELECT	*
	FROM	Integration_APHeader
	WHERE	Company = @Company
			AND ((@WeekEndDate IS Null OR (@WeekEndDate IS NOT Null AND WeekEndDate = @WeekEndDate))
			AND (@BatchId IS Null OR (@BatchId IS NOT Null AND BatchId =  @BatchId)))

	SELECT	*
	FROM	Integration_APDetails
	WHERE	BatchId =  @BatchId
END
ELSE
BEGIN
	IF @ProcessType = 'U'
	BEGIN
		DECLARE curBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	BatchId
		FROM	Integration_APHeader
		WHERE	Company = @Company
				AND BatchId =  @BatchId

		OPEN curBatches 
		FETCH FROM curBatches INTO @Company

		WHILE @@FETCH_STATUS = 0 
		BEGIN
			PRINT 'Batch Id: ' + @BatchId

			UPDATE	Integration_APHeader
			SET		Status = 0
			WHERE	BatchId = @BatchId

			UPDATE	Integration_APDetails 
			SET		Processed = 0,
					Verification = 'OK'
			WHERE	BatchId = @BatchId

			UPDATE	IntegrationsDB.Integrations.dbo.ReceivedIntegrations
			SET		Status = 0
			WHERE	Integration = 'DPY'
					--AND Company = @Company
					AND BatchId = @BatchId

			FETCH FROM curBatches INTO @BatchId
		END

		CLOSE curBatches
		DEALLOCATE curBatches
	END
	ELSE
	BEGIN
		PRINT 'Batch Id: ' + @BatchId

		DELETE	Integration_APHeader
		WHERE	Company = @Company
				AND BatchId = @BatchId

		DELETE	Integration_APDetails 
		WHERE	BatchId = @BatchId

		DELETE	IntegrationsDB.Integrations.dbo.ReceivedIntegrations
		WHERE	Integration = 'DPY'
				AND Company = @Company
				AND BatchId = @BatchId
	END
END
GO

/*
UPDATE	Integration_APDetails
SET		VendorId = 'I52891'
WHERE	BatchId = '1_DPY_20220205'
		AND VendorId = 'I52962'

DELETE	Integration_APDetails
WHERE	BatchId = '3_DPY_20190119'
		AND VendorId = '311'
*/