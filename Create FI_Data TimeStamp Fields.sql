-- JobCodes
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_JobCodes_TimeStamp')
BEGIN
	ALTER TABLE [dbo].EquipmentSize ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT JobCodes_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_JobCodes_TimeStamp ON [dbo].JobCodes
		([TimeStamp]) ON [PRIMARY]
END
GO

-- DamageCodes
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_DamageCodes_TimeStamp')
BEGIN
	ALTER TABLE [dbo].DamageCodes ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT DamageCodes_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_DamageCodes_TimeStamp ON [dbo].DamageCodes
		([TimeStamp]) ON [PRIMARY]
END
GO

-- RepairCodes
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_RepairCodes_TimeStamp')
BEGIN
	ALTER TABLE [dbo].[RepairCodes] ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX [IX_RepairCodes_TimeStamp] ON [dbo].[RepairCodes]
		([TimeStamp]) ON [PRIMARY]
END
GO

-- SubCategories
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_SubCategories_TimeStamp')
BEGIN
	ALTER TABLE [dbo].[SubCategories] ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT SubCategories_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_SubCategories_TimeStamp ON [dbo].[SubCategories]
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Positions
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Positions_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Positions ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Positions_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Positions_TimeStamp ON [dbo].Positions
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Locations
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Locations_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Locations ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Locations_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Locations_TimeStamp ON [dbo].Locations
		([TimeStamp]) ON [PRIMARY]
END
GO

-- CodeRelations
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_CodeRelations_TimeStamp')
BEGIN
	ALTER TABLE [dbo].CodeRelations ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT CodeRelations_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_CodeRelations_TimeStamp ON [dbo].CodeRelations
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Mech
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Mech_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Mech ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Mech_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Mech_TimeStamp ON [dbo].Mech
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Translation
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Translation_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Translation ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Translation_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Translation_TimeStamp ON [dbo].Translation
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Depots
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Depots_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Depots ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Depots_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Depots_TimeStamp ON [dbo].Depots
		([TimeStamp]) ON [PRIMARY]
END
GO

-- Customers
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_Customers_TimeStamp')
BEGIN
	ALTER TABLE [dbo].Customers ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT Customers_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_Customers_TimeStamp ON [dbo].Customers
		([TimeStamp]) ON [PRIMARY]
END
GO

-- ApprovalValues
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_ApprovalValues_TimeStamp')
BEGIN
	ALTER TABLE [dbo].ApprovalValues ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT ApprovalValues_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_ApprovalValues_TimeStamp ON [dbo].ApprovalValues
		([TimeStamp]) ON [PRIMARY]
END
GO

-- EquipmentSize
IF NOT EXISTS(SELECT object_id FROM sys.indexes WHERE name = 'IX_EquipmentSize_TimeStamp')
BEGIN
	ALTER TABLE [dbo].EquipmentSize ADD [TimeStamp] [Datetime] NOT NULL
		CONSTRAINT EquipmentSize_AddDateDflt DEFAULT GETDATE() WITH VALUES 
	
	CREATE NONCLUSTERED INDEX IX_EquipmentSize_TimeStamp ON [dbo].EquipmentSize
		([TimeStamp]) ON [PRIMARY]
END
GO