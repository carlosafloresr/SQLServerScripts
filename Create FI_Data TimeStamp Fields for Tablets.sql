USE [MobileEstimates]
GO

/*******************************************
TRUNCATE TABLE CodeRelations
GO
TRUNCATE TABLE Customers
GO
EXECUTE USP_Synchronize_Codes 'DALLAS'
GO
*******************************************/
-- select * from Customers where Acct_No = 'DALTRD'
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

-- JobCodes
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_JobCodes_TimeStamp')
BEGIN
	ALTER TABLE [dbo].JobCodes ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT JobCodes_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_JobCodes_TimeStamp ON [dbo].JobCodes
		([TimeStamp]) ON [PRIMARY]
END
GO

-- DamageCodes
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_DamageCodes_TimeStamp')
BEGIN
	ALTER TABLE [dbo].DamageCodes ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT DamageCodes_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_DamageCodes_TimeStamp ON [dbo].DamageCodes
		([TimeStamp]) ON [PRIMARY]
END
GO

-- RepairCodes
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_RepairCodes_TimeStamp')
BEGIN
	ALTER TABLE [dbo].[RepairCodes] ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX [IX_RepairCodes_TimeStamp] ON [dbo].[RepairCodes]
		([TimeStamp]) ON [PRIMARY]
END
GO

-- SubCategories
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_SubCategories_TimeStamp')
BEGIN
	ALTER TABLE [dbo].[SubCategories] ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT SubCategories_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_SubCategories_TimeStamp ON [dbo].[SubCategories]
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Positions
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Positions_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Positions ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Positions_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Positions_TimeStamp ON [dbo].Positions
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Locations
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Locations_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Locations ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Locations_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Locations_TimeStamp ON [dbo].Locations
		([TimeStamp]) ON [PRIMARY]
END
GO

-- CodeRelations
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_CodeRelations_TimeStamp')
BEGIN
	ALTER TABLE [dbo].CodeRelations ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT CodeRelations_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_CodeRelations_TimeStamp ON [dbo].CodeRelations
		([TimeStamp]) ON [PRIMARY]
END
GO

IF NOT EXISTS(SELECT object_id FROM sys.all_columns WHERE Name = 'DeletedOn')
BEGIN
	ALTER TABLE [dbo].CodeRelations ADD [DeletedOn] [Datetime]
END
GO

-- Mech
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Mech_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Mech ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Mech_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Mech_TimeStamp ON [dbo].Mech
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Translation
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Translation_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Translation ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Translation_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Translation_TimeStamp ON [dbo].Translation
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Depots
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Depots_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Depots ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Depots_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Depots_TimeStamp ON [dbo].Depots
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Customers
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Customers_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Customers ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Customers_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Customers_TimeStamp ON [dbo].Customers
		([TimeStamp]) ON [PRIMARY]
END
GO

-- ApprovalValues
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_ApprovalValues_TimeStamp')
BEGIN
	ALTER TABLE [dbo].ApprovalValues ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT ApprovalValues_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_ApprovalValues_TimeStamp ON [dbo].ApprovalValues
		([TimeStamp]) ON [PRIMARY]
END
GO

-- EquipmentSize
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_EquipmentSize_TimeStamp')
BEGIN
	ALTER TABLE [dbo].EquipmentSize ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT EquipmentSize_AddDateDflt DEFAULT '01/01/2012' WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_EquipmentSize_TimeStamp ON [dbo].EquipmentSize
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Fix CodeRelations Code
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE Name = 'IX_CodeRelations_Primary')
BEGIN
	TRUNCATE TABLE [MobileEstimates].dbo.CodeRelations

	BEGIN TRY
		ALTER TABLE [CodeRelations] DROP CONSTRAINT [PK_CodeRelations_Primary]
	END TRY
	BEGIN CATCH
		BEGIN TRY
			DROP INDEX [PK_CodeRelations_Primary] ON [dbo].[CodeRelations]
		END TRY
		BEGIN CATCH
			DROP INDEX [IX_CodeRelations_Primary] ON [dbo].[CodeRelations]
		END CATCH
	END CATCH

	ALTER TABLE [CodeRelations] DROP COLUMN [CodeRelationId]

	ALTER TABLE [CodeRelations] ADD [CodeRelationId] [int] NULL
	CREATE CLUSTERED INDEX [IX_CodeRelations_Primary] ON [dbo].[CodeRelations]
	([CodeRelationId] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
GO

USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_Synchronize_Codes_TimeStamp]    Script Date: 12/07/2012 12:34:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
******************************************
Synchronize Server Codes Codes with the 
local database
******************************************
EXECUTE USP_Synchronize_Codes 'HOUSTON'
******************************************
*/
ALTER PROCEDURE [dbo].[USP_Synchronize_Codes] (@Location Varchar(15) = Null)
AS
DECLARE	@SERVERONLINE	Bit,
		@LocCounter		Int,
		@SrvCounter		Int,
		@TimeStamp		Datetime

