DECLARE	@Consecutive		Int
SET @Consecutive = 1

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
		@CreationDate		Datetime,
		@ModificationDate	Datetime

SET		@Tablet = (SELECT UPPER(HOST_NAME()) AS Computer_Name)

SELECT	@WorkOrder			= WorkOrder
		,@InvoiceNumber		= InvoiceNumber
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
		,@CreationDate		= CreationDate
		,@ModificationDate	= ModificationDate
FROM	Repairs
WHERE	Consecutive			= @Consecutive

EXECUTE ILSINT02.FI_Data.dbo.USP_Repairs @Tablet
										,@Consecutive
										,@WorkOrder
										,@InvoiceNumber
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
										,@CreationDate
										,@ModificationDate