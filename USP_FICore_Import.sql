/*
EXECUTE USP_FICore_Import
*/
ALTER PROCEDURE USP_FICore_Import
AS
SET NOCOUNT ON

DECLARE	@ReceivedSalesId	Bigint,
		@Inv_No				Varchar(10),
		@Inv_Date			Date,
		@Acct_No			Varchar(12),
		@Parts				Numeric(10,2),
		@Labor				Numeric(10,2),
		@Sale_Tax			Numeric(10,2),
		@Chassis			Varchar(25),
		@Container			Varchar(25),
		@Depot_Loc			Varchar(25),
		@Workorder			Varchar(25),
		@Inv_Est			Char(1),
		@RecordAmount		Numeric(10,2),
		@TransType			Varchar(10),
		@ReturnValue		Bigint

DECLARE TableCursor CURSOR FOR
SELECT	ReceivedSalesId,
		Inv_No,
		Inv_Date,
		Acct_No,
		Parts,
		Labor,
		Sale_Tax,
		Chassis,
		Container,
		Depot_Loc,
		CASE WHEN Workorder = '' THEN Job_Order ELSE Workorder END AS Workorder,
		Inv_Est
FROM	ILSINT02.FI_Data.dbo.ReceivedSales
WHERE	Status = 0

OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @ReceivedSalesId, @Inv_No, @Inv_Date, @Acct_No, @Parts, @Labor, @Sale_Tax,
								 @Chassis, @Container, @Depot_Loc, @Workorder, @Inv_Est

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @Depot_Loc		= RTRIM(@Depot_Loc)
	SET @Acct_No		= RTRIM(@Acct_No)
	SET @Inv_No			= RTRIM(@Inv_No)
	SET @RecordAmount	= @Parts + @Labor
	SET	@TransType		= CASE WHEN @Inv_Est = 'I' THEN 'INV' ELSE 'EST' END

	BEGIN TRY
		EXECUTE @ReturnValue = USP_ManifestTransactions	
							@ManifestTypeId = 2
							,@Company = 'FI'
							,@Location = @Depot_Loc
							,@TransactionDate = @Inv_Date
							,@EffectiveDate = Null
							,@CustomerNumber = @Acct_No
							,@DocumentNumber = @Inv_No
							,@ReferenceNumber = ''
							,@TransactionType = @TransType
							,@Amount = @RecordAmount

		IF @ReturnValue > 0
		BEGIN
			UPDATE	ILSINT02.FI_Data.dbo.ReceivedSales
			SET		Status = 1
			WHERE	ReceivedSalesId = @ReceivedSalesId

			IF RTRIM(@Chassis) <> ''
			BEGIN
				SET @Chassis = RTRIM(@Chassis)
				EXECUTE USP_EquipmentDetails @ReturnValue, 'CHA', @Chassis
			END

			IF RTRIM(@Container) <> ''
			BEGIN
				SET @Container = RTRIM(@Container)
				EXECUTE USP_EquipmentDetails @ReturnValue, 'CON', @Container
			END

			IF @Parts <> 0
			BEGIN
				EXECUTE USP_AdditionalValues @ReturnValue, 'Parts', @Parts
			END

			IF @Labor <> 0
			BEGIN
				EXECUTE USP_AdditionalValues @ReturnValue, 'Labor', @Labor
			END

			IF @Sale_Tax <> 0
			BEGIN
				EXECUTE USP_AdditionalValues @ReturnValue, 'Tax', @Sale_Tax
			END
		END
	END TRY
	BEGIN CATCH
		 PRINT 'Error processing document: ' + @Inv_No
	END CATCH

	FETCH NEXT FROM TableCursor INTO @ReceivedSalesId, @Inv_No, @Inv_Date, @Acct_No, @Parts, @Labor, @Sale_Tax,
									 @Chassis, @Container, @Depot_Loc, @Workorder, @Inv_Est
END

CLOSE TableCursor
DEALLOCATE TableCursor