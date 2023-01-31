/************************************************************************************************
***                                     DATABASE VERSION 25                                   ***
*************************************************************************************************/
EXECUTE master..sp_addsrvrolemember @loginame = N'MobileUser', @rolename = N'sysadmin'
GO

EXECUTE master.dbo.sp_configure 'show advanced options', 1
RECONFIGURE
GO

EXECUTE master.dbo.sp_configure 'xp_cmdshell', 1
RECONFIGURE
GO

USE [MobileEstimates]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Add the Column LineItem to the table RepairsPictures
IF NOT EXISTS(SELECT * FROM SYS.all_columns WHERE object_id IN (SELECT object_id FROM SYS.tables WHERE Name = 'RepairsPictures') AND Name = 'LineItem')
BEGIN
	ALTER TABLE [dbo].[RepairsPictures]
	ADD [LineItem] Int NOT NULL
	CONSTRAINT RepairsPictures_LineItem DEFAULT 0
END
GO

-- Add the Column PictureType to the table RepairsPictures
IF NOT EXISTS(SELECT * FROM SYS.all_columns WHERE object_id IN (SELECT object_id FROM SYS.tables WHERE Name = 'RepairsPictures') AND Name = 'PictureType')
BEGIN
	ALTER TABLE [dbo].[RepairsPictures]
	ADD [PictureType] Char(1) NOT NULL
	CONSTRAINT RepairsPictures_PictureType DEFAULT 'R'
END
GO

-- Add the Column SavedOn to the table RepairsPictures
IF NOT EXISTS(SELECT * FROM SYS.all_columns WHERE object_id IN (SELECT object_id FROM SYS.tables WHERE Name = 'RepairsPictures') AND Name = 'SavedOn')
BEGIN
	ALTER TABLE [dbo].[RepairsPictures]
	ADD [SavedOn] Datetime NULL
	CONSTRAINT [DF_RepairsPictures_SavedOn]  DEFAULT (getdate())
END
GO

-- Add the Column RepairType to the table Repairs
IF NOT EXISTS(SELECT * FROM SYS.all_columns WHERE object_id IN (SELECT object_id FROM SYS.tables WHERE Name = 'Repairs') AND Name = 'RepairType')
BEGIN
	ALTER TABLE dbo.Repairs 
	ADD [RepairType] CHAR(1) NULL
END
GO

-- Add the Column MIDAS_Version to the table Repairs
IF NOT EXISTS(SELECT * FROM SYS.all_columns WHERE object_id IN (SELECT object_id FROM SYS.tables WHERE Name = 'Repairs') AND Name = 'MIDAS_Version')
BEGIN
	ALTER TABLE dbo.Repairs 
	ADD [MIDAS_Version] Varchar(12) NULL
END
GO

IF (SELECT max_length FROM SYS.all_columns WHERE object_id IN (SELECT object_id FROM SYS.tables WHERE Name = 'Repairs') AND Name = 'EquipmentSize') <> 10
BEGIN
	ALTER TABLE MobileEstimates.dbo.Repairs
	ALTER COLUMN [EquipmentSize] Varchar(10)
END
GO

IF NOT EXISTS(SELECT object_id FROM sys.objects WHERE name = 'DBVersion')
BEGIN
	CREATE TABLE [dbo].[DBVersion]([Version] [smallint] NOT NULL) ON [PRIMARY]

	INSERT INTO dbo.DBVersion (Version) VALUES (20)
END
GO

