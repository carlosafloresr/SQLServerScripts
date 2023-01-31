/*
EXECUTE USP_Lockbox_ApplyTo_Export
*/
ALTER PROCEDURE USP_Lockbox_ApplyTo_Export
AS
SET NOCOUNT ON

DECLARE	@Company		Varchar(5),
		@BatchId		Varchar(25),
		@Integration	Varchar(10) = 'APPLYAR'

DECLARE curLockBoxBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT Company, BatchId
FROM	Lockbox_ApplyTo
WHERE	Submitted = 0

OPEN curLockBoxBatches 
FETCH FROM curLockBoxBatches INTO @Company, @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Company ' + @Company + ' Batch ' + @BatchId

	INSERT INTO PRISQL004P.Integrations.dbo.Integrations_ApplyTo
           ([Integration]
           ,[Company]
           ,[BatchId]
           ,[CustomerVendor]
           ,[ApplyFrom]
           ,[ApplyTo]
           ,[ApplyAmount]
           ,[WriteOffAmnt]
           ,[RecordType]
           ,[Processed]
           ,[PostingDate]) 
	SELECT	@Integration,
			Company,
			BatchId,
			Customer,
			ApplyFrom,
			ApplyTo,
			ApplyAmount,
			Writeoff,
			'AR', 0, GETDATE()
	FROM	Lockbox_ApplyTo
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND Submitted = 0

	IF @@ERROR = 0
	BEGIN
		UPDATE	PRISQL004P.Integrations.dbo.Integrations_ApplyTo
		SET		Processed = 1
		WHERE	RecordId IN (SELECT ApplyRecordId FROM Lockbox_ApplyTo WHERE Company = @Company AND BatchId = @BatchId AND Submitted = 0)

		EXECUTE PRISQL004P.Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @BatchId, 10

		UPDATE	Lockbox_ApplyTo 
		SET		Submitted = 1
		WHERE	Company = @Company 
				AND BatchId = @BatchId 
				AND Submitted = 0
	END

	FETCH FROM curLockBoxBatches INTO @Company, @BatchId
END

CLOSE curLockBoxBatches
DEALLOCATE curLockBoxBatches