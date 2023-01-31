USE [Integrations]
GO 

SET NOCOUNT ON

DECLARE	@BatchId		Varchar(22) = '9FSI20230125_1451',
		@Company		Varchar(15),
		@Integration	Varchar(10) = 'FSIG', --FSI,FSIG,FSIP,TIP
		@Script			Char(1) = 'U',
		@Reversal		Bit = 0,
		@Validated		Bit = 0,
		@Reprocess		Bit = 0,
		@Status			Smallint = 0,
		@GPServer		Varchar(15) = 'PRISQL01P',
		@Demurrage		Varchar(10)

SET @Company		= (SELECT Company FROM FSI_ReceivedHeader WITH (NOLOCK) WHERE BatchId = @BatchId)
SET @Integration	= UPPER(@Integration)

PRINT 'Company: ' + ISNULL(@Company, 'Not Found')

IF @Script = 'U' AND @Company IS NOT Null
BEGIN
	UPDATE	FSI_ReceivedSubDetails
	SET		Processed = 1
	WHERE	BatchId = @BatchId

	UPDATE	FSI_ReceivedDetails
	SET		Processed = 1
	WHERE	BatchId = @BatchId

	SET NOCOUNT OFF

	IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WITH (NOLOCK) WHERE Integration = @Integration AND BatchId = @BatchId) -- IN ('FSI','FSIG','FSIP','TIP')
		UPDATE	ReceivedIntegrations 
		SET		Status = @Status, GPServer = @GPServer, ReverseBatch = @Reversal, Integration = UPPER(Integration), Validated = @Validated, Reprocess = @Reprocess
		WHERE	Integration IN (@Integration)
				AND BatchId = @BatchId
	ELSE
		INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer, Status, ReverseBatch, Validated, Reprocess) VALUES (@Integration, @Company, @BatchId, @GPServer, @Status, @Reversal, @Validated, @Reprocess)

	IF @Integration = 'FSI'
	BEGIN
		UPDATE	FSI_ReceivedHeader 
		SET		Status = @Status
		WHERE	BatchId = @BatchId

		UPDATE	FSI_ReceivedDetails 
		SET		Processed = @Status
		WHERE	FSI_ReceivedDetailId IN (SELECT SourceRecordId FROM FSI_TransactionDetails WHERE BatchId = @BatchId AND IntegrationType = @Integration AND SourceType = 'AR')
				--AND InvoiceNumber IN ('50-121473')
	END

	IF @Integration = 'FSIP'
	BEGIN
		UPDATE	FSI_ReceivedSubDetails 
		SET		Processed = @Status, 
				Verification = Null 
		WHERE	FSI_ReceivedSubDetailId IN (SELECT FSI_ReceivedSubDetailId FROM View_Integration_FSI_Vendors WHERE BatchId = @BatchId)
				--AND FSI_ReceivedSubDetailId IN (43022180)
	END

	IF @Integration = 'FSIG'
	BEGIN
		UPDATE	FSI_ReceivedDetails
		SET		Processed = @Status, 
				Verification = Null
		WHERE	FSI_ReceivedDetailId IN (SELECT SourceRecordId FROM FSI_TransactionDetails WHERE BatchId = @BatchId AND IntegrationType = @Integration AND SourceType = 'AR')
				--AND FSI_ReceivedDetailId IN (22560187)

		UPDATE	FSI_ReceivedSubDetails 
		SET		Processed = @Status, 
				Verification = Null
		WHERE	FSI_ReceivedSubDetailId IN (SELECT SourceRecordId FROM FSI_TransactionDetails WHERE BatchId = @BatchId AND IntegrationType = @Integration AND SourceType = 'AP')
				--AND FSI_ReceivedSubDetailId IN (22560187)
	END

	IF @Integration = 'TIP'
	BEGIN
		UPDATE	FSI_ReceivedDetails
		SET		Processed = @Status, 
				Verification = Null
		WHERE	FSI_ReceivedDetailId IN (SELECT SourceRecordId FROM FSI_TransactionDetails WHERE BatchId = @BatchId AND IntegrationType = @Integration AND SourceType = 'AR')
				--AND FSI_ReceivedDetailId IN (38440915)

		UPDATE	FSI_ReceivedSubDetails 
		SET		Processed = @Status, 
				Verification = Null
		WHERE	FSI_ReceivedSubDetailId IN (SELECT SourceRecordId FROM FSI_TransactionDetails WHERE BatchId = @BatchId AND IntegrationType = @Integration AND SourceType = 'AP')
				--AND FSI_ReceivedSubDetailId IN (38440915)
	END

	IF @Integration IN ('FSIG','FSIP','TIP')
	BEGIN
		SET NOCOUNT ON

		DELETE	FSI_PayablesRecords 
		WHERE	RecordId IN (SELECT SourceRecordId FROM FSI_TransactionDetails WHERE BatchId = @BatchId AND IntegrationType = @Integration AND SourceType = 'AP')
	END
END
ELSE
BEGIN
	IF @Script = 'D'
	BEGIN
		DELETE ReceivedIntegrations WHERE BatchId = @BatchId
		DELETE FSI_ReceivedHeader WHERE BatchId = @BatchId
		DELETE FSI_ReceivedDetails WHERE BatchId = @BatchId
		DELETE FSI_ReceivedSubDetails WHERE BatchId = @BatchId
	END

	IF @Script = 'S'
	BEGIN
		SELECT * FROM ReceivedIntegrations WHERE BATCHID = @BatchId
		SELECT * FROM FSI_ReceivedHeader WHERE BATCHID = @BatchId
		SELECT * FROM FSI_ReceivedDetails WHERE BATCHID = @BatchId ORDER BY DetailId
		SELECT * FROM FSI_ReceivedSubDetails WHERE BATCHID = @BatchId ORDER BY DetailId
	END
END

/*
SELECT	*
FROM	FSI_ReceivedHeader
WHERE	BatchId LIKE '9FSI20230125_14%'

SELECT	* 
FROM	GLSO.dbo.GL20000 
WHERE	REFRENCE = 'PN:95-138645/CNT:ECMU445720' 
		AND (CRDTAMNT + DEBITAMT) = 1121.58 
		AND TRXDATE = '10/19/2019'

SELECT	* 
FROM	GLSO.dbo.GL20000 
WHERE	REFRENCE = 'PN:95-138889/CNT:TTNU117532' 
		AND (CRDTAMNT + DEBITAMT) = 974.68
		AND TRXDATE = '10/19/2019'
*/