BEGIN TRY
     SELECT @SERVERONLINE = ServerRunning 
     FROM	ILSINT02.FI_Data.dbo.ServerRunning
END TRY
BEGIN CATCH
     SET @SERVERONLINE = 0
END CATCH

IF @SERVERONLINE = 1
BEGIN
	IF RTRIM(@Location) = ''
		SET @Location = NULL

	PRINT	'*** JOB CODES ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM JobCodes

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_JobCodes_TimeStamp @TimeStamp

			IF @SrvCounter > 0
			BEGIN
				SELECT	JobCode,
						Description,
						Category,
						Cost,
						TimeStamp
				INTO	#tmpRecords
				FROM	ILSINT02.FI_Data.dbo.JobCodes
				WHERE	TimeStamp > @TimeStamp
	
				INSERT INTO JobCodes
				SELECT	SRV.JobCode,
						SRV.Description,
						SRV.Category,
						SRV.Cost,
						SRV.TimeStamp
				FROM	#tmpRecords SRV
				WHERE	SRV.JobCode NOT IN (SELECT JobCode FROM JobCodes)

				UPDATE	JobCodes
				SET		JobCodes.Description	= SRV.Description,
						JobCodes.Category		= SRV.Category,
						JobCodes.Cost			= SRV.Cost,
						JobCodes.TimeStamp		= SRV.TimeStamp
				FROM	#tmpRecords SRV
				WHERE	JobCodes.JobCode = SRV.JobCode

				DROP TABLE #tmpRecords
			END

	PRINT	'*** DAMAGE CODES ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM DamageCodes

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_DamageCodes_TimeStamp @TimeStamp

			IF @SrvCounter > 0
			BEGIN
				SELECT	DamageCode
						,Description
						,Category
						,TimeStamp
				INTO	#tmpDamageCodes
				FROM	ILSINT02.FI_Data.dbo.DamageCodes
				WHERE	TimeStamp > @TimeStamp

				INSERT INTO DamageCodes
				SELECT	DamageCode
						,Description
						,Category
						,TimeStamp
				FROM	#tmpDamageCodes
				WHERE	DamageCode NOT IN (SELECT DamageCode FROM DamageCodes)

				UPDATE	DamageCodes
				SET		Description	= SRV.Description,
						Category	= SRV.Category,
						TimeStamp	= SRV.TimeStamp
				FROM	#tmpDamageCodes SRV
				WHERE	DamageCodes.DamageCode = SRV.DamageCode

				DROP TABLE #tmpDamageCodes
			END

	PRINT	'*** REPAIR CODES ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM RepairCodes

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_RepairCodes_TimeStamp @TimeStamp

			IF @SrvCounter > 0
			BEGIN
				SELECT	RepairCode
						,Description
						,Category
						,TimeStamp
				INTO	#tmpRepairCodes
				FROM	ILSINT02.FI_Data.dbo.RepairCodes
				WHERE	TimeStamp > @TimeStamp

				INSERT INTO RepairCodes
				SELECT	RepairCode
						,Description
						,Category
						,TimeStamp
				FROM	#tmpRepairCodes SRV
				WHERE	RepairCode NOT IN (SELECT RepairCode FROM RepairCodes)

				UPDATE	RepairCodes
				SET		Description	= SRV.Description,
						Category	= SRV.Category,
						TimeStamp	= SRV.TimeStamp
				FROM	#tmpRepairCodes SRV
				WHERE	RepairCodes.RepairCode = SRV.RepairCode

				DROP TABLE #tmpRepairCodes
			END
	
	PRINT	'*** SUBCATEGORIES ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM SubCategories

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_SubCategories_TimeStamp @TimeStamp
	
			IF @SrvCounter > 0
			BEGIN
				SELECT	Category,
						SubCategory,
						RequiresPosition,
						TimeStamp
				INTO	#tmpSubCategories
				FROM	ILSINT02.FI_Data.dbo.SubCategories
				WHERE	TimeStamp > @TimeStamp

				INSERT INTO SubCategories
				SELECT	Category,
						SubCategory,
						RequiresPosition,
						TimeStamp
				FROM	#tmpSubCategories
				WHERE	RTRIM(Category) + RTRIM(SubCategory) NOT IN (SELECT RTRIM(Category) + RTRIM(SubCategory) FROM SubCategories)

				UPDATE	SubCategories
				SET		RequiresPosition	= SRV.RequiresPosition,
						TimeStamp			= SRV.TimeStamp
				FROM	#tmpSubCategories SRV
				WHERE	SubCategories.Category = SRV.Category
						AND SubCategories.SubCategory = SRV.SubCategory

				DROP TABLE #tmpSubCategories
			END

	PRINT	'*** POSITIONS ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM Positions

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_Positions_TimeStamp @TimeStamp

			IF @SrvCounter > 0
			BEGIN
				SELECT	*
				INTO	#tmpPositions
				FROM	ILSINT02.FI_Data.dbo.Positions
				WHERE	TimeStamp > @TimeStamp

				INSERT INTO Positions
				SELECT	Category,
						Position,
						Inactive,
						TimeStamp
				FROM	#tmpPositions
				WHERE	RTRIM(Category) + RTRIM(Position) NOT IN (SELECT RTRIM(Category) + RTRIM(Position) FROM Positions)

				UPDATE	Positions
				SET		Inactive	= SRV.Inactive,
						TimeStamp	= SRV.TimeStamp
				FROM	#tmpPositions SRV
				WHERE	Positions.Category = SRV.Category
						AND Positions.Position = SRV.Position

				DROP TABLE #tmpPositions
			END

	PRINT	'*** LOCATIONS ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM Locations

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_Locations_TimeStamp @TimeStamp

			IF @SrvCounter > 0
			BEGIN
				SELECT	Location
						,SubLocation
						,CustomerNumber
						,Prefix
						,TimeStamp
				INTO	#tmpLocation
				FROM	ILSINT02.FI_Data.dbo.Locations
				WHERE	TimeStamp > @TimeStamp

				INSERT INTO Locations 
						(Location
						,SubLocation
						,CustomerNumber
						,Prefix
						,TimeStamp)
				SELECT	Location
						,SubLocation
						,CustomerNumber
						,Prefix
						,TimeStamp
				FROM	#tmpLocation
				WHERE	RTRIM(Location) + RTRIM(SubLocation) + RTRIM(CustomerNumber) NOT IN (SELECT RTRIM(Location) + RTRIM(SubLocation) + RTRIM(CustomerNumber) FROM Locations)

				UPDATE	Locations
				SET		Prefix		= SRV.Prefix,
						TimeStamp	= SRV.TimeStamp
				FROM	#tmpLocation SRV
				WHERE	Locations.Location = SRV.Location
						AND Locations.SubLocation = SRV.SubLocation
						AND Locations.CustomerNumber = SRV.CustomerNumber

				DROP TABLE #tmpLocation
			END

	PRINT	'*** CODE RELATIONS ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM CodeRelations WHERE (@Location IS NULL OR (@Location IS NOT NULL AND Location = @Location))

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_CodeRelations_TimeStamp @Location, @TimeStamp

			IF @SrvCounter > 0
			BEGIN
				SELECT	CodeRelationId, RelationType, ParentCode, ChildCode, Category, SubCategory, Location, TimeStamp, DeletedOn
				INTO	#tmpCodes
				FROM	ILSINT02.FI_Data.dbo.CodeRelations
				WHERE	Location = @Location
						AND TimeStamp > @TimeStamp

				UPDATE	CodeRelations
				SET		DeletedOn = #tmpCodes.DeletedOn
				FROM	#tmpCodes
				WHERE	CodeRelations.CodeRelationId = #tmpCodes.CodeRelationId
						AND #tmpCodes.DeletedOn IS NOT Null
						AND CodeRelations.DeletedOn IS Null

				INSERT INTO CodeRelations (CodeRelationId, RelationType, ParentCode, ChildCode, Category, SubCategory, Location, TimeStamp, DeletedOn)
				SELECT	DISTINCT CodeRelationId, RelationType, ParentCode, ChildCode, Category, SubCategory, Location, TimeStamp, DeletedOn
				FROM	#tmpCodes TMP
				WHERE	TMP.DeletedOn IS Null
						AND CodeRelationId NOT IN (SELECT CodeRelationId FROM CodeRelations WHERE DeletedOn IS Null AND Location = @Location)

				DROP TABLE #tmpCodes
			END

	PRINT	'*** MECHANICS ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM Mech

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_Mech_TimeStamp @TimeStamp

			IF @SrvCounter > 0
			BEGIN
				SELECT	*
				INTO	#tmpMech
				FROM	ILSINT02.FI_Data.dbo.Mech
				WHERE	TimeStamp > @TimeStamp
						AND Mech_No IS NOT Null
						AND Mech_No <> 'Add New'

				UPDATE	Mech
				SET		FName		= #tmpMech.FName,
						LName		= #tmpMech.LName,
						Depot_Loc	= #tmpMech.Depot_Loc,
						Active		= #tmpMech.Active,
						Password	= #tmpMech.Password,
						TimeStamp	= #tmpMech.TimeStamp
				FROM	#tmpMech
				WHERE	Mech.Mech_No = #tmpMech.Mech_No

				INSERT INTO Mech (Mech_No, FName, LName, Depot_Loc, Active, Password, TimeStamp)
				SELECT	Mech_No,
						FName,
						LName,
						Depot_Loc,
						Active,
						Password,
						TimeStamp
				FROM	#tmpMech
				WHERE	Mech_No NOT IN (SELECT Mech_No FROM Mech)
						AND Mech_No IS NOT Null
						AND Mech_No <> 'Add New'

				DROP TABLE #tmpMech
			END

	PRINT	'*** TRANSLATIONS ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM Translation

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_Translation_TimeStamp @TimeStamp

			IF @SrvCounter > 0
			BEGIN
				SELECT	*
				INTO	#tmpTranslation
				FROM	ILSINT02.FI_Data.dbo.Translation
				WHERE	TimeStamp > @TimeStamp

				INSERT INTO Translation (FormName, ObjectName, English, Spanish, TimeStamp)
				SELECT	FormName, ObjectName, English, Spanish, TimeStamp
				FROM	#tmpTranslation
				WHERE	RTRIM(FormName) + RTRIM(ObjectName) NOT IN (SELECT RTRIM(FormName) + RTRIM(ObjectName) FROM Translation)

				UPDATE	Translation
				SET		English		= SRV.English,
						Spanish		= SRV.Spanish,
						TimeStamp	= SRV.TimeStamp
				FROM	#tmpTranslation SRV
				WHERE	Translation.FormName = SRV.FormName
						AND Translation.ObjectName = SRV.ObjectName

				DROP TABLE #tmpTranslation
			END

	PRINT	'*** DEPOTS ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM Depots

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_Depots_TimeStamp @TimeStamp

			IF @LocCounter <> @SrvCounter
			BEGIN
				SELECT	*
				INTO	#tmpDepots
				FROM	ILSINT02.FI_Data.dbo.Depots
				WHERE	TimeStamp > @TimeStamp

				INSERT INTO Depots (Depot, Depot_Loc, Location, Use_Mech, Prefix, TimeStamp)
				SELECT	Depot
						,Depot_Loc
						,Location
						,Use_Mech
						,Prefix
						,TimeStamp
				FROM	#tmpDepots
				WHERE	Depot NOT IN (SELECT Depot FROM Depots)

				UPDATE	Depots
				SET		Depot_Loc	= SRV.Depot_Loc, 
						Location	= SRV.Location, 
						Use_Mech	= SRV.Use_Mech,
						Prefix		= SRV.Prefix,
						TimeStamp	= SRV.TimeStamp
				FROM	#tmpDepots
				WHERE	Depots.Depot = #tmpDepots.Depot

				DROP TABLE #tmpDepots
			END

	PRINT	'*** CUSTOMERS ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM Customers

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_Customers_TimeStamp @TimeStamp

			IF @SrvCounter > 0
			BEGIN
				SELECT	Acct_No, Acct_Name, Sales, Inactive, Percentage, TimeStamp
				INTO	#tmpCustomers
				FROM	ILSINT02.FI_Data.dbo.Customers
				WHERE	TimeStamp > @TimeStamp

				UPDATE	Customers
				SET		Acct_Name	= #tmpCustomers.Acct_Name, 
						Sales		= #tmpCustomers.Sales, 
						Inactive	= #tmpCustomers.Inactive,
						Percentage	= #tmpCustomers.Percentage,
						TimeStamp	= #tmpCustomers.TimeStamp
				FROM	#tmpCustomers
				WHERE	Customers.Acct_No = #tmpCustomers.Acct_No

				INSERT INTO Customers (Acct_No, Acct_Name, Sales, Inactive, Percentage, TimeStamp)
				SELECT	Acct_No, Acct_Name, Sales, Inactive, Percentage, TimeStamp
				FROM	#tmpCustomers
				WHERE	Acct_No NOT IN (SELECT Acct_No FROM Customers)

				DROP TABLE #tmpCustomers
			END

	PRINT	'*** APPROVAL VALUES ***'
			SELECT	Amount, Tires, TimeStamp
			INTO	#tmpApprovals
			FROM	ILSINT02.FI_Data.dbo.ApprovalValues

			IF EXISTS(SELECT Amount FROM ApprovalValues)
			BEGIN
				UPDATE	ApprovalValues
				SET		ApprovalValues.Amount	= #tmpApprovals.Amount,
						ApprovalValues.Tires	= #tmpApprovals.Tires
				FROM	#tmpApprovals
			END
			ELSE
			BEGIN
				INSERT INTO	ApprovalValues (Amount, Tires, TimeStamp) 
				SELECT	Amount, Tires, TimeStamp
				FROM	#tmpApprovals
			END

			DROP TABLE #tmpApprovals

	PRINT	'*** EQUIPMENT SIZE ***'
			SELECT	@TimeStamp = ISNULL(MAX(TimeStamp), '01/01/2012') FROM EquipmentSize

			EXECUTE @SrvCounter = ILSINT02.FI_Data.dbo.USP_EquipmentSize_TimeStamp @TimeStamp

			IF @SrvCounter > 0
			BEGIN
				SELECT	*
				INTO	#tmpEqSize
				FROM	ILSINT02.FI_Data.dbo.EquipmentSize
				WHERE	TimeStamp > @TimeStamp

				INSERT INTO EquipmentSize (EquipmentSize, Inactive, TimeStamp)
				SELECT	EquipmentSize, Inactive, TimeStamp
				FROM	#tmpEqSize
				WHERE	EquipmentSize NOT IN (SELECT EquipmentSize FROM EquipmentSize)

				UPDATE	EquipmentSize
				SET		Inactive	= SRV.Inactive,
						TimeStamp	= SRV.TimeStamp
				FROM	#tmpEqSize SRV
				WHERE	EquipmentSize.EquipmentSize = SRV.EquipmentSize

				DROP TABLE #tmpEqSize
			END
