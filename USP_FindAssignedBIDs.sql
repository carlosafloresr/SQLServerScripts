USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindAssignedBIDs]    Script Date: 03/19/2013 11:23:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
******************************************
Search and download Server Assigned BIDs 
to the local database
******************************************
EXECUTE USP_FindAssignedBIDs '9999'

EXECUTE USP_ClearEntryTables
******************************************
*/
ALTER PROCEDURE [dbo].[USP_FindAssignedBIDs] (@Mechanic Varchar(10))
AS
DECLARE	@SERVERONLINE		Bit,
		@ReturnValue		Int = 0,
		@RepairId			Int = 0,
		@Consecutive		Int = 0,
		@CentralDatabase	Varchar(50)

BEGIN TRY
	SELECT	@CentralDatabase = RTRIM(UPPER(CentralDatabase))
	FROM	CentralDatabase

	IF @CentralDatabase = 'FI_DATA'
	BEGIN
		SELECT	@SERVERONLINE = ServerRunning 
		FROM	ILSINT02.FI_Data.dbo.ServerRunning
	END
	ELSE
	BEGIN
		SELECT	@SERVERONLINE = ServerRunning 
		FROM	ILSINT02.FI_Data_Test.dbo.ServerRunning
	END
END TRY
BEGIN CATCH
     SET @SERVERONLINE = 0
END CATCH

