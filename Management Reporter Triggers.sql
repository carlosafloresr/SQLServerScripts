Alter table [Connector].[Integration] DISABLE trigger ALL 
Alter table [Connector].[Map] DISABLE trigger ALL 
Alter table [Scheduling].[TaskCategory] DISABLE trigger ALL 
Alter table [Scheduling].[Task] DISABLE trigger ALL 
Alter table [Scheduling].[Trigger] DISABLE trigger ALL 
go

DELETE FROM [Connector].[IntegrationGroup] 
DELETE FROM [Connector].[Map] WHERE [MapId] IN (SELECT [Id] FROM [Scheduling].[Task] WHERE [CategoryId] IN (SELECT [Id] FROM [Scheduling].[TaskCategory] WHERE [ParentId] IN (SELECT [Id] FROM [Scheduling].[TaskCategory] where ParentID is null))); 
DELETE FROM [Connector].[MapDefinition] WHERE [DefinitionId] NOT IN (SELECT DISTINCT DefinitionId FROM Connector.Map) 
go

DELETE FROM [Scheduling].[Task] WHERE [CategoryId] not IN (SELECT [Id] FROM [Scheduling].[TaskCategory] where ParentID is null) 
DELETE FROM [Scheduling].[Trigger] where Id NOT IN (SELECT distinct TriggerId from [Scheduling].[Task]) 
DELETE FROM [Connector].[MapCategoryAdapterSettings] 
go

Alter table [Connector].[Integration] ENABLE trigger ALL 
Alter table [Connector].[Map] ENABLE trigger ALL 
Alter table [Scheduling].[TaskCategory] ENABLE trigger ALL 
Alter table [Scheduling].[Task] ENABLE trigger ALL 
Alter table [Scheduling].[Trigger] ENABLE trigger ALL 
go

DELETE FROM [Connector].[Integration] 
go

DELETE FROM [Scheduling].[TaskCategory] 
go