END
GO

/*
SELECT * FROM View_CodeRelations_Full WHERE Location = 'MEMPHIS'
*/
ALTER VIEW [dbo].[View_CodeRelations_Full]
AS
SELECT	CR.CodeRelationId
		,CR.RelationType
		,CR.ParentCode
		,CR.ChildCode
		,CR.Category
		,ISNULL(T1.Spanish, CR.Category) AS Category_Spanish
		,CR.SubCategory
		,ISNULL(T2.Spanish, CR.SubCategory) AS SubCategory_Spanish
		,CR.Location
		,CASE WHEN CR.RelationType = 'JC' THEN JC.Description
			  WHEN CR.RelationType = 'DC' THEN DC.Description
			  WHEN CR.RelationType = 'RC' THEN RC.Description
		END AS EnglishText
		,CASE WHEN CR.RelationType = 'JC' THEN ISNULL(TR.Spanish, JC.Description)
			  WHEN CR.RelationType = 'DC' THEN ISNULL(TR.Spanish, DC.Description)
			  WHEN CR.RelationType = 'RC' THEN ISNULL(TR.Spanish, RC.Description)
		END AS SpanishText
FROM	dbo.CodeRelations CR
		LEFT JOIN JobCodes JC ON CR.ChildCode = JC.JobCode AND CR.RelationType = 'JC'
		LEFT JOIN DamageCodes DC ON CR.ChildCode = DC.DamageCode AND CR.RelationType = 'DC'
		LEFT JOIN RepairCodes RC ON CR.ChildCode = RC.RepairCode AND CR.RelationType = 'RC'
		LEFT JOIN Translation TR ON CR.RelationType = TR.FormName AND CR.ChildCode = TR.ObjectName
		LEFT JOIN Translation T1 ON T1.FormName = 'CATEGORY' AND CR.Category = T1.ObjectName
		LEFT JOIN Translation T2 ON T2.FormName = 'SUBCATEGORY' AND CR.SubCategory = T2.ObjectName
