/****** Object:  Table [dbo].[Translation]    Script Date: 01/30/2012 15:50:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Translation](
	[TranslationId] [int] IDENTITY(1,1) NOT NULL,
	[FormName] [varchar](50) NOT NULL,
	[ObjectName] [varchar](50) NOT NULL,
	[English] [varchar](250) NOT NULL,
	[Spanish] [varchar](250) NULL,
 CONSTRAINT [PK_Translation_Primary] PRIMARY KEY CLUSTERED 
(
	[TranslationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RepairsPictures]    Script Date: 01/30/2012 15:50:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RepairsPictures](
	[RepairsPictureId] [int] IDENTITY(1,1) NOT NULL,
	[Consecutive] [int] NOT NULL,
	[PictureFileName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_RepairPictures] PRIMARY KEY CLUSTERED 
(
	[RepairsPictureId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RepairsDetails]    Script Date: 01/30/2012 15:50:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RepairsDetails](
	[RepairDetailsId] [int] IDENTITY(1,1) NOT NULL,
	[Consecutive] [int] NOT NULL,
	[LineItem] [int] NOT NULL,
	[PartNumber] [varchar](25) NULL,
	[PartDescription] [varchar](40) NULL,
	[LocationCode] [varchar](20) NULL,
	[DamageCode] [varchar](10) NULL,
	[RepairCode] [varchar](10) NULL,
	[DamageWidth] [numeric](10, 2) NULL,
	[DamageLenght] [numeric](10, 2) NULL,
	[EquipmentType] [char](1) NULL,
	[ResponsibleParty] [char](1) NULL,
	[Quantity] [numeric](10, 2) NULL,
	[RepairedComponent] [varchar](25) NULL,
 CONSTRAINT [PK_RepairDetails_Primary] PRIMARY KEY CLUSTERED 
(
	[RepairDetailsId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Repairs]    Script Date: 01/30/2012 15:50:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Repairs](
	[Consecutive] [int] NOT NULL,
	[WorkOrder] [varchar](12) NOT NULL,
	[Fk_SubmittedId] [int] NULL,
	[InvoiceNumber] [int] NULL,
	[CustomerNumber] [varchar](50) NULL,
	[Equipment] [varchar](15) NULL,
	[EquipmentType] [char](1) NULL,
	[EquipmentSize] [char](6) NULL,
	[EquipmentLocation] [varchar](25) NULL,
	[SubLocation] [varchar](40) NULL,
	[RepairRemarks] [varchar](200) NULL,
	[EstimateDate] [datetime] NULL,
	[RepairDate] [datetime] NULL,
	[Estimator] [varchar](30) NULL,
	[Mechanic] [varchar](20) NULL,
	[PrivateRemarks] [varchar](200) NULL,
	[SerialNumber] [varchar](30) NULL,
	[ModelNumber] [varchar](25) NULL,
	[Hours] [numeric](8, 2) NULL,
	[Manufactor] [varchar](20) NULL,
	[ManufactorDate] [date] NULL,
	[RepairStatus] [char](2) NOT NULL,
	[ChassisInspection] [bit] NOT NULL,
	[ForSubmitting] [bit] NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModificationDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Repairs] PRIMARY KEY CLUSTERED 
(
	[Consecutive] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[USP_RepairsPictures]    Script Date: 01/30/2012 15:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_RepairsPictures]
		@Consecutive		Int,
		@PictureFileName	varchar(50)
AS
INSERT INTO RepairsPictures
           (Consecutive
           ,PictureFileName)
VALUES
           (@Consecutive
           ,@PictureFileName)
GO
/****** Object:  StoredProcedure [dbo].[USP_RepairsList]    Script Date: 01/30/2012 15:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_RepairsList] (@ForSubmitting Bit = 0)
AS
SELECT	Consecutive
		,RepairDate
		,EquipmentLocation
		,SubLocation
		,Equipment
		,EquipmentType
FROM	Repairs
WHERE	ForSubmitting = @ForSubmitting
ORDER BY Consecutive
GO
/****** Object:  StoredProcedure [dbo].[USP_RepairsDetails]    Script Date: 01/30/2012 15:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_RepairsDetails]
		@Consecutive		int,
		@LineItem			int,
		@PartNumber			varchar(25),
		@PartDescription	varchar(40),
		@LocationCode		varchar(20),
		@DamageCode			varchar(10),
		@RepairCode			varchar(10),
		@DamageWidth		numeric(10,2),
		@DamageLenght		numeric(10,2),
		@EquipmentType		char(1),
		@ResponsibleParty	char(1),
		@Quantity			numeric(10,2),
		@RepairedComponent	varchar(25)
AS
DECLARE	@RepairDetailsId	Int
SET		@RepairDetailsId	= (SELECT RepairDetailsId FROM RepairsDetails WHERE Consecutive = @Consecutive AND LineItem = @LineItem)

BEGIN TRANSACTION

IF @RepairDetailsId IS NULL
BEGIN
	INSERT INTO RepairsDetails
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
           ,RepairedComponent)
     VALUES
           (@Consecutive
           ,@LineItem
           ,@PartNumber
           ,@PartDescription
           ,@LocationCode
           ,@DamageCode
           ,@RepairCode
           ,@DamageWidth
           ,@DamageLenght
           ,@EquipmentType
           ,@ResponsibleParty
           ,@Quantity
           ,@RepairedComponent)
END
ELSE
BEGIN
	UPDATE	RepairsDetails
	SET		PartNumber			= @PartNumber,
			PartDescription		= @PartDescription,
			LocationCode		= @LocationCode,
			DamageCode			= @DamageCode,
			RepairCode			= @RepairCode,
			DamageWidth			= @DamageWidth,
			DamageLenght		= @DamageLenght,
			EquipmentType		= @EquipmentType,
			ResponsibleParty	= @ResponsibleParty,
			Quantity			= @Quantity,
			RepairedComponent	= @RepairedComponent
	WHERE	RepairDetailsId		= @RepairDetailsId
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
GO
/****** Object:  StoredProcedure [dbo].[USP_Repairs]    Script Date: 01/30/2012 15:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_Repairs]
		@Consecutive		Int,
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
		@ChassisInspection	bit
AS
BEGIN TRANSACTION

IF EXISTS(SELECT Consecutive FROM Repairs WHERE Consecutive = @Consecutive)
BEGIN
	UPDATE	Repairs
	SET		CustomerNumber		= @CustomerNumber,
			Equipment			= @Equipment,
			EquipmentType		= @EquipmentType,
			EquipmentSize		= @EquipmentSize,
			EquipmentLocation	= @EquipmentLocation,
			SubLocation			= @SubLocation,
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
			,ChassisInspection)
	VALUES
			(@Consecutive
			,@WorkOrder
			,@Fk_SubmittedId
			,@InvoiceNumber
			,@CustomerNumber
			,@Equipment
			,@EquipmentType
			,@EquipmentSize
			,@EquipmentLocation
			,@SubLocation
			,@RepairRemarks
			,GETDATE()
			,GETDATE()
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
GO
/****** Object:  StoredProcedure [dbo].[USP_DeleteRepair]    Script Date: 01/30/2012 15:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_DeleteRepair] (@Consecutive Int)
AS
DELETE Repairs WHERE Consecutive = @Consecutive
DELETE RepairsDetails WHERE Consecutive = @Consecutive
DELETE RepairsPictures WHERE Consecutive = @Consecutive
GO
/****** Object:  Default [DF_Repair_Consecutive]    Script Date: 01/30/2012 15:50:09 ******/
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repair_Consecutive]  DEFAULT ((0)) FOR [Consecutive]
GO
/****** Object:  Default [DF_Repair_RepairStatus]    Script Date: 01/30/2012 15:50:09 ******/
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repair_RepairStatus]  DEFAULT ('HH') FOR [RepairStatus]
GO
/****** Object:  Default [DF_Repair_ChassisInspection]    Script Date: 01/30/2012 15:50:09 ******/
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repair_ChassisInspection]  DEFAULT ((0)) FOR [ChassisInspection]
GO
/****** Object:  Default [DF_Repairs_ForSubmitting]    Script Date: 01/30/2012 15:50:09 ******/
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repairs_ForSubmitting]  DEFAULT ((0)) FOR [ForSubmitting]
GO
/****** Object:  Default [DF_Repair_CreationDate]    Script Date: 01/30/2012 15:50:09 ******/
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repair_CreationDate]  DEFAULT (getdate()) FOR [CreationDate]
GO
/****** Object:  Default [DF_Repair_ModificationDate]    Script Date: 01/30/2012 15:50:09 ******/
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repair_ModificationDate]  DEFAULT (getdate()) FOR [ModificationDate]
GO
/****** Object:  Default [DF_Sale_Equip_Id]    Script Date: 01/30/2012 15:50:09 ******/
ALTER TABLE [dbo].[RepairsDetails] ADD  CONSTRAINT [DF_Sale_Equip_Id]  DEFAULT ((1)) FOR [LineItem]
GO
/****** Object:  Default [DF_Sale_DamageWidth]    Script Date: 01/30/2012 15:50:09 ******/
ALTER TABLE [dbo].[RepairsDetails] ADD  CONSTRAINT [DF_Sale_DamageWidth]  DEFAULT ((0)) FOR [DamageWidth]
GO