IF NOT EXISTS(SELECT Name FROM SysObjects WHERE Name = 'View_RepairsPictures' AND XType = 'V')
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[View_RepairsPictures]
	AS
	SELECT	RepairsPictureId,
			Consecutive,
			LineItem,
			PictureFileName, 
			PictureType,
			CASE WHEN PictureType = ''B'' THEN ''Before''
				WHEN PictureType = ''A'' THEN ''After''
				WHEN PictureType = ''I'' THEN ''Inspection''
				WHEN PictureType = ''D'' OR PictureFileName LIKE ''%_DRIVERSIGN%'' THEN ''Driver Signature''
				WHEN PictureType = ''M'' OR PictureFileName LIKE ''%_SIGNATURE%'' THEN ''Mechanic Signature''
				ELSE ''Regular''
			END AS [Type],
			CASE WHEN PictureType = ''B'' THEN 1
				WHEN PictureType = ''A'' THEN 2
				WHEN PictureType = ''I'' THEN 3
				WHEN PictureType = ''D'' OR PictureFileName LIKE ''%_DRIVERSIGN%'' THEN 5
				WHEN PictureType = ''M'' OR PictureFileName LIKE ''%_SIGNATURE%'' THEN 6
				ELSE 4
			END AS [TypeSort],
			SavedOn
	FROM	RepairsPictures
	WHERE	PictureType NOT IN (''D'',''M'')
			AND PictureFileName NOT LIKE ''%_SIGNATURE%''
			AND PictureFileName NOT LIKE ''%_DRIVERSIGN%'''
END
GO

IF NOT EXISTS(SELECT Name FROM SysObjects WHERE Name = 'View_RepairsPicturesAll' AND XType = 'V')
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[View_RepairsPicturesAll]
	AS
	SELECT	RepairsPictureId,
			RP.Consecutive,
			RP.LineItem,
			PictureFileName, 
			PictureType,
			CASE WHEN PictureType = ''B'' THEN ''Before''
				WHEN PictureType = ''A'' THEN ''After''
				WHEN PictureType = ''I'' THEN ''Inspection''
				WHEN PictureType = ''D'' OR PictureFileName LIKE ''%_DRIVERSIGN%'' THEN ''Driver Signature''
				WHEN PictureType = ''M'' OR PictureFileName LIKE ''%_SIGNATURE%'' THEN ''Mechanic Signature''
				ELSE ''Regular''
			END AS [Type],
			CASE WHEN PictureType = ''B'' THEN 1
				WHEN PictureType = ''A'' THEN 2
				WHEN PictureType = ''I'' THEN 3
				WHEN PictureType = ''D'' OR PictureFileName LIKE ''%_DRIVERSIGN%'' THEN 5
				WHEN PictureType = ''M'' OR PictureFileName LIKE ''%_SIGNATURE%'' THEN 6
				ELSE 4
			END AS [TypeSort],
			SavedOn
	FROM	RepairsPictures RP
			INNER JOIN RepairsDetails RD ON RP.Consecutive = RD.Consecutive AND RP.LineItem = RD.LineItem
	WHERE	PictureType NOT IN (''D'',''M'')
			AND PictureFileName NOT LIKE ''%_SIGNATURE%''
			AND PictureFileName NOT LIKE ''%_DRIVERSIGN%'''
END
GO

IF NOT EXISTS(SELECT Name FROM SysObjects WHERE Name = 'USP_SelectRepairsPictures' AND XType = 'P')
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[USP_SelectRepairsPictures]
			@Consecutive		Int,
			@LineItem			Int = Null,
			@DeleteDateTime		Datetime = Null
	AS
	IF @LineItem IS Null
	BEGIN
		SELECT	PictureFileName
		FROM	RepairsPictures 
		WHERE	Consecutive = @Consecutive
				AND SavedOn > @DeleteDateTime
	END
	ELSE
	BEGIN
		SELECT	PictureFileName
		FROM	RepairsPictures 
		WHERE	Consecutive = @Consecutive 
				AND	LineItem = @LineItem
				AND SavedOn > @DeleteDateTime
	END'
END
GO