WHERE	SubCategory IS NOT NulL
		AND DeletedOn IS Null
GO

/*
SELECT * FROM View_CodeRelations
*/
ALTER VIEW [dbo].[View_CodeRelations]
AS
SELECT	COR.RelationType
		,COR.ParentCode
		,LOC.Location AS ParentDescription
		,COR.ChildCode
		,JOC.Description AS ChildDescription
		,COR.Category
		,COR.SubCategory
		,1 AS Sort
FROM	CodeRelations COR
		INNER JOIN Locations LOC ON COR.ParentCode = LOC.Location
		INNER JOIN JobCodes JOC ON COR.ChildCode = JOC.JobCode
WHERE	RelationType = 'JC'
		AND DeletedOn IS Null
UNION
SELECT	COR.RelationType
		,COR.ParentCode
		,PAR.Description AS ParentDescription
		,COR.ChildCode
		,REC.Description AS ChildDescription
		,COR.Category
		,COR.SubCategory
		,2 AS Sort
FROM	CodeRelations COR
		INNER JOIN JobCodes PAR ON COR.ParentCode = PAR.JobCode
		INNER JOIN RepairCodes REC ON COR.ChildCode = REC.RepairCode
WHERE	RelationType = 'RC'
		AND DeletedOn IS Null
UNION
SELECT	COR.RelationType
		,COR.ParentCode
		,REC.Description AS ParentDescription
		,COR.ChildCode
		,DAC.Description AS ChildDescription
		,COR.Category
		,COR.SubCategory
		,3 AS Sort
