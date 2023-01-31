DECLARE	@ManifestTypeId			int,
		@Company				varchar(5),
		@Location				varchar(25) = Null,
		@TransactionDate		datetime,
		@EffectiveDate			date = Null,
		@CustomerNumber			varchar(25) = Null,
		@DocumentNumber			varchar(30),
		@ReferenceNumber		varchar(30) = Null,
		@TransactionType		varchar(3),
		@Amount					numeric(12,2),
		@CreationDate			datetime = Null,
		@ReturnValue			int,
		@Fk_TransactionId		Bigint,
		@Labor					numeric(12,2),
		@Parts					numeric(12,2),
		@AccountNumber			varchar(20),
		@BatchId				varchar(20),
		@Chassis				varchar(15),
		@Container				varchar(15)


DECLARE TableFields CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	1 AS ManifestTypeId,
		'FI' AS Company,
		State AS Location,
		InvoiceDate,
		CAST(SUBSTRING(FileName, 7, 4) + '/' + SUBSTRING(FileName, 11, 2) + '/' + SUBSTRING(FileName, 13, 2) AS Date),
		CASE WHEN FRS.IntegrationType = 'AR' THEN FRS.AccountNumber ELSE Null END,
		FRS.InvoiceNumber,
		WorkOrder,
		CASE WHEN FRS.RecordType = 'C' THEN 'COS' WHEN FRS.RecordType = 'E' THEN 'EST' ELSE 'INV' END,
		CASE WHEN FRS.IntegrationType = 'AR' THEN FRS.InvoiceTotal ELSE FRS.Labor + FRS.Parts END,
		FRS.ReceivedOn,
		CASE WHEN FRS.RecordType = 'C' THEN 1 WHEN FRS.RecordType = 'E' THEN 2 ELSE 3 END,
		FRS.Labor,
		FRS.Parts,
		FRS.AccountNumber,
		FRS.BatchId,
		FRS.Chassis,
		FRS.Container
FROM	ILSINT02.Integrations.dbo.FRS_Integrations FRS
		LEFT OUTER JOIN Transactions TRA ON FRS.Workorder = TRA.ReferenceNumber AND CASE WHEN FRS.RecordType = 'C' THEN 1 WHEN FRS.RecordType = 'E' THEN 2 ELSE 3 END = TRA.Fk_TransactionTypeId -- FRS.InvoiceNumber = TRA.DocumentNumber AND
WHERE	TRA.DocumentNumber IS Null

OPEN TableFields
FETCH FROM TableFields INTO @ManifestTypeId, @Company, @Location, @TransactionDate, @EffectiveDate, @CustomerNumber, @DocumentNumber, @ReferenceNumber, @TransactionType, @Amount, @CreationDate,
							@Fk_TransactionId, @Labor, @Parts, @AccountNumber, @BatchId, @Chassis, @Container

WHILE @@FETCH_STATUS = 0 
BEGIN
	BEGIN TRANSACTION
	
	EXECUTE @ReturnValue = USP_ManifestTransactions @ManifestTypeId, @Company, @Location, @TransactionDate, @EffectiveDate, @CustomerNumber, @DocumentNumber, @ReferenceNumber, @TransactionType, @Amount, @CreationDate

	IF @ReturnValue > 0
	BEGIN
		IF @Chassis IS NOT Null
			EXECUTE USP_EquipmentDetails @ReturnValue, 'CHA', @Chassis

		IF @Container IS NOT Null
			EXECUTE USP_EquipmentDetails @ReturnValue, 'CON', @Container

		EXECUTE USP_AdditionalValues @Fk_TransactionId, 'Labor', @Labor
		EXECUTE USP_AdditionalValues @Fk_TransactionId, 'Parts', @Parts

		IF @TransactionType = 'COS'
		BEGIN
			EXECUTE USP_AdditionalValues @Fk_TransactionId, 'VendorId', @AccountNumber
			EXECUTE USP_AdditionalValues @Fk_TransactionId, 'APBatchId', @BatchId
		END
		ELSE
		BEGIN
			EXECUTE USP_AdditionalValues @Fk_TransactionId, 'ARBatchId', @BatchId
		END
	END

	IF @@ERROR = 0
		COMMIT TRANSACTION
	ELSE
	BEGIN
		ROLLBACK TRANSACTION

		PRINT 'Error on Reference ' + @ReferenceNumber + ' Type ' + @TransactionType
	END

	FETCH FROM TableFields INTO @ManifestTypeId, @Company, @Location, @TransactionDate, @EffectiveDate, @CustomerNumber, @DocumentNumber, @ReferenceNumber, @TransactionType, @Amount, @CreationDate,
								@Fk_TransactionId, @Labor, @Parts, @AccountNumber, @BatchId, @Chassis, @Container
END	

CLOSE TableFields
DEALLOCATE TableFields

--SELECT * FROM TRANSACTIONS WHERE DOCUMENTNUMBER IN ('29-18842','29-19449','29-20399','4873-20316')