IF @SERVERONLINE = 1
BEGIN
	-- *** FIND ASSIGNED BIDS ***
	SELECT	RepairId
	INTO	#tmpRepairs
	FROM	ILSINT02.FI_Data.dbo.Repairs
	WHERE	BIDStatus = 1000

	IF @CentralDatabase = 'FI_DATA'
	BEGIN
		INSERT INTO	#tmpRepairs
		SELECT	RepairId
		FROM	ILSINT02.FI_Data.dbo.Repairs
		WHERE	BIDStatus IN (4,8)
				AND (BIDMechanic = @Mechanic
				OR Mechanic = @Mechanic)
	END
	ELSE
	BEGIN
		INSERT INTO	#tmpRepairs
		SELECT	RepairId
		FROM	ILSINT02.FI_Data_Test.dbo.Repairs
		WHERE	BIDStatus IN (4,8)
				AND (BIDMechanic = @Mechanic
				OR Mechanic = @Mechanic)
	END

	IF @@ROWCOUNT > 0
	BEGIN
		SET @ReturnValue = 1

		DECLARE	@Tablet				Varchar(15),
				@WorkOrder			varchar(12),
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
				@ServerDateTime		Datetime,
				@BIDStatus			Smallint,
				@TestRecord			Bit

		IF LEFT(@Tablet, 2) <> 'HH' OR @Tablet IS Null
			SET @Tablet = 'HH999'

		DECLARE AssignedRepairs CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT RepairId FROM #tmpRepairs

		OPEN AssignedRepairs
		FETCH FROM AssignedRepairs INTO @RepairId

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CentralDatabase = 'FI_DATA'
			BEGIN
				SELECT	@WorkOrder			= RTRIM(WorkOrder)
						,@InvoiceNumber		= RTRIM(InvoiceNumber)
						,@CustomerNumber	= RTRIM(CustomerNumber)
						,@Equipment			= RTRIM(Equipment)
						,@EquipmentType		= EquipmentType
						,@EquipmentSize		= RTRIM(EquipmentSize)
						,@EquipmentLocation	= RTRIM(EquipmentLocation)
						,@SubLocation		= RTRIM(SubLocation)
						,@RepairRemarks		= RTRIM(RepairRemarks)
						,@EstimateDate		= EstimateDate
						,@RepairDate		= RepairDate
						,@Estimator			= Estimator
						,@Mechanic			= Mechanic
						,@PrivateRemarks	= RTRIM(PrivateRemarks)
						,@SerialNumber		= RTRIM(SerialNumber)
						,@ModelNumber		= RTRIM(ModelNumber)
						,@Hours				= Hours
						,@Manufactor		= Manufactor
						,@ManufactorDate	= ManufactorDate
						,@RepairStatus		= RepairStatus
						,@ChassisInspection	= ChassisInspection
						,@RepairStatus		= RepairStatus
						,@Container			= RTRIM(Container)
						,@ContainerMounted	= ContainerMounted
						,@Lot_Road			= RTRIM(Lot_Road)
						,@FMCSA				= FMCSA
						,@CreationDate		= CreationDate
						,@ModificationDate	= ModificationDate
						,@Status			= 0
						,@BIDStatus			= BIDStatus
						,@TestRecord		= TestRecord
				FROM	ILSINT02.FI_Data.dbo.Repairs
				WHERE	RepairId			= @RepairId
			END
			ELSE
			BEGIN
				SELECT	@WorkOrder			= RTRIM(WorkOrder)
						,@InvoiceNumber		= RTRIM(InvoiceNumber)
						,@CustomerNumber	= RTRIM(CustomerNumber)
						,@Equipment			= RTRIM(Equipment)
						,@EquipmentType		= EquipmentType
						,@EquipmentSize		= RTRIM(EquipmentSize)
						,@EquipmentLocation	= RTRIM(EquipmentLocation)
						,@SubLocation		= RTRIM(SubLocation)
						,@RepairRemarks		= RTRIM(RepairRemarks)
						,@EstimateDate		= EstimateDate
						,@RepairDate		= RepairDate
						,@Estimator			= Estimator
						,@Mechanic			= Mechanic
						,@PrivateRemarks	= RTRIM(PrivateRemarks)
						,@SerialNumber		= RTRIM(SerialNumber)
						,@ModelNumber		= RTRIM(ModelNumber)
						,@Hours				= Hours
						,@Manufactor		= Manufactor
						,@ManufactorDate	= ManufactorDate
						,@RepairStatus		= RepairStatus
						,@ChassisInspection	= ChassisInspection
						,@RepairStatus		= RepairStatus
						,@Container			= RTRIM(Container)
						,@ContainerMounted	= ContainerMounted
						,@Lot_Road			= RTRIM(Lot_Road)
						,@FMCSA				= FMCSA
						,@CreationDate		= CreationDate
						,@ModificationDate	= ModificationDate
						,@Status			= 0
						,@BIDStatus			= BIDStatus
						,@TestRecord		= TestRecord
				FROM	ILSINT02.FI_Data_Test.dbo.Repairs
				WHERE	RepairId			= @RepairId
			END

			SET @Consecutive = (SELECT Consecutive FROM Repairs WHERE InvoiceNumber = @InvoiceNumber)

			IF @Consecutive IS NOT Null
			BEGIN
				EXECUTE USP_DeleteRepair @Consecutive
			END
			ELSE
			BEGIN
				SET @Consecutive = (SELECT ISNULL(MAX(Consecutive) + 1, 1) AS TicketNumber FROM Repairs)
			END

			IF @WorkOrder IS Null
				SET @WorkOrder = @Tablet + '-' + dbo.PADL(@Consecutive, 5, '0')

			SELECT	@SubLocation = Sublocation
			FROM	LastSubLocation
			WHERE	Location = @EquipmentLocation

			-- *** HEADER DATA INSERT ***
			INSERT INTO dbo.Repairs
						(Consecutive
						,WorkOrder
						,Fk_SubmittedId
						,InvoiceNumber
						,CustomerNumber
						,Equipment
						,EquipmentType
						,EquipmentSize
						,EquipmentLocation
						,SubLocation
						,RepairRemarks
						,EstimateDate
						,RepairDate
						,Estimator
						,Mechanic
						,PrivateRemarks
						,SerialNumber
						,ModelNumber
						,Hours
						,Manufactor
						,ManufactorDate
						,RepairStatus
						,ChassisInspection
						,ForSubmitting
						,CreationDate
						,ModificationDate
						,SubmittedOn
						,Container
						,ContainerMounted
						,Lot_Road
						,FMCSA
						,BIDStatus
						,BIDEstimate
						,TestRecord)
					VALUES
						(@Consecutive,
						@WorkOrder,
						NULL,
						@InvoiceNumber,
						@CustomerNumber,
						@Equipment,
						@EquipmentType,
						@EquipmentSize,
						@EquipmentLocation,
						@SubLocation,
						@RepairRemarks,
						CASE WHEN @EstimateDate IS Null THEN GETDATE() ELSE @EstimateDate END,
						CASE WHEN @RepairDate IS Null THEN GETDATE() ELSE @RepairDate END,
						@Estimator,
						@Mechanic,
						@PrivateRemarks,
						@SerialNumber,
						@ModelNumber,
						@Hours,
						@Manufactor,
						@ManufactorDate,
						@RepairStatus,
						@ChassisInspection,
						0,
						@CreationDate,
						@ModificationDate,
						Null,
						@Container,
						@ContainerMounted,
						@Lot_Road,
						@FMCSA,
						@BIDStatus,
						Null,
						@TestRecord)

			-- *** DETAIL INSERT DATA ***

			IF @BIDStatus <> 18
			BEGIN
				IF @CentralDatabase = 'FI_DATA'
				BEGIN
					INSERT INTO dbo.RepairsDetails
								(Consecutive
								,LineItem
								,PartNumber
								,PartDescription
								,LocationCode
								,DamageCode
								,RepairCode
								,DamageWidth
								,DamageLenght
								,EquipmentType
								,ResponsibleParty
								,Quantity
								,RepairedComponent
								,DOTIn
								,DOTOut
								,SubCategory
								,RecapperOn
								,RecapperOff
								,Position
								,ItemCost
								,ActualCost
								,BIDItemCompleted)
					SELECT		@Consecutive
								,LineItem
								,PartNumber
								,PartDescription
								,LocationCode
								,DamageCode
								,RepairCode
								,DamageWidth
								,DamageLenght
								,EquipmentType
								,ResponsibleParty
								,Quantity
								,RepairedComponent
								,DOTIn
								,DOTOut
								,SubCategory
								,RecapperOn
								,RecapperOff
								,Position
								,ISNULL(ItemCost, 0.00)
								,ISNULL(ActualCost, 0.00)
								,0 AS CompletedItem
					FROM		ILSINT02.FI_Data.dbo.RepairsDetails
					WHERE		Fk_RepairId = @RepairId
								AND PartNumber <> ''
				END
				ELSE
				BEGIN
					INSERT INTO dbo.RepairsDetails
								(Consecutive
								,LineItem
								,PartNumber
								,PartDescription
								,LocationCode
								,DamageCode
								,RepairCode
								,DamageWidth
								,DamageLenght
								,EquipmentType
								,ResponsibleParty
								,Quantity
								,RepairedComponent
								,DOTIn
								,DOTOut
								,SubCategory
								,RecapperOn
								,RecapperOff
								,Position
								,ItemCost
								,ActualCost
								,BIDItemCompleted)
					SELECT		@Consecutive
								,LineItem
								,PartNumber
								,PartDescription
								,LocationCode
								,DamageCode
								,RepairCode
								,DamageWidth
								,DamageLenght
								,EquipmentType
								,ResponsibleParty
								,Quantity
								,RepairedComponent
								,DOTIn
								,DOTOut
								,SubCategory
								,RecapperOn
								,RecapperOff
								,Position
								,ISNULL(ItemCost, 0.00)
								,ISNULL(ActualCost, 0.00)
								,0 AS CompletedItem
					FROM		ILSINT02.FI_Data_Test.dbo.RepairsDetails
					WHERE		Fk_RepairId = @RepairId
								AND PartNumber <> ''
				END
			END

			IF @CentralDatabase = 'FI_DATA'
			BEGIN
				UPDATE	ILSINT02.FI_Data.dbo.Repairs 
				SET		BIDStatus = CASE WHEN @BIDStatus = 8 THEN 9 ELSE 5 END 
				WHERE	RepairId	= @RepairId
			END
			ELSE
			BEGIN
				UPDATE	ILSINT02.FI_Data_Test.dbo.Repairs 
				SET		BIDStatus = CASE WHEN @BIDStatus = 8 THEN 9 ELSE 5 END 
				WHERE	RepairId	= @RepairId
			END
			
			FETCH FROM AssignedRepairs INTO @RepairId
		END

		CLOSE AssignedRepairs
		DEALLOCATE AssignedRepairs
	END

	DROP TABLE #tmpRepairs
END

RETURN @ReturnValue