FROM	CodeRelations COR
		INNER JOIN RepairCodes REC ON COR.ParentCode = REC.RepairCode
		INNER JOIN DamageCodes DAC ON COR.ChildCode = DAC.DamageCode
WHERE	RelationType = 'DC'
		AND DeletedOn IS Null
GO

USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_LoadJobCodes]    Script Date: 12/18/2012 4:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_LoadJobCodes 'TIRES', 'REPLACE', 'SP'
*/
ALTER PROCEDURE [dbo].[USP_LoadJobCodes]
		@Category		Varchar(20),
		@SubCategory	Varchar(25),
		@Languaje		Char(2) = 'EN'
AS
SELECT	DISTINCT ChildCode, 
		RTRIM(ChildCode) + ' - ' + CASE WHEN @Languaje = 'EN' THEN RTRIM(EnglishText) ELSE RTRIM(SpanishText) END AS ChildDescription 
FROM	View_CodeRelations_Full 
WHERE	RelationType = 'JC' 
		AND Category = @Category
		AND SubCategory = @SubCategory
		AND ChildCode IN (
						SELECT	ParentCode 
						FROM	View_CodeRelations
						WHERE	RelationType = 'RC' 
								AND Category = @Category
								AND SubCategory = @SubCategory
						)
ORDER BY 2
GO