IF NOT EXISTS(SELECT Name FROM SysObjects WHERE Name = 'USP_RetrieveRepairsPictures' AND XType = 'P')
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[USP_RetrieveRepairsPictures]
		@Consecutive	Int,
		@LineItem		Int = Null,
		@PictureId		Int = Null
	AS
	IF @LineItem IS Null AND @PictureId IS Null
	BEGIN
		SELECT	*
				INTO #tmpData
		FROM	(
				SELECT	DISTINCT 0 AS RepairsPictureId,
						RP.Consecutive,
						RP.LineItem,
						'''' AS PictureFileName, 
						'''' AS PictureType,
						''Item # '' + CAST(RP.LineItem AS Varchar) AS [Type],
						0 AS TypeSort,
						Null AS Parent,
						''N'' + dbo.PADL(RP.LineItem, 8, ''0'') AS Node,
						Null AS SavedOn,
						RTRIM(RD.PartDescription) AS PartDescription
				FROM	View_RepairsPicturesAll RP
						INNER JOIN RepairsDetails RD ON RP.Consecutive = RD.Consecutive AND RP.LineItem = RD.LineItem
				WHERE	RP.Consecutive = @Consecutive
						AND TypeSort < 5
				UNION
				SELECT	RepairsPictureId,
						Consecutive,
						LineItem,
						PictureFileName, 
						PictureType,
						[Type],
						TypeSort,
						''N'' + dbo.PADL(LineItem, 8, ''0'') AS Parent,
						[Type] + dbo.PADL(RepairsPictureId, 8, ''0'') AS Node,
						SavedOn,
						'''' AS PartDescription
				FROM	View_RepairsPictures 
				WHERE	Consecutive = @Consecutive
				) DATA

			SELECT	T1.*,
					ROW_NUMBER() OVER (PARTITION BY T1.PictureType ORDER BY T1.Parent, T1.SavedOn) AS RowNumber,
					Counter = (SELECT COUNT(*) FROM #tmpData T2 WHERE T2.LineItem = T1.LineItem AND T2.PictureType = T1.PictureType)
			FROM	#tmpData T1
			ORDER BY Consecutive, TypeSort, SavedOn

			DROP TABLE #tmpData
	END
	ELSE
	BEGIN
		IF @LineItem IS NOT Null AND @PictureId IS Null
		BEGIN
			SELECT	*
					INTO #tmpData2
			FROM	(
					SELECT	RepairsPictureId,
							Consecutive,
							LineItem,
							PictureFileName, 
							PictureType,
							[Type],
							TypeSort,
							''N'' + dbo.PADL(LineItem, 8, ''0'') AS Parent,
							[Type] + dbo.PADL(RepairsPictureId, 8, ''0'') AS Node,
							SavedOn,
							'''' AS PartDescription
					FROM	View_RepairsPictures 
					WHERE	Consecutive = @Consecutive
							AND LineItem = @LineItem
					) DATA

			SELECT	T1.*,
					ROW_NUMBER() OVER (PARTITION BY T1.PictureType ORDER BY T1.Parent, T1.SavedOn) AS RowNumber,
					Counter = (SELECT COUNT(*) FROM #tmpData2 T2 WHERE T2.LineItem = T1.LineItem AND T2.PictureType = T1.PictureType)
			FROM	#tmpData2 T1
			ORDER BY Consecutive, TypeSort, SavedOn

			DROP TABLE #tmpData2
		END
		ELSE
		BEGIN
			SELECT	* 
			FROM	RepairsPictures
			WHERE	Consecutive = @Consecutive 
					AND LineItem = @LineItem
					AND RepairsPictureId = @PictureId
		END
	END'
END
GO

IF NOT EXISTS(SELECT Name FROM SysObjects WHERE Name = 'USP_DeleteRepairsPictures' AND XType = 'P')
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[USP_DeleteRepairsPictures]
			@Consecutive		Int,
			@LineItem			Int = Null,
			@PictureFileName	Varchar(50) = Null,
			@DeleteDateTime		Datetime = Null
	AS
	IF @LineItem IS NOT Null
	BEGIN
		DELETE	RepairsPictures 
		WHERE	Consecutive = @Consecutive 
				AND	LineItem = @LineItem
				AND SavedOn > @DeleteDateTime
	END
	ELSE
	BEGIN
		DELETE	RepairsPictures 
		WHERE	Consecutive = @Consecutive 
				AND PictureFileName = @PictureFileName
				AND SavedOn > @DeleteDateTime
	END'
END
GO

IF NOT EXISTS(SELECT Name FROM SysObjects WHERE Name = 'USP_Check_DBVersion' AND XType = 'P')
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[USP_Check_DBVersion] (@Location Varchar(15) = Null)
	AS
	DECLARE	@SERVERONLINE	Bit = 0,
			@SrvVersion		Smallint = 0,
			@LocVersion		SmallInt = 0

	BEGIN TRY
			SELECT @SERVERONLINE = ServerRunning 
			FROM	ILSINT02.FI_Data.dbo.ServerRunning
	END TRY
	BEGIN CATCH
			SET @SERVERONLINE = 0
	END CATCH

	IF @SERVERONLINE = 1
	BEGIN
		SELECT @LocVersion	= [Version] FROM dbo.DBVersion
		SELECT @SrvVersion	= [Version] FROM ILSINT02.FI_Data.dbo.DBVersion

		IF @SrvVersion > @LocVersion
		BEGIN
			EXECUTE xp_cmdshell ''sqlcmd -S localhost -U MobileUser -P memphis1 -i \\iilogistics.com\NETLOGON\Midas\SQL_Script\Update_SQLServer_OnTablet.sql -e''

			IF @@ERROR = 0
			BEGIN
				UPDATE DBVersion SET Version = @SrvVersion
			END
		END

		EXECUTE dbo.USP_Synchronize_Codes @Location
	END'
END
GO

BEGIN TRY
	IF NOT EXISTS(SELECT Name FROM SysObjects WHERE Name = 'LastSubLocation' AND XType = 'U')
	BEGIN
		CREATE TABLE LastSubLocation (Location Varchar(20), SubLocation Varchar(25))
	END

	IF NOT EXISTS(SELECT Name FROM SysObjects WHERE Name = 'USP_SubLocation' AND XType = 'P')
	BEGIN
		EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE USP_SubLocation (@Location Varchar(20), @SubLocation Varchar(25))
		AS
		IF EXISTS(SELECT Name FROM SysObjects WHERE Name = ''LastSubLocation'' AND XType = ''U'')
		BEGIN
			IF EXISTS(SELECT Location FROM LastSubLocation WHERE Location = @Location)
			BEGIN
				UPDATE	LastSubLocation 
				SET		SubLocation = @SubLocation
				WHERE	Location	= @Location
			END
			ELSE
			BEGIN
				INSERT INTO LastSubLocation (Location, SubLocation) VALUES (@Location, @SubLocation)
			END
		END
		ELSE
		BEGIN
			CREATE TABLE LastSubLocation (Location Varchar(20), SubLocation Varchar(25))
			INSERT INTO LastSubLocation (Location, SubLocation) VALUES (@Location, @SubLocation)
		END'
	END
END TRY
BEGIN CATCH
     PRINT ERROR_MESSAGE()
END CATCH
GO

USE [MobileEstimates]
GO
/*
EXECUTE USP_RepairsList 0, 'NASHVILLE'
*/
ALTER PROCEDURE [dbo].[USP_RepairsList] (@Testing Bit = 0, @Location Varchar(20) = Null)
AS
SELECT	Consecutive
		,EstimateDate AS RepairDate
		,EquipmentLocation
		,SubLocation
		,Equipment
		,CASE EquipmentType WHEN 'R' THEN 'CHS' WHEN 'C' THEN 'CON' ELSE 'GEN' END AS EquipmentType
		,ForSubmitting
		,CAST(CASE WHEN Fk_SubmittedId IS NULL THEN 0 ELSE 1 END AS Bit) AS Submitted
		,0 AS Sort
		,BIDStatus
		,Mechanic
		,Lot_Road
FROM	Repairs
WHERE	(Fk_SubmittedId IS NULL OR (BIDStatus > 2 AND Fk_SubmittedId IS NULL))
		AND TestRecord = @Testing
		AND (@Location IS Null OR (@Location IS NOT Null AND EquipmentLocation = @Location))
UNION
SELECT	Consecutive
		,EstimateDate AS RepairDate
		,EquipmentLocation
		,SubLocation
		,Equipment
		,CASE EquipmentType WHEN 'R' THEN 'CHS' WHEN 'C' THEN 'CON' ELSE 'GEN' END AS EquipmentType
		,ForSubmitting
		,CAST(CASE WHEN Fk_SubmittedId IS NULL THEN 0 ELSE 1 END AS Bit) AS Submitted
		,1 AS Sort
		,BIDStatus
		,Mechanic
		,Lot_Road
FROM	Repairs
WHERE	Fk_SubmittedId IS NOT NULL
		AND SubmittedOn >= CAST(SubmittedOn AS Date)
		AND TestRecord = @Testing
		AND (@Location IS Null OR (@Location IS NOT Null AND EquipmentLocation = @Location))
ORDER BY 9, Consecutive DESC
GO

/*
SELECT * FROM View_CustomerByLocation
*/
ALTER VIEW [dbo].[View_CustomerByLocation]
AS
SELECT	CUS.Acct_No
		,CUS.Acct_Name
		,DEP.Depot_Loc
		,RTRIM(DEP.Depot_Loc) AS Location
		,LOC.SubLocation
		,CUS.Sales
		,CUS.Inactive
FROM	Customers CUS
		LEFT JOIN Locations LOC ON CUS.Acct_No = LOC.CustomerNumber
		LEFT JOIN Depots DEP ON DEP.Depot_Loc = LOC.Location OR LEFT(CUS.Acct_No, 3) = DEP.Prefix
GO

----------------------------------------------------------------------------------------------------------
/*
EXECUTE USP_FindNextConsecutive 'HH999', 1
*/
ALTER PROCEDURE [dbo].[USP_FindNextConsecutive] 
		@Tablet		Varchar(10) = Null,
		@OnServer	Bit = 0
AS
DECLARE	@NextId		Int,
		@Records	Int = 0

IF @Tablet IS Null
BEGIN
	IF PATINDEX('%HH%', @@SERVERNAME) = 0
	BEGIN
		SET @Tablet = 'HH099'
	END
	ELSE
	BEGIN
		SET @Tablet = RTRIM(UPPER(@@SERVERNAME))
	END
END

IF @OnServer = 1
BEGIN
	BEGIN TRY
		-- ***** CHECK IF THE SERVER IS ONLINE ***
		SELECT	@NextId = ISNULL(CAST(MAX(RIGHT(RTRIM(Workorder), 5)) + 1 AS Int), 1)
		FROM	ILSINT02.FI_Data.dbo.Repairs 
		WHERE	Tablet = @Tablet
	END TRY
	BEGIN CATCH
		 SELECT	@NextId = ISNULL(MAX(Consecutive) + 1, 1) 
		 FROM	Repairs
	END CATCH
END
ELSE
BEGIN
	SELECT	@NextId = ISNULL(MAX(Consecutive) + 1, 1) 
	FROM	Repairs
END

SELECT @NextId AS Consecutive
GO

----------------------------------------------------------------------------------------------------------
USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindAssignedBIDs]    Script Date: 04/11/2013 10:35:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
******************************************
Search and download Server Assigned BIDs 
to the local database
******************************************
EXECUTE USP_FindAssignedBIDs '1'
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
	SELECT	@SERVERONLINE = ServerRunning 
	FROM	ILSINT02.FI_Data.dbo.ServerRunning
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

	INSERT INTO	#tmpRepairs
	SELECT	RepairId
	FROM	ILSINT02.FI_Data.dbo.Repairs
	WHERE	BIDStatus IN (4,8)
			AND (BIDMechanic = @Mechanic
			OR Mechanic = @Mechanic)

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
				@TestRecord			Bit,
				@RepairType			Char(1)

		IF LEFT(@Tablet, 2) <> 'HH' OR @Tablet IS Null
			SET @Tablet = 'HH999'

		DECLARE AssignedRepairs CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT RepairId FROM #tmpRepairs

		OPEN AssignedRepairs
		FETCH FROM AssignedRepairs INTO @RepairId

		WHILE @@FETCH_STATUS = 0
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
					,@RepairType		= RepairType
			FROM	ILSINT02.FI_Data.dbo.Repairs
			WHERE	RepairId			= @RepairId

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
						,TestRecord
						,RepairType)
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
						@TestRecord,
						@RepairType)

			-- *** DETAIL INSERT DATA ***
			IF @BIDStatus <> 18
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

			UPDATE	ILSINT02.FI_Data.dbo.Repairs 
			SET		BIDStatus = CASE WHEN @BIDStatus = 8 THEN 9 ELSE 5 END 
			WHERE	RepairId	= @RepairId
			
			FETCH FROM AssignedRepairs INTO @RepairId
		END

		CLOSE AssignedRepairs
		DEALLOCATE AssignedRepairs
	END

	DROP TABLE #tmpRepairs
