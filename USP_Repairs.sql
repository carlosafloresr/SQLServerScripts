CREATE PROCEDURE USP_Repairs
		@Consecutive		Int,
		@WorkOrder			varchar(12),
		@Fk_SubmittedId		int,
		@InvoiceNumber		int,
		@CustomerNumber		varchar(50),
		@EquipmentType		char(1),
		@EquipmentSize		char(6),
		@EquipmentLocation  varchar(25),
		@RepairRemarks		varchar(200),
		@EstimateDate		datetime,
		@RepairDate			datetime,
		@Estimator			varchar(30),
		@Mechanic			varchar(20),
		@PrivateRemarks		varchar(200),
		@SerialNumber		varchar(30),
		@ModelNumber		varchar(25),
		@Hours				numeric(8,2),
		@Manufactor			varchar(20),
		@ManufactorDate		date,
		@RepairStatus		char(2),
		@ChassisInspection	bit
AS
BEGIN TRANSACTION

IF EXISTS(SELECT Consecutive FROM Repairs WHERE Consecutive = @Consecutive)
BEGIN
	UPDATE	Repairs
	SET		CustomerNumber		= @CustomerNumber,
			EquipmentType		= @EquipmentType,
			EquipmentSize		= @EquipmentSize,
			EquipmentLocation	= @EquipmentLocation,
			RepairRemarks		= @RepairRemarks,
			EstimateDate		= @EstimateDate,
			RepairDate			= @RepairDate,
			Estimator			= @Estimator,
			Mechanic			= @Mechanic,
			PrivateRemarks		= @PrivateRemarks,
			SerialNumber		= @SerialNumber,
			ModelNumber			= @ModelNumber,
			Hours				= @Hours,
			ChassisInspection	= @ChassisInspection
	WHERE	Consecutive			= @Consecutive
END
ELSE
BEGIN
	INSERT INTO Repairs
			(Consecutive
			,WorkOrder
			,Fk_SubmittedId
			,InvoiceNumber
			,CustomerNumber
			,EquipmentType
			,EquipmentSize
			,EquipmentLocation
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
			,ChassisInspection)
	VALUES
			(@Consecutive
			,@WorkOrder
			,@Fk_SubmittedId
			,@InvoiceNumber
			,@CustomerNumber
			,@EquipmentType
			,@EquipmentSize
			,@EquipmentLocation
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
			,@ChassisInspection)
END

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
	RETURN 0
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	RETURN @@ERROR
END