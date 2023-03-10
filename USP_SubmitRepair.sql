USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_SubmitRepair]    Script Date: 8/4/2014 10:43:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_SubmitRepair 108, ''
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
		@Status				int = 0,
		@Container			varchar(15) = Null,
		@ContainerMounted	bit,
		@Lot_Road			varchar(15),
		@FMCSA				date = Null,
		@CreationDate		Datetime,
		@ModificationDate	Datetime,
		@ExecutionError		Int = 0,
		@ServerRepairId		Int,
		@ServerDateTime		Datetime,
		@BIDStatus			Smallint,
		@SubCategory		Varchar(25),
		@TestRecord			Bit,
		@SrvConsecutive		Int = Null,
		@SPError			Int = 0,
		@NewConsecutive		Int,
		@LastConsecutive	Int,
		@RepairType			Char(1) = Null,
		@MIDAS_Version		Varchar(15) = Null,
		@PictureType		Char(1),
		@SavedOn			Datetime

-- ***** CHECK IF THE SERVER IS ONLINE ***
SET		@Tablet	= (SELECT UPPER(HOST_NAME()) AS Computer_Name)

IF LEFT(@Tablet, 2) <> 'HH'
	SET @Tablet = UPPER(RIGHT(RTRIM(@@SERVERNAME), 5))