END

RETURN @ReturnValue
GO

----------------------------------------------------------------------------------------------------------
USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_SubmitRepair]    Script Date: 8/26/2014 9:01:04 AM ******/
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
		@EquipmentSize		Varchar(10),
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
GO
----------------------------------------------------------------------------------------------------------
USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_Repairs]    Script Date: 09/10/2013 10:11:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- LAST VERSION ---

ALTER PROCEDURE [dbo].[USP_Repairs]
		@Consecutive		Int,
		@WorkOrder			varchar(12),
		@Fk_SubmittedId		int = Null,
		@InvoiceNumber		int = Null,
		@CustomerNumber		varchar(20),
		@Equipment			varchar(40),
		@EquipmentType		char(1),
		@EquipmentSize		char(10),
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
		@ChassisInspection	Bit,
		@ForSubmitting		Bit = 0,
		@Container			Varchar(15) = Null,
		@ContainerMounted	Bit = Null,
		@Lot_Road			Varchar(15),
		@FMCSA				Date = Null,
		@BIDStatus			Smallint = 0,
		@TestRecord			Bit = 0,
		@RepairType			Char(1) = Null,
		@MIDAS_Version		Varchar(15) = Null
AS
BEGIN TRANSACTION

IF @RepairDate IS Null OR @RepairDate < '01/01/1980'
	SET @RepairDate = @EstimateDate

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
			Manufactor			= @Manufactor,
			PrivateRemarks		= @PrivateRemarks,
			SerialNumber		= @SerialNumber,
			ModelNumber			= @ModelNumber,
			Hours				= @Hours,
			ChassisInspection	= @ChassisInspection,
			ForSubmitting		= @ForSubmitting,
			Container			= @Container,
			ContainerMounted	= @ContainerMounted,
			Lot_Road			= @Lot_Road,
			RepairStatus		= @RepairStatus,
			FMCSA				= @FMCSA,
			BIDStatus			= @BIDStatus,
			TestRecord			= @TestRecord,
			RepairType			= @RepairType,
			MIDAS_Version		= @MIDAS_Version
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
			,ChassisInspection
			,ForSubmitting
			,Container
			,ContainerMounted
			,Lot_Road
			,FMCSA
			,TestRecord
			,BIDStatus
			,RepairType
			,MIDAS_Version)
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
			,@ForSubmitting
			,@Container
			,@ContainerMounted
			,@Lot_Road
			,@FMCSA
			,@TestRecord
			,@BIDStatus
			,@RepairType
			,@MIDAS_Version)
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


USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindAssignedBIDs]    Script Date: 08/20/2013 3:54:13 PM ******/
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
	SELECT	@SERVERONLINE = ServerRunning 
	FROM	ILSINT02.FI_Data.dbo.ServerRunning
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

	INSERT INTO	#tmpRepairs
	SELECT	RepairId
	FROM	ILSINT02.FI_Data.dbo.Repairs
	WHERE	BIDStatus IN (4,8)
			AND (BIDMechanic = @Mechanic
			OR Mechanic = @Mechanic)
			
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
				@TestRecord			Bit,
				@RepairType			Char(1)

		IF LEFT(@Tablet, 2) <> 'HH' OR @Tablet IS Null
			SET @Tablet = RIGHT(@@SERVERNAME, 5)

		DECLARE AssignedRepairs CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT RepairId FROM #tmpRepairs

		OPEN AssignedRepairs
		FETCH FROM AssignedRepairs INTO @RepairId

		WHILE @@FETCH_STATUS = 0
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
					,@RepairType		= RepairType
			FROM	ILSINT02.FI_Data.dbo.Repairs
			WHERE	RepairId			= @RepairId

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
						,TestRecord
						,RepairType)
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
						@TestRecord,
						@RepairType)

			-- *** DETAIL INSERT DATA ***
			IF @BIDStatus <> 18
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

			UPDATE	ILSINT02.FI_Data.dbo.Repairs 
			SET		BIDStatus	= CASE WHEN @BIDStatus = 8 THEN 9 ELSE 5 END 
			WHERE	RepairId	= @RepairId
			
			FETCH FROM AssignedRepairs INTO @RepairId
		END

		CLOSE AssignedRepairs
		DEALLOCATE AssignedRepairs
	END

	DROP TABLE #tmpRepairs