IF EXISTS(SELECT object_id FROM sys.views WHERE Name = 'View_CodeRelations_Full')
BEGIN
	EXEC dbo.sp_executesql @statement = N'ALTER VIEW [dbo].[View_CodeRelations_Full]
	AS
	SELECT	CR.CodeRelationId
			,CR.RelationType
			,CR.ParentCode
			,CR.ChildCode
			,CR.Category
			,ISNULL(T1.Spanish, CR.Category) AS Category_Spanish
			,CR.SubCategory
			,ISNULL(T2.Spanish, CR.SubCategory) AS SubCategory_Spanish
			,CR.Location
			,CASE WHEN CR.RelationType = ''JC'' THEN JC.Description
				  WHEN CR.RelationType = ''DC'' THEN DC.Description
				  WHEN CR.RelationType = ''RC'' THEN RC.Description
			END AS EnglishText
			,CASE WHEN CR.RelationType = ''JC'' THEN ISNULL(TR.Spanish, JC.Description)
				  WHEN CR.RelationType = ''DC'' THEN ISNULL(TR.Spanish, DC.Description)
				  WHEN CR.RelationType = ''RC'' THEN ISNULL(TR.Spanish, RC.Description)
			END AS SpanishText
	FROM	dbo.CodeRelations CR
			LEFT JOIN JobCodes JC ON CR.ChildCode = JC.JobCode AND CR.RelationType = ''JC''
			LEFT JOIN DamageCodes DC ON CR.ChildCode = DC.DamageCode AND CR.RelationType = ''DC''
			LEFT JOIN RepairCodes RC ON CR.ChildCode = RC.RepairCode AND CR.RelationType = ''RC''
			LEFT JOIN Translation TR ON CR.RelationType = TR.FormName AND CR.ChildCode = TR.ObjectName
			LEFT JOIN Translation T1 ON T1.FormName = ''CATEGORY'' AND CR.Category = T1.ObjectName
			LEFT JOIN Translation T2 ON T2.FormName = ''SUBCATEGORY'' AND CR.SubCategory = T2.ObjectName
	WHERE	SubCategory IS NOT NulL
			AND DeletedOn IS Null'