BEGIN TRY
	SELECT	@SERVERONLINE = ServerRunning 
	FROM	ILSINT02.FI_Data.dbo.ServerRunning
     
	DECLARE @tblConsecutive TABLE (Consecutive Int)

	INSERT INTO @tblConsecutive
	EXECUTE USP_FindNextConsecutive @Tablet, 1

	SELECT	@SrvConsecutive = Consecutive 
	FROM	@tblConsecutive
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
	BEGIN TRY
		DECLARE	@SrvVersion		Smallint = 0,
				@LocVersion		SmallInt = 0

		SELECT @LocVersion	= [Version] FROM dbo.DBVersion
		SELECT @SrvVersion	= [Version] FROM ILSINT02.FI_Data.dbo.DBVersion

		IF @SrvVersion > @LocVersion
		BEGIN
			EXECUTE xp_cmdshell 'sqlcmd -S localhost -U MobileUser -P memphis1 -i \\iilogistics.com\netlogon\Midas\SQL_Script\Update_SQLServer_OnTablet.sql -e'

			IF @@ERROR = 0
			BEGIN
				UPDATE DBVersion SET Version = @SrvVersion
			END
		END
	END TRY
	BEGIN CATCH
		 -- NONE
	END CATCH

	BEGIN TRANSACTION
	
	BEGIN TRY
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
				,@BIDStatus			= BIDStatus
				,@TestRecord		= TestRecord
				,@RepairType		= RepairType
				,@MIDAS_Version		= MIDAS_Version
		FROM	Repairs
		WHERE	Consecutive			= @Consecutive

		IF @SrvConsecutive IS NOT Null AND @SrvConsecutive > @Consecutive
		BEGIN
			SET @WorkOrder = RTRIM(@Tablet) + '-' + dbo.PADL(@SrvConsecutive, 5, '0')
		END
		
		PRINT 'REPAIRS TABLE'
		EXECUTE @ServerRepairId		= ILSINT02.FI_Data.dbo.USP_Repairs 
									@Tablet
									,@WorkOrder
									,@CustomerNumber
									,@Equipment
									,@EquipmentType
									,@EquipmentSize
									,@EquipmentLocation
									,@SubLocation
									,@RepairRemarks
									,@EstimateDate
									,@RepairDate
									,@Estimator
									,@Mechanic
									,@PrivateRemarks
									,@SerialNumber
									,@ModelNumber
									,@Hours
									,@Manufactor
									,@ManufactorDate
									,@RepairStatus
									,@ChassisInspection
									,@Status
									,@Container
									,@ContainerMounted
									,@Lot_Road
									,@FMCSA	
									,@CreationDate
									,@ModificationDate
									,@BIDStatus
									,@TestRecord
									,@Mechanic
									,@RepairType
									,@MIDAS_Version

		SET @SPError = @@ERROR

		-- ***** REPAIR DETAILS SUBMIT *****
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
					@Position			varchar(5),
					@ItemCost			decimal(12,2),
					@ActualCost			decimal(12,2),
					@BIDItemCompleted	bit

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
					Position,
					ItemCost,
					ActualCost,
					BIDItemCompleted,
					SubCategory
			FROM	RepairsDetails
			WHERE	Consecutive = @Consecutive

			OPEN RepDetails 
			FETCH FROM RepDetails INTO	@RepairDetailsId, @LineItem, @PartNumber, @PartDescription, @LocationCode, @DamageCode, @RepairCode, @DamageWidth,
										@DamageLenght, @ResponsibleParty, @Quantity, @RepairedComponent, @DOTIn, @DOTOut, @RecapperOn, @RecapperOff, @Position,
										@ItemCost, @ActualCost, @BIDItemCompleted, @SubCategory
			
			EXECUTE ILSINT02.FI_Data.dbo.USP_RepairsDetails_Delete @Consecutive
			
			WHILE @@FETCH_STATUS = 0 AND @@ERROR = 0
			BEGIN
				PRINT 'REPAIRS DETAILS TABLE. ITEM # ' + CAST(@LineItem AS Varchar)

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
																@Position,
																@SubCategory,
																@ItemCost, 
																@ActualCost,
																@BIDItemCompleted

				IF @@ERROR > 0
				BEGIN
					SET @SPError = @@ERROR
					BREAK 
				END

				FETCH FROM RepDetails INTO	@RepairDetailsId, @LineItem, @PartNumber, @PartDescription, @LocationCode, @DamageCode, @RepairCode, @DamageWidth,
											@DamageLenght, @ResponsibleParty, @Quantity, @RepairedComponent, @DOTIn, @DOTOut, @RecapperOn, @RecapperOff, @Position,
											@ItemCost, @ActualCost, @BIDItemCompleted, @SubCategory
			END
			
			CLOSE RepDetails
			DEALLOCATE RepDetails
			
			-- ***** REPAIR PICTURES SUBMIT *****
			IF @BIDStatus < 4 AND @SPError = 0
			BEGIN
				DECLARE RepPictures CURSOR LOCAL KEYSET OPTIMISTIC FOR
				SELECT	RepairsPictureId,
						PictureFileName,
						LineItem,
						PictureType,
						SavedOn
				FROM	RepairsPictures
				WHERE	Consecutive = @Consecutive
			
				EXECUTE ILSINT02.FI_Data.dbo.USP_RepairsPictures_Delete @Consecutive
			
				OPEN RepPictures 
				FETCH FROM RepPictures INTO @RepairsPictureId, @PictureFileName, @LineItem, @PictureType, @SavedOn
			
				WHILE @@FETCH_STATUS = 0 AND @@ERROR = 0
				BEGIN
					PRINT 'REPAIRS PICTURES TABLE. PICTURE # ' + CAST(@RepairsPictureId AS Varchar)

					EXECUTE ILSINT02.FI_Data.dbo.USP_RepairsPictures @ServerRepairId, @RepairsPictureId, @PictureFileName, @LineItem, @PictureType, @SavedOn

					IF @@ERROR > 0
						SET @SPError = @@ERROR
				
					FETCH FROM RepPictures INTO @RepairsPictureId, @PictureFileName, @LineItem, @PictureType, @SavedOn
				END
			
				CLOSE RepPictures
				DEALLOCATE RepPictures
			END
		END
		ELSE
		BEGIN
			IF @ServerRepairId < -1
			BEGIN
				SET @SPError		= 0
				SET	@ServerRepairId	= ABS(@ServerRepairId)

				PRINT 'DUPLICATED REPAIR'
			END
		END
	END TRY
	BEGIN CATCH
		SET @SPError = ISNULL(ERROR_NUMBER(), 0)
	END CATCH
END

IF @SPError > 0
BEGIN
	ROLLBACK TRANSACTION
	SET @ExecutionError = -1
	SET @ErrorMessage = ERROR_MESSAGE()
END
ELSE
BEGIN
	-- FIXED ON 04/15/2013 13:55 PM

	UPDATE	Repairs 
	SET		Fk_SubmittedId	= @ServerRepairId, 
			SubmittedOn		= @ServerDateTime
	WHERE	Consecutive		= @Consecutive

	COMMIT TRANSACTION

	SET @ExecutionError = 0
	SET @ErrorMessage = ''

	PRINT @ServerRepairId
END

RETURN @ExecutionError