END

RETURN @ReturnValue
GO
----------------------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[USP_RepairsPictures]
		@Consecutive		Int,
		@LineItem			Int,
		@PictureFileName	Varchar(50),
		@PictureType		Char(1)
AS
INSERT INTO RepairsPictures
           (Consecutive
		   ,LineItem
           ,PictureFileName
		   ,PictureType)
VALUES
           (@Consecutive
		   ,@LineItem
           ,@PictureFileName
		   ,@PictureType)
GO
----------------------------------------------------------------------------------------------------------
USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_RetrieveRepairsPictures]    Script Date: 8/25/2014 4:03:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_RetrieveRepairsPictures 1, 1
*/
ALTER PROCEDURE [dbo].[USP_RetrieveRepairsPictures]
	@Consecutive	Int,
	@LineItem		Int = Null,
	@PictureId		Int = Null
AS
IF @LineItem IS Null AND @PictureId IS Null
BEGIN
	SELECT	*
			INTO #tmpData
	FROM	(
			SELECT	DISTINCT 0 AS RepairsPictureId,
					RP.Consecutive,
					RP.LineItem,
					'' AS PictureFileName, 
					'' AS PictureType,
					'Item # ' + CAST(RP.LineItem AS Varchar) AS [Type],
					0 AS TypeSort,
					Null AS Parent,
					'N' + dbo.PADL(RP.LineItem, 8, '0') AS Node,
					Null AS SavedOn,
					RTRIM(RD.PartDescription) AS PartDescription
			FROM	View_RepairsPicturesAll RP
					INNER JOIN RepairsDetails RD ON RP.Consecutive = RD.Consecutive AND RP.LineItem = RD.LineItem
			WHERE	RP.Consecutive = @Consecutive
					AND TypeSort < 5
			UNION
			SELECT	RepairsPictureId,
					Consecutive,
					LineItem,
					PictureFileName, 
					PictureType,
					[Type],
					TypeSort,
					'N' + dbo.PADL(LineItem, 8, '0') AS Parent,
					[Type] + dbo.PADL(RepairsPictureId, 8, '0') AS Node,
					SavedOn,
					'' AS PartDescription
			FROM	View_RepairsPictures 
			WHERE	Consecutive = @Consecutive
			) DATA

		SELECT	T1.*,
				ROW_NUMBER() OVER (PARTITION BY T1.PictureType ORDER BY T1.Parent, T1.SavedOn) AS RowNumber,
				Counter = (SELECT COUNT(*) FROM #tmpData T2 WHERE T2.LineItem = T1.LineItem AND T2.PictureType = T1.PictureType)
		FROM	#tmpData T1
		ORDER BY Consecutive, TypeSort, SavedOn

		DROP TABLE #tmpData
END
ELSE
BEGIN
	IF @LineItem IS NOT Null AND @PictureId IS Null
	BEGIN
		SELECT	*
				INTO #tmpData2
		FROM	(
				SELECT	RepairsPictureId,
						Consecutive,
						LineItem,
						PictureFileName, 
						PictureType,
						[Type],
						TypeSort,
						'N' + dbo.PADL(LineItem, 8, '0') AS Parent,
						[Type] + dbo.PADL(RepairsPictureId, 8, '0') AS Node,
						SavedOn,
						'' AS PartDescription
				FROM	View_RepairsPictures 
				WHERE	Consecutive = @Consecutive
						AND LineItem = @LineItem
				) DATA

		SELECT	T1.*,
				ROW_NUMBER() OVER (PARTITION BY T1.PictureType ORDER BY T1.Parent, T1.SavedOn) AS RowNumber,
				Counter = (SELECT COUNT(*) FROM #tmpData2 T2 WHERE T2.LineItem = T1.LineItem AND T2.PictureType = T1.PictureType)
		FROM	#tmpData2 T1
		ORDER BY Consecutive, TypeSort, SavedOn

		DROP TABLE #tmpData2
	END
	ELSE
	BEGIN
		SELECT	* 
		FROM	RepairsPictures
		WHERE	Consecutive = @Consecutive 
				AND LineItem = @LineItem
				AND RepairsPictureId = @PictureId
	END
END
GO

----------------------------------------------------------------------------------------------------------
USE [MobileEstimates]
GO

EXECUTE sp_MSforeachtable @command1="PRINT '?' DBCC DBREINDEX ('?', ' ', 80)"
GO

EXECUTE sp_updatestats
GO

EXECUTE USP_ShrinkLogFile
GO

--DECLARE	@Location	Varchar(25)

--SELECT	@Location = ISNULL(EquipmentLocation, 'MEMPHIS')
--FROM	Repairs
--WHERE	Consecutive IN (SELECT MAX(Consecutive) FROM Repairs)

--EXECUTE USP_Synchronize_Codes @Location
--GO