END
ELSE
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[View_CodeRelations_Full]
	AS
	SELECT	CR.CodeRelationId
			,CR.RelationType
			,CR.ParentCode
			,CR.ChildCode
			,CR.Category
			,ISNULL(T1.Spanish, CR.Category) AS Category_Spanish
			,CR.SubCategory
			,ISNULL(T2.Spanish, CR.SubCategory) AS SubCategory_Spanish
			,CR.Location
			,CASE WHEN CR.RelationType = ''JC'' THEN JC.Description
				  WHEN CR.RelationType = ''DC'' THEN DC.Description
				  WHEN CR.RelationType = ''RC'' THEN RC.Description
			END AS EnglishText
			,CASE WHEN CR.RelationType = ''JC'' THEN ISNULL(TR.Spanish, JC.Description)
				  WHEN CR.RelationType = ''DC'' THEN ISNULL(TR.Spanish, DC.Description)
				  WHEN CR.RelationType = ''RC'' THEN ISNULL(TR.Spanish, RC.Description)
			END AS SpanishText
	FROM	dbo.CodeRelations CR
			LEFT JOIN JobCodes JC ON CR.ChildCode = JC.JobCode AND CR.RelationType = ''JC''
			LEFT JOIN DamageCodes DC ON CR.ChildCode = DC.DamageCode AND CR.RelationType = ''DC''
			LEFT JOIN RepairCodes RC ON CR.ChildCode = RC.RepairCode AND CR.RelationType = ''RC''
			LEFT JOIN Translation TR ON CR.RelationType = TR.FormName AND CR.ChildCode = TR.ObjectName
			LEFT JOIN Translation T1 ON T1.FormName = ''CATEGORY'' AND CR.Category = T1.ObjectName
			LEFT JOIN Translation T2 ON T2.FormName = ''SUBCATEGORY'' AND CR.SubCategory = T2.ObjectName
	WHERE	SubCategory IS NOT NulL
			AND DeletedOn IS Null'
END
GO

USE [MobileEstimates]
GO