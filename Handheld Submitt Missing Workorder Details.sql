/*
EXECUTE USP_SubmitRepair 2, ''
*/
ALTER PROCEDURE [dbo].[USP_SubmitRepair] (@Consecutive Int, @ErrorMessage Varchar(1000) OUTPUT)
AS
DECLARE @SERVERONLINE		Bit,
		@Tablet				Varchar(15),
		@WorkOrder			varchar(12),
		@Fk_SubmittedId		int = Null,
		@InvoiceNumber		int = Null,
		@CustomerNumber		varchar(20),
		@Equipment			varchar(40),
		@EquipmentType		char(1),
		@EquipmentSize		char(6),
		@EquipmentLocation  varchar(25),
		@SubLocation		varchar(40),
		@RepairRemarks		varchar(200) = Null,
		@EstimateDate		datetime,
		@RepairDate			datetime,
		@Estimator			varchar(30) = Null,
		@Mechanic			varchar(20),
		@PrivateRemarks		varchar(200) = Null,
		@SerialNumber		varchar(30) = Null,
		@ModelNumber		varchar(25) = Null,
		@Hours				numeric(8,2) = Null,
		@Manufactor			varchar(20) = Null,
		@ManufactorDate		date = Null,
		@RepairStatus		char(2),
		@ChassisInspection	bit,
		@Status				int,
		@Container			varchar(15) = Null,
		@ContainerMounted	bit,
		@Lot_Road			varchar(15),
		@FMCSA				date = Null,
		@CreationDate		Datetime,
		@ModificationDate	Datetime,
		@ExecutionError		Int,
		@ServerRepairId		Int,
		@ServerDateTime		Datetime

-- ***** CHECK IF THE SERVER IS ONLINE ***
BEGIN TRY
     SELECT @SERVERONLINE = ServerRunning 
     FROM	ILSINT02.FI_Data.dbo.ServerRunning
     
END TRY
BEGIN CATCH
     SET @SERVERONLINE = 0
END CATCH

IF @SERVERONLINE = 0
BEGIN
	SET @ExecutionError = -1
	SET @ErrorMessage = 'Central Server Is Unavailable'
