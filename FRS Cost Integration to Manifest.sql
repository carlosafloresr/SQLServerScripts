/*
EXECUTE FI_DATA.dbo.USP_FRSCostIntegrationToManifes 'FRM_1508031601'
*/
CREATE PROCEDURE USP_FRSCostIntegrationToManifes
		@BatchId				Varchar(25)
AS
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
		@Labor					numeric(12,2),
		@Parts					numeric(12,2),
		@AccountNumber			varchar(20),
		@Chassis				varchar(15),
		@Container				varchar(15)

DECLARE TableFields CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	1 AS ManifestTypeId,
		'FI' AS Company,
		'' AS Location,
		Inv_Date,
		GLI.TrxDate,
		'AP' AS IntegrationType,
		'I' + CAST(FRS.Inv_No AS Varchar) AS Inv_No,
		Genset_No,
		'COS',
		FRS.cost,
		FRS.ReceivedOn,
		FRS.Labor,
		FRS.Parts,
		FRS.acct_no,
		GLI.BatchId,
		FRS.Chassis,
		FRS.Container
FROM	View_FI_Estimates_All FRS
		INNER JOIN Integrations.dbo.Integrations_GL GLI ON CAST(FRS.inv_no AS Varchar) = GLI.InvoiceNumber AND FRS.vendor_id = GLI.VendorId AND GLI.BatchId = @BatchId

OPEN TableFields
FETCH FROM TableFields INTO @ManifestTypeId, @Company, @Location, @TransactionDate, @EffectiveDate, @CustomerNumber, @DocumentNumber, @ReferenceNumber, @TransactionType, @Amount, @CreationDate,
							@Labor, @Parts, @AccountNumber, @BatchId, @Chassis, @Container

WHILE @@FETCH_STATUS = 0 
BEGIN
	BEGIN TRANSACTION

	-- MANIFEST COST TRANSACTION
	EXECUTE @ReturnValue = LENSASQL002.Manifest.dbo.USP_ManifestTransactions @ManifestTypeId, @Company, @Location, @TransactionDate, @EffectiveDate, @CustomerNumber, @DocumentNumber, @ReferenceNumber, @TransactionType, @Amount, @CreationDate
	
	IF @ReturnValue > 0
	BEGIN
		IF @Chassis IS NOT Null
			EXECUTE LENSASQL002.Manifest.dbo.USP_EquipmentDetails @ReturnValue, 'CHA', @Chassis

		IF @Container IS NOT Null
			EXECUTE LENSASQL002.Manifest.dbo.USP_EquipmentDetails @ReturnValue, 'CON', @Container

		EXECUTE LENSASQL002.Manifest.dbo.USP_AdditionalValues @ReturnValue, 'Labor', @Labor
		EXECUTE LENSASQL002.Manifest.dbo.USP_AdditionalValues @ReturnValue, 'Parts', @Parts
		EXECUTE LENSASQL002.Manifest.dbo.USP_AdditionalValues @ReturnValue, 'VendorId', @AccountNumber
		EXECUTE LENSASQL002.Manifest.dbo.USP_AdditionalValues @ReturnValue, 'APBatchId', @BatchId

		IF @@ERROR = 0
		BEGIN
			SET @ReturnValue = 0
			SET @TransactionType = 'INV'
			SET @Amount = @Labor + @Parts

			-- MANIFEST INVOICE TRANSACTION
			EXECUTE @ReturnValue = LENSASQL002.Manifest.dbo.USP_ManifestTransactions @ManifestTypeId, @Company, @Location, @TransactionDate, Null, @CustomerNumber, @DocumentNumber, @ReferenceNumber, @TransactionType, @Amount, @CreationDate
	
			IF @ReturnValue > 0
			BEGIN
				IF @Chassis IS NOT Null
					EXECUTE LENSASQL002.Manifest.dbo.USP_EquipmentDetails @ReturnValue, 'CHA', @Chassis

				IF @Container IS NOT Null
					EXECUTE LENSASQL002.Manifest.dbo.USP_EquipmentDetails @ReturnValue, 'CON', @Container

				EXECUTE LENSASQL002.Manifest.dbo.USP_AdditionalValues @ReturnValue, 'Labor', @Labor
				EXECUTE LENSASQL002.Manifest.dbo.USP_AdditionalValues @ReturnValue, 'Parts', @Parts 
				EXECUTE LENSASQL002.Manifest.dbo.USP_AdditionalValues @ReturnValue, 'VendorId', @AccountNumber
				EXECUTE LENSASQL002.Manifest.dbo.USP_AdditionalValues @ReturnValue, 'ARBatchId', @BatchId
			END
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
								@Labor, @Parts, @AccountNumber, @BatchId, @Chassis, @Container
END	

CLOSE TableFields
DEALLOCATE TableFields