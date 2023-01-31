/*
EXECUTE USP_IMCMR_FindLastBatch 'IMCMR'
*/
ALTER PROCEDURE USP_IMCMR_FindLastBatch
		@Company	Varchar(5)
AS
DECLARE @BatchId	Varchar(15),
		@Return		Varchar(15),
		@BatchName	Varchar(5) = 'REPAR'

SET		@BatchId = (SELECT	TOP 1 BatchId
FROM	[FI].[staging].[MSR_Import]
WHERE	[import_date] IN (
							SELECT	MAX([import_date])
							FROM	[FI].[staging].[MSR_Import]
							WHERE	[Company] = @Company
									AND BatchId LIKE (@BatchName + '%'))
		AND [Company] = @Company
		AND BatchId LIKE (@BatchName + '%'))

IF EXISTS(SELECT BatchId FROM BatchesReceived WHERE	Company = @Company AND BatchId = @BatchId)
BEGIN
	SET @Return = @BatchId
END
ELSE
BEGIN
	INSERT INTO BatchesReceived (Company, BatchId) VALUES (@Company, @BatchId)
END

SET @Return = REPLACE(@BatchId, 'REPAR', IIF(@Company = 'IMCMR', 'REPAR', 'REPGL'))

SELECT @Return AS BatchId