END
ELSE
BEGIN
	-- ***** IF SERVER ONLINE SUBMIT INFORMATION *****
	BEGIN TRANSACTION
	
	BEGIN TRY
		SET		@Tablet				= (SELECT UPPER(HOST_NAME()) AS Computer_Name)
		SET		@ServerDateTime		= (SELECT GETDATE() FROM ILSINT02.FI_Data.dbo.ServerRunning)
		
		SELECT	@WorkOrder			= WorkOrder
				,@CustomerNumber	= CustomerNumber
				,@Equipment			= Equipment
				,@EquipmentType		= EquipmentType
				,@EquipmentSize		= EquipmentSize
				,@EquipmentLocation	= EquipmentLocation
				,@SubLocation		= SubLocation
				,@RepairRemarks		= RepairRemarks
				,@EstimateDate		= EstimateDate
				,@RepairDate		= RepairDate
				,@Estimator			= Estimator
				,@Mechanic			= Mechanic
				,@PrivateRemarks	= PrivateRemarks
				,@SerialNumber		= SerialNumber
				,@ModelNumber		= ModelNumber
				,@Hours				= Hours
				,@Manufactor		= Manufactor
				,@ManufactorDate	= ManufactorDate
				,@RepairStatus		= RepairStatus
				,@ChassisInspection	= ChassisInspection
				,@RepairStatus		= RepairStatus
				,@Container			= Container
				,@ContainerMounted	= ContainerMounted
				,@Lot_Road			= Lot_Road
				,@FMCSA				= FMCSA
				,@CreationDate		= CreationDate
				,@ModificationDate	= ModificationDate
				,@Status			= 0
		FROM	Repairs
		WHERE	Consecutive			= @Consecutive

		--EXECUTE @ServerRepairId		= ILSINT02.FI_Data.dbo.USP_Repairs 
		--							@Tablet
		--							,@WorkOrder
		--							,@CustomerNumber
		--							,@Equipment
		--							,@EquipmentType
		--							,@EquipmentSize
		--							,@EquipmentLocation
		--							,@SubLocation
		--							,@RepairRemarks
		--							,@EstimateDate
		--							,@RepairDate
		--							,@Estimator
		--							,@Mechanic
		--							,@PrivateRemarks
		--							,@SerialNumber
		--							,@ModelNumber
		--							,@Hours
		--							,@Manufactor
		--							,@ManufactorDate
		--							,@RepairStatus
		--							,@ChassisInspection
		--							,@Status
		--							,@Container
		--							,@ContainerMounted
		--							,@Lot_Road
		--							,@FMCSA	
		--							,@CreationDate
		--							,@ModificationDate

		-- ***** REPAIR DETAILS SUBMIT *****
		SET @ServerRepairId = (SELECT RepairId FROM ILSINT02.FI_Data.dbo.Repairs WHERE WorkOrder = @WorkOrder)

		IF @ServerRepairId > 0
		BEGIN			
			DECLARE	@RepairDetailsId	int,
					@LineItem			int,
					@PartNumber			varchar(25),
					@PartDescription	varchar(40),
					@LocationCode		varchar(20),
					@DamageCode			varchar(10),
					@RepairCode			varchar(10),
					@DamageWidth		numeric(10,2),
					@DamageLenght		numeric(10,2),
					@ResponsibleParty	char(1),
					@Quantity			numeric(10,2),
					@RepairedComponent	varchar(25),
					@RepairsPictureId	int,
					@PictureFileName	varchar(50),
					@DOTIn				varchar(15),
					@DOTOut				varchar(15),
					@RecapperOn			varchar(15),
					@RecapperOff		varchar(15),
					@Position			varchar(5)

			DECLARE RepDetails CURSOR LOCAL KEYSET OPTIMISTIC FOR
			SELECT	RepairDetailsId,
					LineItem,
					PartNumber,
					PartDescription,
					LocationCode,
					DamageCode,
					RepairCode,
					DamageWidth,
					DamageLenght,
					ResponsibleParty,
					Quantity,
					RepairedComponent,
					DOTIn,
					DOTOut,
					RecapperOn,
					RecapperOff,
					Position
			FROM	RepairsDetails
			WHERE	Consecutive = @Consecutive

			OPEN RepDetails 
			FETCH FROM RepDetails INTO	@RepairDetailsId, @LineItem, @PartNumber, @PartDescription, @LocationCode, @DamageCode, @RepairCode, @DamageWidth,
										@DamageLenght, @ResponsibleParty, @Quantity, @RepairedComponent, @DOTIn, @DOTOut, @RecapperOn, @RecapperOff, @Position
			
			EXECUTE ILSINT02.FI_Data.dbo.USP_RepairsDetails_Delete @Consecutive
			
			WHILE @@FETCH_STATUS = 0 AND @@ERROR = 0
			BEGIN
				EXECUTE ILSINT02.FI_Data.dbo.USP_RepairsDetails @ServerRepairId,
																@LineItem, 
																@PartNumber, 
																@PartDescription, 
																@LocationCode, 
																@DamageCode, 
																@RepairCode, 
																@DamageWidth,
																@DamageLenght, 
																@EquipmentType,
																@ResponsibleParty, 
																@Quantity, 
																@RepairedComponent,
																@DOTIn, 
																@DOTOut, 
																@RecapperOn, 
																@RecapperOff, 
																@Position
				
				FETCH FROM RepDetails INTO	@RepairDetailsId, @LineItem, @PartNumber, @PartDescription, @LocationCode, @DamageCode, @RepairCode, @DamageWidth,
											@DamageLenght, @ResponsibleParty, @Quantity, @RepairedComponent, @DOTIn, @DOTOut, @RecapperOn, @RecapperOff, @Position
			END
			
			CLOSE RepDetails
			DEALLOCATE RepDetails
			
			-- ***** REPAIR PICTURES SUBMIT *****
			DECLARE RepPictures CURSOR LOCAL KEYSET OPTIMISTIC FOR
			SELECT	RepairsPictureId,
					PictureFileName
			FROM	RepairsPictures
			WHERE	Consecutive = @Consecutive
			
			EXECUTE ILSINT02.FI_Data.dbo.USP_RepairsPictures_Delete @Consecutive
			
			OPEN RepPictures 
			FETCH FROM RepPictures INTO @RepairsPictureId, @PictureFileName
			
			WHILE @@FETCH_STATUS = 0 AND @@ERROR = 0
			BEGIN
				EXECUTE ILSINT02.FI_Data.dbo.USP_RepairsPictures @ServerRepairId, @RepairsPictureId, @PictureFileName
				
				FETCH FROM RepPictures INTO @RepairsPictureId, @PictureFileName
			END
			
			CLOSE RepPictures
			DEALLOCATE RepPictures
		END
		
		IF @@ERROR = 0
		BEGIN
			UPDATE Repairs SET Fk_SubmittedId = @ServerRepairId, SubmittedOn = @ServerDateTime WHERE Consecutive = @Consecutive
			COMMIT TRANSACTION
			SET @ExecutionError = 0
			SET @ErrorMessage = ''
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			SET @ExecutionError = @@ERROR
			SET @ErrorMessage = ERROR_MESSAGE()
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	    SET @ExecutionError = -1
	    SET @ErrorMessage = ERROR_MESSAGE()
	END CATCH
END

EXECUTE USP_ShrinkLogFile

RETURN @ExecutionError