USE MobileEstimates
GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_SubCategories_RequiresPosition]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[SubCategories] DROP CONSTRAINT [DF_SubCategories_RequiresPosition]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_RepairsDetails_BIDItemCompleted]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RepairsDetails] DROP CONSTRAINT [DF_RepairsDetails_BIDItemCompleted]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_RepairsDetails_ActualCost]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RepairsDetails] DROP CONSTRAINT [DF_RepairsDetails_ActualCost]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_RepairsDetails_ItemCost]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RepairsDetails] DROP CONSTRAINT [DF_RepairsDetails_ItemCost]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Sale_DamageWidth]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RepairsDetails] DROP CONSTRAINT [DF_Sale_DamageWidth]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Sale_Equip_Id]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RepairsDetails] DROP CONSTRAINT [DF_Sale_Equip_Id]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repairs_TestRecord]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] DROP CONSTRAINT [DF_Repairs_TestRecord]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repairs_BIDStatus]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] DROP CONSTRAINT [DF_Repairs_BIDStatus]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repair_ModificationDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] DROP CONSTRAINT [DF_Repair_ModificationDate]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repair_CreationDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] DROP CONSTRAINT [DF_Repair_CreationDate]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repairs_ForSubmitting]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] DROP CONSTRAINT [DF_Repairs_ForSubmitting]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repair_ChassisInspection]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] DROP CONSTRAINT [DF_Repair_ChassisInspection]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repair_RepairStatus]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] DROP CONSTRAINT [DF_Repair_RepairStatus]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repair_Consecutive]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] DROP CONSTRAINT [DF_Repair_Consecutive]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Positions_Inactive]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Positions] DROP CONSTRAINT [DF_Positions_Inactive]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_JobCodes_Cost]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[JobCodes] DROP CONSTRAINT [DF_JobCodes_Cost]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_EquipmentSize_Inactive]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[EquipmentSize] DROP CONSTRAINT [DF_EquipmentSize_Inactive]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Customers_Percentage]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Customers] DROP CONSTRAINT [DF_Customers_Percentage]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Customers_Inactive]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Customers] DROP CONSTRAINT [DF_Customers_Inactive]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Customers_Sales]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Customers] DROP CONSTRAINT [DF_Customers_Sales]
END

GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_CodeRelations_Category]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CodeRelations] DROP CONSTRAINT [DF_CodeRelations_Category]
END

GO
/****** Object:  Index [IX_Translation_ObjectName]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Translation]') AND name = N'IX_Translation_ObjectName')
DROP INDEX [IX_Translation_ObjectName] ON [dbo].[Translation]
GO
/****** Object:  Index [IX_Translation_FormName]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Translation]') AND name = N'IX_Translation_FormName')
DROP INDEX [IX_Translation_FormName] ON [dbo].[Translation]
GO
/****** Object:  Index [IX_RepairDetails_Consecutive]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RepairsDetails]') AND name = N'IX_RepairDetails_Consecutive')
DROP INDEX [IX_RepairDetails_Consecutive] ON [dbo].[RepairsDetails]
GO
/****** Object:  Index [IX_Repair_WorkOrder]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Repairs]') AND name = N'IX_Repair_WorkOrder')
DROP INDEX [IX_Repair_WorkOrder] ON [dbo].[Repairs]
GO
/****** Object:  Index [IX_Repair_Consecutive]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Repairs]') AND name = N'IX_Repair_Consecutive')
DROP INDEX [IX_Repair_Consecutive] ON [dbo].[Repairs]
GO
/****** Object:  Index [IX_Locations_SubLocation]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Locations]') AND name = N'IX_Locations_SubLocation')
DROP INDEX [IX_Locations_SubLocation] ON [dbo].[Locations]
GO
/****** Object:  Index [IX_Locations_Location_Prefix]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Locations]') AND name = N'IX_Locations_Location_Prefix')
DROP INDEX [IX_Locations_Location_Prefix] ON [dbo].[Locations]
GO
/****** Object:  Index [IX_JobCodes_Category]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[JobCodes]') AND name = N'IX_JobCodes_Category')
DROP INDEX [IX_JobCodes_Category] ON [dbo].[JobCodes]
GO
/****** Object:  Index [IX_Accounts_Account]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Customers]') AND name = N'IX_Accounts_Account')
DROP INDEX [IX_Accounts_Account] ON [dbo].[Customers]
GO
/****** Object:  Index [IX_CodeRelations_Type]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND name = N'IX_CodeRelations_Type')
DROP INDEX [IX_CodeRelations_Type] ON [dbo].[CodeRelations]
GO
/****** Object:  Index [IX_CodeRelations_Parent]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND name = N'IX_CodeRelations_Parent')
DROP INDEX [IX_CodeRelations_Parent] ON [dbo].[CodeRelations]
GO
/****** Object:  Index [IX_CodeRelations_Location]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND name = N'IX_CodeRelations_Location')
DROP INDEX [IX_CodeRelations_Location] ON [dbo].[CodeRelations]
GO
/****** Object:  Index [IX_CodeRelations_Child]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND name = N'IX_CodeRelations_Child')
DROP INDEX [IX_CodeRelations_Child] ON [dbo].[CodeRelations]
GO
/****** Object:  Index [IX_CodeRelations_Category]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND name = N'IX_CodeRelations_Category')
DROP INDEX [IX_CodeRelations_Category] ON [dbo].[CodeRelations]
GO
/****** Object:  View [dbo].[View_Locations]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_Locations]'))
DROP VIEW [dbo].[View_Locations]
GO
/****** Object:  View [dbo].[View_JobCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_JobCodes]'))
DROP VIEW [dbo].[View_JobCodes]
GO
/****** Object:  View [dbo].[View_CustomerByLocation]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_CustomerByLocation]'))
DROP VIEW [dbo].[View_CustomerByLocation]
GO
/****** Object:  View [dbo].[View_CodeRelations]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_CodeRelations]'))
DROP VIEW [dbo].[View_CodeRelations]
GO
/****** Object:  Table [dbo].[Translation]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Translation]') AND type in (N'U'))
DROP TABLE [dbo].[Translation]
GO
/****** Object:  Table [dbo].[SubCategories]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SubCategories]') AND type in (N'U'))
DROP TABLE [dbo].[SubCategories]
GO
/****** Object:  Table [dbo].[RepairsPictures]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RepairsPictures]') AND type in (N'U'))
DROP TABLE [dbo].[RepairsPictures]
GO
/****** Object:  Table [dbo].[RepairsDetails]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RepairsDetails]') AND type in (N'U'))
DROP TABLE [dbo].[RepairsDetails]
GO
/****** Object:  Table [dbo].[Repairs]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Repairs]') AND type in (N'U'))
DROP TABLE [dbo].[Repairs]
GO
/****** Object:  Table [dbo].[RepairCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RepairCodes]') AND type in (N'U'))
DROP TABLE [dbo].[RepairCodes]
GO
/****** Object:  Table [dbo].[Positions]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Positions]') AND type in (N'U'))
DROP TABLE [dbo].[Positions]
GO
/****** Object:  Table [dbo].[Mech]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Mech]') AND type in (N'U'))
DROP TABLE [dbo].[Mech]
GO
/****** Object:  Table [dbo].[Locations]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Locations]') AND type in (N'U'))
DROP TABLE [dbo].[Locations]
GO
/****** Object:  Table [dbo].[JobCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[JobCodes]') AND type in (N'U'))
DROP TABLE [dbo].[JobCodes]
GO
/****** Object:  Table [dbo].[EquipmentSize]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EquipmentSize]') AND type in (N'U'))
DROP TABLE [dbo].[EquipmentSize]
GO
/****** Object:  Table [dbo].[Depots]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Depots]') AND type in (N'U'))
DROP TABLE [dbo].[Depots]
GO
/****** Object:  Table [dbo].[DamageCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DamageCodes]') AND type in (N'U'))
DROP TABLE [dbo].[DamageCodes]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Customers]') AND type in (N'U'))
DROP TABLE [dbo].[Customers]
GO
/****** Object:  Table [dbo].[CodeRelations]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND type in (N'U'))
DROP TABLE [dbo].[CodeRelations]
GO
/****** Object:  Table [dbo].[ApprovalValues]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ApprovalValues]') AND type in (N'U'))
DROP TABLE [dbo].[ApprovalValues]
GO
/****** Object:  UserDefinedFunction [dbo].[STRTRAN]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STRTRAN]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[STRTRAN]
GO
/****** Object:  UserDefinedFunction [dbo].[STRFILTER]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STRFILTER]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[STRFILTER]
GO
/****** Object:  UserDefinedFunction [dbo].[ROMANTOARAB]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ROMANTOARAB]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ROMANTOARAB]
GO
/****** Object:  UserDefinedFunction [dbo].[RCHARINDEX]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RCHARINDEX]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RCHARINDEX]
GO
/****** Object:  UserDefinedFunction [dbo].[RATC]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RATC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RATC]
GO
/****** Object:  UserDefinedFunction [dbo].[RAT]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RAT]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RAT]
GO
/****** Object:  UserDefinedFunction [dbo].[PROPER]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PROPER]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[PROPER]
GO
/****** Object:  UserDefinedFunction [dbo].[PADR]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PADR]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[PADR]
GO
/****** Object:  UserDefinedFunction [dbo].[PADL]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PADL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[PADL]
GO
/****** Object:  UserDefinedFunction [dbo].[PADC]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PADC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[PADC]
GO
/****** Object:  UserDefinedFunction [dbo].[OCCURS2]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OCCURS2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[OCCURS2]
GO
/****** Object:  UserDefinedFunction [dbo].[OCCURS]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OCCURS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[OCCURS]
GO
/****** Object:  UserDefinedFunction [dbo].[GETWORDNUM]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GETWORDNUM]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[GETWORDNUM]
GO
/****** Object:  UserDefinedFunction [dbo].[GETWORDCOUNT]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GETWORDCOUNT]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[GETWORDCOUNT]
GO
/****** Object:  UserDefinedFunction [dbo].[GETALLWORDS2]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GETALLWORDS2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[GETALLWORDS2]
GO
/****** Object:  UserDefinedFunction [dbo].[GETALLWORDS]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GETALLWORDS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[GETALLWORDS]
GO
/****** Object:  UserDefinedFunction [dbo].[CHRTRAN]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHRTRAN]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[CHRTRAN]
GO
/****** Object:  UserDefinedFunction [dbo].[CHARINDEX_CI]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHARINDEX_CI]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[CHARINDEX_CI]
GO
/****** Object:  UserDefinedFunction [dbo].[CHARINDEX_BIN]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHARINDEX_BIN]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[CHARINDEX_BIN]
GO
/****** Object:  UserDefinedFunction [dbo].[ATC2]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ATC2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ATC2]
GO
/****** Object:  UserDefinedFunction [dbo].[ATC]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ATC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ATC]
GO
/****** Object:  UserDefinedFunction [dbo].[AT2]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AT2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[AT2]
GO
/****** Object:  UserDefinedFunction [dbo].[AT]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AT]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[AT]
GO
/****** Object:  UserDefinedFunction [dbo].[ARMENIANTOARAB]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ARMENIANTOARAB]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ARMENIANTOARAB]
GO
/****** Object:  UserDefinedFunction [dbo].[ARABTOROMAN]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ARABTOROMAN]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ARABTOROMAN]
GO
/****** Object:  UserDefinedFunction [dbo].[ARABTOARMENIAN]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ARABTOARMENIAN]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ARABTOARMENIAN]
GO
/****** Object:  UserDefinedFunction [dbo].[ADDROMANNUMBERS]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ADDROMANNUMBERS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ADDROMANNUMBERS]
GO
/****** Object:  StoredProcedure [dbo].[USP_Synchronize_RepairCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Synchronize_RepairCodes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_Synchronize_RepairCodes]
GO
/****** Object:  StoredProcedure [dbo].[USP_Synchronize_JobCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Synchronize_JobCodes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_Synchronize_JobCodes]
GO
/****** Object:  StoredProcedure [dbo].[USP_Synchronize_DamageCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Synchronize_DamageCodes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_Synchronize_DamageCodes]
GO
/****** Object:  StoredProcedure [dbo].[USP_Synchronize_Codes]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Synchronize_Codes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_Synchronize_Codes]
GO
/****** Object:  StoredProcedure [dbo].[USP_SubmitRepair]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_SubmitRepair]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_SubmitRepair]
GO
/****** Object:  StoredProcedure [dbo].[USP_ShrinkLogFile]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_ShrinkLogFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_ShrinkLogFile]
GO
/****** Object:  StoredProcedure [dbo].[USP_SaveBIDItemCompletion]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_SaveBIDItemCompletion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_SaveBIDItemCompletion]
GO
/****** Object:  StoredProcedure [dbo].[USP_RepairsPictures]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_RepairsPictures]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_RepairsPictures]
GO
/****** Object:  StoredProcedure [dbo].[USP_RepairsList]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_RepairsList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_RepairsList]
GO
/****** Object:  StoredProcedure [dbo].[USP_RepairsDetails]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_RepairsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_RepairsDetails]
GO
/****** Object:  StoredProcedure [dbo].[USP_Repairs]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Repairs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_Repairs]
GO
/****** Object:  StoredProcedure [dbo].[USP_LoadJobCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_LoadJobCodes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_LoadJobCodes]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindRepairCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_FindRepairCodes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_FindRepairCodes]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindNextConsecutive]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_FindNextConsecutive]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_FindNextConsecutive]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindDamageCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_FindDamageCodes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_FindDamageCodes]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindAssignedBIDs]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_FindAssignedBIDs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_FindAssignedBIDs]
GO
/****** Object:  StoredProcedure [dbo].[USP_DeleteRepair]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_DeleteRepair]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_DeleteRepair]
GO
/****** Object:  StoredProcedure [dbo].[USP_CodeRelations]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_CodeRelations]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_CodeRelations]
GO
/****** Object:  StoredProcedure [dbo].[USP_ClearEntryTables]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_ClearEntryTables]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_ClearEntryTables]
GO
/****** Object:  User [MobileUser]    Script Date: 08/07/2012 10:56:22 AM ******/
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'MobileUser')
DROP USER [MobileUser]
GO

USE [MobileEstimates]
GO
/****** Object:  User [MobileUser]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'MobileUser')
CREATE USER [MobileUser] FOR LOGIN [MobileUser] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [MobileUser]
GO

/****** Object:  StoredProcedure [dbo].[USP_ClearEntryTables]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_ClearEntryTables]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[USP_ClearEntryTables]
AS
TRUNCATE TABLE Repairs
TRUNCATE TABLE RepairsDetails
TRUNCATE TABLE RepairsPictures
' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_CodeRelations]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_CodeRelations]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
EXECUTE USP_CodeRelations
*/
CREATE PROCEDURE [dbo].[USP_CodeRelations]
AS
SELECT	CD1.Category
		,CD1.SubCategory
		,CD1.ParentCode AS Main
		,CD1.ChildCode AS SubMain
		,SubSubMain = (SELECT MIN(CD2.ChildCode) FROM View_CodeRelations CD2 WHERE CD2.Category = CD1.Category AND CD2.SubCategory = CD1.SubCategory AND CD2.ParentCode = CD1.ChildCode AND CD2.RelationType = ''RC'')
		,CD1.ParentCode
		,CD1.ParentDescription
		,CD1.ChildCode
		,CD1.ChildDescription
		,CD1.Sort
		,RTRIM(CD1.Category) + ''-'' + RTRIM(CD1.SubCategory) + ''-'' + RTRIM(CD1.ParentCode) + ''-'' + RTRIM(CD1.ChildCode) AS GroupField
FROM	View_CodeRelations CD1
WHERE	CD1.RelationType = ''JC''
UNION
SELECT	CD1.Category
		,CD1.SubCategory
		,CD2.ParentCode AS Main
		,CD2.ChildCode AS SubMain
		,CD1.ChildCode AS SubSubMain
		,CD1.ParentCode
		,CD1.ParentDescription
		,CD1.ChildCode
		,CD1.ChildDescription
		,CD1.Sort
		,RTRIM(CD1.Category) + ''-'' + RTRIM(CD1.SubCategory) + ''-'' + RTRIM(CD2.ParentCode) + ''-'' + RTRIM(CD2.ChildCode) AS GroupField
FROM	View_CodeRelations CD1
		INNER JOIN View_CodeRelations CD2 ON CD1.ParentCode = CD2.ChildCode AND CD1.Category = CD2.Category AND CD1.SubCategory = CD2.SubCategory AND CD2.RelationType = ''JC''
WHERE	CD1.RelationType = ''RC''
UNION
SELECT	CD1.Category
		,CD1.SubCategory
		,CD3.ParentCode AS Main
		,CD3.ChildCode AS SubMain
		,CD2.ChildCode AS SubSubMain
		,CD1.ParentCode
		,CD1.ParentDescription
		,CD1.ChildCode
		,CD1.ChildDescription
		,CD1.Sort
		,RTRIM(CD1.Category) + ''-'' + RTRIM(CD1.SubCategory) + ''-'' + RTRIM(CD3.ParentCode) + ''-'' + RTRIM(CD3.ChildCode) AS GroupField
FROM	View_CodeRelations CD1
		INNER JOIN View_CodeRelations CD2 ON CD1.ParentCode = CD2.ChildCode AND CD1.Category = CD2.Category AND CD1.SubCategory = CD2.SubCategory AND CD2.RelationType = ''RC''
		INNER JOIN View_CodeRelations CD3 ON CD2.ParentCode = CD3.ChildCode AND CD2.Category = CD3.Category AND CD2.SubCategory = CD3.SubCategory AND CD3.RelationType = ''JC''
WHERE	CD1.RelationType = ''DC''
ORDER BY 11,5,10' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_DeleteRepair]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_DeleteRepair]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
EXECUTE USP_DeleteRepair 5
*/
CREATE PROCEDURE [dbo].[USP_DeleteRepair] (@Consecutive Int)
AS
DELETE Repairs WHERE Consecutive = @Consecutive
DELETE RepairsDetails WHERE Consecutive = @Consecutive
DELETE RepairsPictures WHERE Consecutive = @Consecutive
' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_FindAssignedBIDs]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_FindAssignedBIDs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
******************************************
Search and download Server Assigned BIDs 
to the local database
******************************************
EXECUTE USP_FindAssignedBIDs ''91''

EXECUTE USP_ClearEntryTables
******************************************
*/
CREATE PROCEDURE [dbo].[USP_FindAssignedBIDs] (@Mechanic Varchar(10))
AS
DECLARE	@SERVERONLINE	Bit,
		@ReturnValue	Int = 0,
		@RepairId		Int = 0,
		@Consecutive	Int = 0

BEGIN TRY
     SELECT @SERVERONLINE = ServerRunning 
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
	WHERE	BIDStatus = 4
			AND BIDMechanic = @Mechanic
	
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
						@EstimateDate,
						@RepairDate,
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
						AND PartNumber <> ''''

			UPDATE ILSINT02.FI_Data.dbo.Repairs SET BIDStatus = 5 WHERE WorkOrder = @WorkOrder

			FETCH FROM AssignedRepairs INTO @RepairId
		END

		CLOSE AssignedRepairs
		DEALLOCATE AssignedRepairs
	END

	DROP TABLE #tmpRepairs
END

RETURN @ReturnValue' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_FindDamageCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_FindDamageCodes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
EXECUTE USP_FindDamageCodes ''TIRES''
*/
CREATE PROCEDURE [dbo].[USP_FindDamageCodes] (@Category Varchar(40) = NULL)
AS
IF @Category = '''' OR @Category IS NULL
BEGIN
	SELECT	DamageCode
			,RTRIM(Description) + ''  ['' + RTRIM(DamageCode) + '']'' AS Description
	FROM	DamageCodes 
	WHERE	Category IS Null
	ORDER BY Description
END
ELSE
BEGIN
	SELECT	DamageCode
			,RTRIM(Description) + ''  ['' + RTRIM(DamageCode) + '']'' AS Description
	INTO	#tmpDamageCodes
	FROM	DamageCodes 
	WHERE	Category = @Category 
	ORDER BY Description
	
	IF @@ROWCOUNT = 0
	BEGIN
		SELECT	DamageCode
				,RTRIM(Description) + ''  ['' + RTRIM(DamageCode) + '']'' AS Description
		FROM	DamageCodes 
		WHERE	Category IS Null
		ORDER BY Description
	END
	ELSE
	BEGIN
		SELECT	*
		FROM	#tmpDamageCodes
	END
	
	DROP TABLE #tmpDamageCodes
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_FindNextConsecutive]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_FindNextConsecutive]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
EXECUTE USP_FindNextConsecutive ''HH003'', 1
*/
CREATE PROCEDURE [dbo].[USP_FindNextConsecutive] 
		@Tablet		Varchar(10) = Null,
		@OnServer	Bit = 0
AS
DECLARE	@NextId		Int,
		@Records	Int = 0

IF @Tablet IS Null
BEGIN
	IF PATINDEX(''%HH%'', @@SERVERNAME) = 0
	BEGIN
		SET @Tablet = ''HH099''
	END
	ELSE
	BEGIN
		SET @Tablet = RTRIM(UPPER(@@SERVERNAME))
	END
END

IF @OnServer = 0 OR @OnServer IS Null
	SELECT @Records = ISNULL(COUNT(*), 0) FROM Repairs

IF @Records = 0
BEGIN
	BEGIN TRY
		-- ***** CHECK IF THE SERVER IS ONLINE ***
		SELECT	@NextId = ISNULL(CAST(MAX(RIGHT(Workorder, 5)) + 1 AS Int), 1)
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
' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_FindRepairCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_FindRepairCodes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
EXECUTE USP_FindRepairCodes ''TIRES''
*/
CREATE PROCEDURE [dbo].[USP_FindRepairCodes] (@Category Varchar(40) = NULL)
AS
IF @Category = '''' OR @Category IS NULL
BEGIN
	SELECT	RepairCode
			,RTRIM(Description) + ''  ['' + RTRIM(RepairCode) + '']'' AS Description
	FROM	RepairCodes 
	WHERE	Category IS Null
	ORDER BY Description
END
ELSE
BEGIN
	SELECT	RepairCode
			,RTRIM(Description) + ''  ['' + RTRIM(RepairCode) + '']'' AS Description
	INTO	#tmpRepairCode
	FROM	RepairCodes 
	WHERE	Category = @Category 
	ORDER BY Description
	
	IF @@ROWCOUNT = 0
	BEGIN
		SELECT	RepairCode
				,RTRIM(Description) + ''  ['' + RTRIM(RepairCode) + '']'' AS Description
		FROM	RepairCodes 
		WHERE	Category IS Null
		ORDER BY Description
	END
	ELSE
	BEGIN
		SELECT	*
		FROM	#tmpRepairCode
	END
	
	DROP TABLE #tmpRepairCode
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_LoadJobCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_LoadJobCodes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
EXECUTE USP_LoadJobCodes ''TIRES'', ''REPLACE''
*/
CREATE PROCEDURE [dbo].[USP_LoadJobCodes]
		@Category		Varchar(20),
		@SubCategory	Varchar(25)
AS
SELECT	DISTINCT ChildCode, 
		RTRIM(ChildCode) + '' - '' + RTRIM(ChildDescription) AS ChildDescription 
FROM	View_CodeRelations 
WHERE	RelationType = ''JC'' 
		AND Category = @Category
		AND SubCategory = @SubCategory
		AND ChildCode IN (
						SELECT	ParentCode 
						FROM	View_CodeRelations
						WHERE	RelationType = ''RC'' 
								AND Category = @Category
								AND SubCategory = @SubCategory
						)
ORDER BY 2' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_Repairs]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Repairs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[USP_Repairs]
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
		@ChassisInspection	Bit,
		@ForSubmitting		Bit = 0,
		@Container			Varchar(15) = Null,
		@ContainerMounted	Bit = Null,
		@Lot_Road			Varchar(15),
		@FMCSA				Date = Null,
		@BIDStatus			Smallint = 0,
		@TestRecord			Bit = 0
AS
BEGIN TRANSACTION

IF @RepairDate IS Null OR @RepairDate < ''01/01/1980''
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
			TestRecord			= @TestRecord
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
			,BIDStatus)
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
			,@BIDStatus)
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
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_RepairsDetails]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_RepairsDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[USP_RepairsDetails]
		@Consecutive			int,
		@LineItem				int,
		@PartNumber				varchar(25),
		@PartDescription		varchar(40),
		@LocationCode			varchar(20),
		@DamageCode				varchar(10),
		@RepairCode				varchar(10),
		@DamageWidth			numeric(10,2),
		@DamageLenght			numeric(10,2),
		@EquipmentType			char(1),
		@ResponsibleParty		char(1),
		@Quantity				numeric(10,2),
		@RepairedComponent		varchar(25),
		@DOTIn					varchar(15) = Null,
		@DOTOut					varchar(15) = Null,
		@SubCategory			varchar(30),
		@RecapperOn				Varchar(15) = Null,
		@RecapperOff			Varchar(15) = Null,
		@Position				Varchar(5) = Null,
		@ItemCost				Numeric(10,2) = 0,
		@BIDItemCompleted		Bit = 0
AS
DECLARE	@RepairDetailsId		Int
SET		@RepairDetailsId		= (SELECT RepairDetailsId FROM RepairsDetails WHERE Consecutive = @Consecutive AND LineItem = @LineItem)

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
		,RepairedComponent
		,DOTIn
		,DOTOut
		,SubCategory
		,RecapperOff
		,RecapperOn
		,Position
		,ItemCost)
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
		,@RepairedComponent
		,@DOTIn
		,@DOTOut
		,@SubCategory
		,@RecapperOff
		,@RecapperOn
		,@Position
		,@ItemCost)
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
			RepairedComponent	= @RepairedComponent,
			DOTIn				= @DOTIn,
			DOTOut				= @DOTOut,
			SubCategory			= @SubCategory,
			RecapperOff			= @RecapperOff,
			RecapperOn			= @RecapperOn,
			Position			= @Position,
			ItemCost			= @ItemCost,
			BIDItemCompleted	= @BIDItemCompleted
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
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_RepairsList]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_RepairsList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
EXECUTE USP_RepairsList
*/
CREATE PROCEDURE [dbo].[USP_RepairsList] (@Testing Bit = 0)
AS
SELECT	Consecutive
		,EstimateDate AS RepairDate
		,EquipmentLocation
		,SubLocation
		,Equipment
		,CASE EquipmentType WHEN ''R'' THEN ''CHS'' WHEN ''C'' THEN ''CON'' ELSE ''GEN'' END AS EquipmentType
		,ForSubmitting
		,CAST(CASE WHEN Fk_SubmittedId IS NULL THEN 0 ELSE 1 END AS Bit) AS Submitted
		,0 AS Sort
		,BIDStatus
FROM	Repairs
WHERE	(Fk_SubmittedId IS NULL OR (BIDStatus > 2 AND Fk_SubmittedId IS NULL))
		AND TestRecord = @Testing
UNION
SELECT	Consecutive
		,EstimateDate AS RepairDate
		,EquipmentLocation
		,SubLocation
		,Equipment
		,CASE EquipmentType WHEN ''R'' THEN ''CHS'' WHEN ''C'' THEN ''CON'' ELSE ''GEN'' END AS EquipmentType
		,ForSubmitting
		,CAST(CASE WHEN Fk_SubmittedId IS NULL THEN 0 ELSE 1 END AS Bit) AS Submitted
		,1 AS Sort
		,BIDStatus
FROM	Repairs
WHERE	Fk_SubmittedId IS NOT NULL
		AND SubmittedOn >= CAST(SubmittedOn AS Date)
		AND TestRecord = @Testing
ORDER BY 9, Consecutive DESC' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_RepairsPictures]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_RepairsPictures]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[USP_RepairsPictures]
		@Consecutive		Int,
		@PictureFileName	varchar(50)
AS
INSERT INTO RepairsPictures
           (Consecutive
           ,PictureFileName)
VALUES
           (@Consecutive
           ,@PictureFileName)
' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_SaveBIDItemCompletion]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_SaveBIDItemCompletion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[USP_SaveBIDItemCompletion]
		@Consecutive			int,
		@LineItem				int,
		@BIDItemCompleted		Bit
AS
DECLARE	@RepairDetailsId		Int
SET		@RepairDetailsId		= (SELECT RepairDetailsId FROM RepairsDetails WHERE Consecutive = @Consecutive AND LineItem = @LineItem)

BEGIN TRANSACTION

BEGIN
	UPDATE	RepairsDetails
	SET		BIDItemCompleted	= @BIDItemCompleted
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
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_ShrinkLogFile]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_ShrinkLogFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
EXECUTE USP_ShrinkLogFile
*/
CREATE PROCEDURE [dbo].[USP_ShrinkLogFile]
AS
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE MobileEstimates
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE MobileEstimates
SET RECOVERY FULL;

' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_SubmitRepair]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_SubmitRepair]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
EXECUTE USP_SubmitRepair 5, ''''
*/
CREATE PROCEDURE [dbo].[USP_SubmitRepair] (@Consecutive Int, @ErrorMessage Varchar(1000) OUTPUT)
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
		@SrvConsecutive		Int = Null

-- ***** CHECK IF THE SERVER IS ONLINE ***
SET		@Tablet	= (SELECT UPPER(HOST_NAME()) AS Computer_Name)

IF LEFT(@Tablet, 2) <> ''HH''
	SET @Tablet = ''HH999''

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
	SET @ErrorMessage = ''Central Server Is Unavailable''
END
ELSE
BEGIN
	-- ***** IF SERVER ONLINE SUBMIT INFORMATION *****
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
		FROM	Repairs
		WHERE	Consecutive			= @Consecutive

		IF @SrvConsecutive IS NOT Null AND @SrvConsecutive > @Consecutive
		BEGIN
			SET @WorkOrder = RTRIM(@Tablet) + ''-'' + dbo.PADL(@SrvConsecutive, 5, ''0'')
		END
		
		PRINT ''REPAIRS TABLE''
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

		IF @@ERROR > 0
			PRINT ERROR_MESSAGE()

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
				PRINT ''REPAIRS DETAILS TABLE. ITEM # '' + CAST(@LineItem AS Varchar)

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
					PRINT ERROR_MESSAGE()
				
				FETCH FROM RepDetails INTO	@RepairDetailsId, @LineItem, @PartNumber, @PartDescription, @LocationCode, @DamageCode, @RepairCode, @DamageWidth,
											@DamageLenght, @ResponsibleParty, @Quantity, @RepairedComponent, @DOTIn, @DOTOut, @RecapperOn, @RecapperOff, @Position,
											@ItemCost, @ActualCost, @BIDItemCompleted, @SubCategory
			END
			
			CLOSE RepDetails
			DEALLOCATE RepDetails
			
			-- ***** REPAIR PICTURES SUBMIT *****
			IF @BIDStatus < 4
			BEGIN
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
					PRINT ''REPAIRS PICTURES TABLE. PICTURE # '' + CAST(@RepairsPictureId AS Varchar)

					EXECUTE ILSINT02.FI_Data.dbo.USP_RepairsPictures @ServerRepairId, @RepairsPictureId, @PictureFileName

					IF @@ERROR > 0
						PRINT ERROR_MESSAGE()
				
					FETCH FROM RepPictures INTO @RepairsPictureId, @PictureFileName
				END
			
				CLOSE RepPictures
				DEALLOCATE RepPictures
			END
		END
	END TRY
	BEGIN CATCH
		
	END CATCH
END

IF @@ERROR > 0
BEGIN
	ROLLBACK TRANSACTION
	SET @ExecutionError = -1
	SET @ErrorMessage = ERROR_MESSAGE()
END
ELSE
BEGIN
	UPDATE	Repairs 
	SET		Fk_SubmittedId	= @ServerRepairId, 
			SubmittedOn		= @ServerDateTime,
			Consecutive		= CASE WHEN @SrvConsecutive IS NOT Null AND @SrvConsecutive > @Consecutive THEN @SrvConsecutive ELSE @Consecutive END
	WHERE	Consecutive		= @Consecutive

	IF @SrvConsecutive IS NOT Null
	BEGIN
		UPDATE	RepairsDetails
		SET		Consecutive = @SrvConsecutive
		WHERE	Consecutive = @Consecutive

		UPDATE	RepairsPictures
		SET		Consecutive = @SrvConsecutive
		WHERE	Consecutive = @Consecutive
	END
			
	COMMIT TRANSACTION
	SET @ExecutionError = 0
	SET @ErrorMessage = ''''
END

EXECUTE USP_ShrinkLogFile

--PRINT @ExecutionError
--PRINT @ErrorMessage
--PRINT @BIDStatus

RETURN @ExecutionError' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_Synchronize_DamageCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Synchronize_DamageCodes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
******************************************
Synchronize Server Damage Codes with the 
local database
******************************************
EXECUTE USP_Synchronize_DamageCodes
******************************************
*/
CREATE PROCEDURE [dbo].[USP_Synchronize_DamageCodes]
AS
DECLARE	@SERVERONLINE Bit

BEGIN TRY
     SELECT @SERVERONLINE = ServerRunning 
     FROM	ILSINT02.FI_Data.dbo.ServerRunning
END TRY
BEGIN CATCH
     SET @SERVERONLINE = 0
END CATCH

IF @SERVERONLINE = 1
BEGIN
	SELECT	DamageCode
			,Description
			,Category
	INTO	#tmpRecords
	FROM	ILSINT02.FI_Data.dbo.DamageCodes
	
	INSERT INTO DamageCodes
	SELECT	DamageCode
			,Description
			,Category
	FROM	#tmpRecords
	WHERE	DamageCode NOT IN (SELECT DamageCode FROM DamageCodes)

	UPDATE	DamageCodes
	SET		DamageCodes.Description = RTRIM(REM.Description),
			DamageCodes.Category = RTRIM(REM.Category)
	FROM	(
			SELECT	REM.DamageCode
					,REM.Description
					,REM.Category
			FROM	#tmpRecords REM
					INNER JOIN DamageCodes LOC ON REM.DamageCode = LOC.DamageCode
			WHERE	REM.Description <> LOC.Description
					OR REM.Category <> LOC.Category
			) REM
	WHERE	DamageCodes.DamageCode = REM.DamageCode
	
	DROP TABLE #tmpRecords
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_Synchronize_JobCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Synchronize_JobCodes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
******************************************
Synchronize Server Job Codes with the 
local database
******************************************
EXECUTE USP_Synchronize_JobCodes
******************************************
*/
CREATE PROCEDURE [dbo].[USP_Synchronize_JobCodes]
AS
DECLARE	@SERVERONLINE Bit

BEGIN TRY
     SELECT @SERVERONLINE = ServerRunning 
     FROM	ILSINT02.FI_Data.dbo.ServerRunning
END TRY
BEGIN CATCH
     SET @SERVERONLINE = 0
END CATCH

IF @SERVERONLINE = 1
BEGIN
	SELECT	JobCode,
			Description,
			Category,
			Cost
	INTO	#tmpRecords
	FROM	ILSINT02.FI_Data.dbo.JobCodes
	
	INSERT INTO JobCodes
	SELECT	SRV.JobCode,
			SRV.Description,
			SRV.Category,
			SRV.Cost
	FROM	#tmpRecords SRV
	WHERE	SRV.JobCode NOT IN (SELECT JobCode FROM JobCodes)
	
	UPDATE	JobCodes
	SET		JobCodes.Description = SRV.Description,
			JobCodes.Category = SRV.Category,
			JobCodes.Cost = SRV.Cost
	FROM	(
			SELECT	SRV.JobCode,
					SRV.Description,
					SRV.Category,
					SRV.Cost
			FROM	#tmpRecords SRV
					INNER JOIN JobCodes LOC ON SRV.JobCode = LOC.JobCode
			WHERE	SRV.JobCode <> LOC.JobCode
					OR SRV.Description <> LOC.Description
					OR SRV.Cost <> LOC.Cost
			) SRV
	WHERE	JobCodes.JobCode = SRV.JobCode
	
	DROP TABLE #tmpRecords
END' 
END
GO
/****** Object:  StoredProcedure [dbo].[USP_Synchronize_RepairCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Synchronize_RepairCodes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
******************************************
Synchronize Server RepairCodes Codes with the 
local database
******************************************
EXECUTE USP_Synchronize_RepairCodes
******************************************
*/
CREATE PROCEDURE [dbo].[USP_Synchronize_RepairCodes]
AS
DECLARE	@SERVERONLINE Bit

BEGIN TRY
     SELECT @SERVERONLINE = ServerRunning 
     FROM	ILSINT02.FI_Data.dbo.ServerRunning
END TRY
BEGIN CATCH
     SET @SERVERONLINE = 0
END CATCH

IF @SERVERONLINE = 1
BEGIN
	SELECT	RepairCode
			,Description
			,Category
	INTO	#tmpRecords
	FROM	ILSINT02.FI_Data.dbo.RepairCodes
	
	INSERT INTO RepairCodes
	SELECT	RepairCode
			,Description
			,Category
	FROM	#tmpRecords
	WHERE	RepairCode NOT IN (SELECT RepairCode FROM RepairCodes)

	UPDATE	RepairCodes
	SET		RepairCodes.Description = RTRIM(REM.Description),
			RepairCodes.Category = RTRIM(REM.Category)
	FROM	(
			SELECT	REM.RepairCode
					,REM.Description
					,REM.Category
			FROM	#tmpRecords REM
					INNER JOIN RepairCodes LOC ON REM.RepairCode = LOC.RepairCode
			WHERE	REM.Description <> LOC.Description
					OR REM.Category <> LOC.Category
			) REM
	WHERE	RepairCodes.RepairCode = REM.RepairCode
	
	DROP TABLE #tmpRecords
END' 
END
GO
/****** Object:  UserDefinedFunction [dbo].[ADDROMANNUMBERS]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ADDROMANNUMBERS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- ADDROMANNUMBERS() User-Defined Function is written just FYA
-- Returns the result of addition, subtraction, multiplication or division of two Roman numbers  
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com ,  25 April 2005 or XXV April MMV :-)
-- ADDROMANNUMBERS(@tcRomanNumber1, @tcRomanNumber2, @tcOperator) Return Values varchar(75)
-- Parameters @tcRomanNumber1 varchar(15) Roman number
-- @tcRomanNumber2 varchar(15) Roman number, @tcOperator char(1) operator
-- Example
-- select dbo.ADDROMANNUMBERS(''I'',''I'',default)                       -- Displays II
-- select dbo.ADDROMANNUMBERS(''MMMDCCCLXXXVIII'',''MDCCCLXXXVIII'',''-'') -- Displays MM
-- select dbo.ADDROMANNUMBERS(''DCCCLXXXVIII'',''VIII'',default)         -- Displays DCCCXCVI
-- select dbo.ADDROMANNUMBERS(''DCCCLXXXVIII'',''VIII'',''*'')             -- Displays Out of range, must be between 1 and 3999
-- select dbo.ADDROMANNUMBERS(''MMMDCCCLXXXVIII'',''II'',''/'')            -- Displays MCMXLIV
-- See also ROMANTOARAB(), ARABTOROMAN()  
CREATE function [dbo].[ADDROMANNUMBERS](@tcRomanNumber1 varchar(15), @tcRomanNumber2 varchar(15), @tcOperator char(1)=''+'' )
returns varchar(75)
   begin
      declare @lcResult varchar(75)
      if @tcOperator in (''+'',''-'',''*'',''/'')
        begin
          declare @lnN1 int, @lnN2 int
          select @lnN1 = dbo.ROMANTOARAB(@tcRomanNumber1),  @lnN2 = dbo.ROMANTOARAB(@tcRomanNumber2)
          if @lnN1 < 0
            set @lcResult = ''Wrong first roman number''
          else 
            if @lnN2 < 0
              set @lcResult = ''Wrong second roman number''
            else   
              begin
                select @lcResult = 
                case @tcOperator 
                  when ''+'' then dbo.ARABTOROMAN(@lnN1 + @lnN2)
                  when ''-'' then dbo.ARABTOROMAN(@lnN1 - @lnN2)
                  when ''*'' then dbo.ARABTOROMAN(@lnN1 * @lnN2)
                  when ''/'' then dbo.ARABTOROMAN(@lnN1 / @lnN2)
                end                
              end
        end
      else 
        set @lcResult = ''Wrong third parameter, must be +,-,*,/''
         
    return @lcResult
  end

' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[ARABTOARMENIAN]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ARABTOARMENIAN]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- ARABTOARMENIAN() Returns the unicode character Armenian numeral equivalent of a specified numeric expression (from 1 to 9999) 
-- see http://en.wikipedia.org/wiki/Armenian_numerals
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com ,  15 October 2006
-- ARABTOARMENIAN(@tNum) Return Values nvarchar(75) Parameters @tNum  number
-- Example
-- select dbo.ARABTOARMENIAN(3888)   -- Displays ՎՊՁԸ
-- select dbo.ARABTOARMENIAN(''1888'') -- Displays ՌՊՁԸ
-- select dbo.ARABTOARMENIAN(1)        -- Displays Ա
-- select dbo.ARABTOARMENIAN(234)    -- Displays ՄԼԴ
-- See also ARMENIANTOARAB()  
CREATE function [dbo].[ARABTOARMENIAN](@tNum sql_variant)
returns nvarchar(75)
as
   begin
      declare @type char(1), @lResult nvarchar(75), @lnNum int

      select  @type =  case
         when charindex(''char'', cast(SQL_VARIANT_PROPERTY(@tNum,''BaseType'') as varchar(20)) ) > 0  then ''C''
         when charindex(''int'', cast(SQL_VARIANT_PROPERTY(@tNum,''BaseType'') as varchar(20)) ) > 0   then ''N''
         when cast(SQL_VARIANT_PROPERTY(@tNum,''BaseType'') as varchar(20))  IN (''real'', ''float'', ''numeric'', ''decimal'')  then ''N''
         else ''W''
         end 
 
     if @type = ''W''
        set @lResult = N''Wrong type of parameter, must be Integer, Numeric or Character''
     else
       begin
         set @lnNum = cast(@tNum as int) 
         if @lnNum  between 1 and 9999
            begin    
               declare @lnI tinyint, @tcNum  varchar(4)
               select @tcNum = ltrim(rtrim(cast(@lnNum as varchar(4)))), @lResult = '''', @lnI = 0
               while  @lnI <= len(@tcNum) 
                  begin   
                    select @lnNum = cast(substring(@tcNum, len(@tcNum)-@lnI, 1) as smallint), @lnI = @lnI + 1
                    if  @lnNum > 0
                      select @lResult = @lResult + nchar(unicode(N''Ա'')+ @lnNum - 1+9*(@lnI-1))
                  end
               select @lResult = reverse(@lResult)
            end
         else
           set @lResult = N''Out of range, must be between 1 and 9999''
        end
     return  @lResult
   end

' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[ARABTOROMAN]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ARABTOROMAN]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- ARABTOROMAN() Returns the character Roman numeral equivalent of a specified numeric expression (from 1 to 3999) 
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com ,  25 April 2005 or XXV April MMV :-)
-- ARABTOROMAN(@tNum) Return Values varchar(15) Parameters @tNum  number
-- Example
-- select dbo.ARABTOROMAN(3888)   -- Displays MMMDCCCLXXXVIII
-- select dbo.ARABTOROMAN(''1888'') -- Displays MDCCCLXXXVIII
-- select dbo.ARABTOROMAN(1)      -- Displays I
-- select dbo.ARABTOROMAN(234)    -- Displays CCXXXIV
 -- See also ROMANTOARAB()  
CREATE function [dbo].[ARABTOROMAN](@tNum sql_variant)
returns varchar(75)
as
   begin
      declare @type char(1), @lResult varchar(75), @lnNum int

      select  @type =  case
         when charindex(''char'', cast(SQL_VARIANT_PROPERTY(@tNum,''BaseType'') as varchar(20)) ) > 0  then ''C''
         when charindex(''int'', cast(SQL_VARIANT_PROPERTY(@tNum,''BaseType'') as varchar(20)) ) > 0   then ''N''
         when cast(SQL_VARIANT_PROPERTY(@tNum,''BaseType'') as varchar(20))  IN (''real'', ''float'', ''numeric'', ''decimal'')  then ''N''
         else ''W''
         end 
 
     if @type = ''W''
        set @lResult = ''Wrong type of parameter, must be Integer, Numeric or Character''
     else
       begin
         set @lnNum = cast(@tNum as int) 
         if @lnNum  between 1 and 3999
            begin    
               declare @ROMANNUMERALS char(7), @lnI tinyint, @tcNum  varchar(4)
               select @ROMANNUMERALS = ''IVXLCDM'', @tcNum = ltrim(rtrim(cast(@lnNum as varchar(4)))), @lResult = ''''
               set @lnI = datalength(@tcNum)
               while  @lnI >= 1  
                  begin   
                    set @lnNum = cast(substring(@tcNum, datalength(@tcNum)-@lnI+1, 1) as smallint)
                    select @lResult = @lResult + case 
                       when @lnNum < 4 then replicate(substring(@ROMANNUMERALS, @lnI*2 - 1, 1),@lnNum )
                       when @lnNum = 4 or @lnNum = 9 then substring(@ROMANNUMERALS, @lnI*2 - 1, 1)+substring(@ROMANNUMERALS, @lnI*2 + case when @lnNum = 9 then 1 else 0 end, 1)
                       else substring(@ROMANNUMERALS, @lnI*2, 1)+replicate(substring(@ROMANNUMERALS, @lnI*2 - 1, 1),@lnNum -5)
                   end
                   set @lnI = @lnI - 1
               end
            end
         else
           set @lResult = ''Out of range, must be between 1 and 3999''
        end
     return  @lResult
   end

' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[ARMENIANTOARAB]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ARMENIANTOARAB]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- ARMENIANTOARAB() Returns the number equivalent of a specified character Armenian numeral expression (from Ա to ՔՋՂԹ)
-- see http://en.wikipedia.org/wiki/Armenian_numerals
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com , 15 October 2006 or ԺԵ  October ՍԶ  :-)
-- ARMENIANTOARAB(@tcArmenianNumber) Return Values smallint
-- Parameters @tcArmenianNumber  nvarchar(4) Armenian number  
-- Example
-- select dbo.ARMENIANTOARAB(N''ՎՊՁԸ'') -- Displays 3888
-- select dbo.ARMENIANTOARAB(N''ՌՊՁԸ'') -- Displays 1888
-- select dbo.ARMENIANTOARAB(N''Ա'')    -- Displays 1
-- select dbo.ARMENIANTOARAB(N''ՄԼԴ'')  -- Displays 234
-- See also ARABTOARMENIAN()  
CREATE function [dbo].[ARMENIANTOARAB](@tcArmenianNumber nvarchar(10))
returns smallint
as
   begin
      declare @lnResult smallint, @lcArmenianNumber nvarchar(10), @lcArmenianLetter nchar(1), @lnI tinyint
      select @tcArmenianNumber = ltrim(rtrim(upper(@tcArmenianNumber))), @lcArmenianNumber = N'''', @lnI = 1, @lnResult = 0
   
     while  @lnI <= len(@tcArmenianNumber)
       begin 
         select @lcArmenianLetter = substring(@tcArmenianNumber, @lnI, 1)
         if  @lcArmenianLetter between N''Ա'' and  N''Ք'' 
           set @lcArmenianNumber = @lcArmenianNumber + @lcArmenianLetter
         else
           if  @lcArmenianLetter <> nchar(32)  
             begin
               set @lnResult = -1
               break
             end
         set @lnI =  @lnI + 1
       end
    
     if @lnResult >  -1
       begin
         select  @lnI = 1
         while  @lnI <= len(@lcArmenianNumber) and @lnResult > - 1
            begin
              select @lcArmenianLetter = substring(@lcArmenianNumber, @lnI, 1), @lnI = @lnI + 1
                if @lcArmenianLetter >= N''Ռ'' and @lnResult = 0  -- 1000
                   select @lnResult = @lnResult + 1000*(unicode(@lcArmenianLetter)-unicode(N''Ռ'')+1)
                 else   
                   if @lcArmenianLetter >= N''Ճ'' and @lnResult % 1000 = 0  -- 100
                      select @lnResult = @lnResult + 100*(unicode(@lcArmenianLetter)-unicode(N''Ճ'')+1)
                   else   
                      if @lcArmenianLetter >= N''Ժ'' and @lnResult % 100 = 0  -- 10
                        select @lnResult = @lnResult + 10*(unicode(@lcArmenianLetter)-unicode(N''Ժ'')+1)
                      else   
                        if @lcArmenianLetter >= N''Ա'' and @lnResult % 10 = 0  -- 1
                           select @lnResult = @lnResult + unicode(@lcArmenianLetter)-unicode(N''Ա'')+1
                        else   
                           select @lnResult = - 1
                           
            end      
       end
     return  @lnResult
  end

' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[AT]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AT]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- AT, RAT, OCCURS, PADC, PADR, PADL,CHRTRAN, STRTRAN, STRFILTER,
-- GETWORDCOUNT, GETWORDNUM, GETALLWORDS, PROPER, RCHARINDEX, ARABTOROMAN, ROMANTOARAB
-- AT()  Returns the beginning numeric position of the nth occurrence of a character expression within
--       another character expression, counting from the leftmost character
-- RAT() Returns the numeric position of the last (rightmost) occurrence of a character string within 
--       another character string
-- OCCURS() Returns the number of times a character expression occurs within another character expression
-- PADL()   Returns a string from an expression, padded with spaces or characters to a specified length on the left side
-- PADR()   Returns a string from an expression, padded with spaces or characters to a specified length on the right side
-- PADC()   Returns a string from an expression, padded with spaces or characters to a specified length on the both sides
-- CHRTRAN()   Replaces each character in a character expression that matches a character in a second character expression
--             with the corresponding character in a third character expression.
-- STRTRAN()   Searches a character expression for occurrences of a second character expression,
--             and then replaces each occurrence with a third character expression.
--             Unlike a built-in function replace, STRTRAN has three additional parameters.
-- STRFILTER() Removes all characters from a string except those specified. 
-- GETWORDCOUNT() Counts the words in a string
-- GETWORDNUM()   Returns a specified word from a string
-- GETALLWORDS()  Inserts the words from a string into the table
-- PROPER() Returns from a character expression a string capitalized as appropriate for proper names
-- RCHARINDEX()  Similar to the Transact-SQL function Charindex, with a Right search
-- ARABTOROMAN() Returns the character Roman numeral equivalent of a specified numeric expression (from 1 to 3999)
-- ROMANTOARAB() Returns the number equivalent of a specified character Roman numeral expression (from I to MMMCMXCIX)
-- Examples:   GETWORDCOUNT, GETWORDNUM
-- select  dbo.GETWORDCOUNT(''User-Defined marvellous string Functions Transact-SQL'', default)
-- select  dbo.GETWORDNUM(''User-Defined marvellous string Functions Transact-SQL'', 2, default)
-- Examples:  CHRTRAN, STRFILTER
-- select dbo.CHRTRAN(''ABCDEF'', ''ACE'', ''XYZ'')   -- Displays XBYDZF
-- select dbo.STRFILTER(''ABCDABCDABCD'', ''AB'')   -- Displays ABABAB
-- AT, RAT, OCCURS, PROPER  
-- select  dbo.AT (''marvellous'', ''User-Defined marvellous string Functions Transact-SQL'', default)
-- select  dbo.OCCURS (''F'', ''User-Defined marvellous string Functions Transact-SQL'')
-- select  dbo.PROPER (''User-Defined marvellous string Functions Transact-SQL'')
-- PADC, PADR, PADL 
-- select  dbo.PADC ('' marvellous string Functions'', 60, ''+*+'')
-- ARABTOROMAN, ROMANTOARAB
-- select dbo.ARABTOROMAN(3888)      -- Displays MMMDCCCLXXXVIII
-- select dbo.ROMANTOARAB(''CCXXXIV'') -- Displays 234
-- For more information about string UDFs Transact-SQL please visit the 
-- http://www.universalthread.com/wconnect/wc.dll?LevelExtreme~2,54,33,27115   or 
-- http://nikiforov.developpez.com/espagnol/  (the Spanish language)
-- http://nikiforov.developpez.com/           (the French  language)
-- http://nikiforov.developpez.com/allemand/  (the German  language)
-- http://nikiforov.developpez.com/italien/   (the Italian language)
-- http://nikiforov.developpez.com/portugais/ (the Portuguese language)
-- http://nikiforov.developpez.com/roumain/   (the Roumanian  language)
-- http://nikiforov.developpez.com/russe/     (the Russian language)
-- http://nikiforov.developpez.com/bulgare/   (the Bulgarian language)
--------------------------------------------------------------------------------------------------------
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
-- AT() User-Defined Function 
-- Returns the beginning numeric position of the first occurrence of a character expression within another character expression, counting from the leftmost character.
-- (including  overlaps)
-- AT(@cSearchExpression, @cExpressionSearched [, @nOccurrence]) Return Values smallint 
-- Parameters
-- @cSearchExpression nvarchar(4000) Specifies the character expression that AT( ) searches for in @cExpressionSearched. 
-- @cExpressionSearched nvarchar(4000) Specifies the character expression @cSearchExpression searches for. 
-- @nOccurrence smallint Specifies which occurrence (first, second, third, and so on) of @cSearchExpression is searched for in @cExpressionSearched. By default, AT() searches for the first occurrence of @cSearchExpression (@nOccurrence = 1). Including @nOccurrence lets you search for additional occurrences of @cSearchExpression in @cExpressionSearched. AT( ) returns 0 if @nOccurrence is greater than the number of times @cSearchExpression occurs in @cExpressionSearched. 
-- Remarks
-- AT() searches the second character expression for the first occurrence of the first character expression. It then returns an integer indicating the position of the first character in the character expression found. If the character expression is not found, AT() returns 0. The search performed by AT() is case-sensitive.
-- AT is nearly similar to a function Oracle PL/SQL INSTR
-- Example
-- declare @gcString nvarchar(4000), @gcFindString nvarchar(4000)
-- select @gcString = ''Now is the time for all good men'', @gcFindString = ''is the''
-- select dbo.AT(@gcFindString, @gcString, default)  -- Displays 5
-- set @gcFindString = ''IS''
-- select dbo.AT(@gcFindString, @gcString, default)  -- Displays 0, case-sensitive
-- select @gcString = ''goood men'', @gcFindString = ''oo''
-- select dbo.AT(@gcFindString, @gcString, 1)  -- Displays 2
-- select dbo.AT(@gcFindString, @gcString, 2)  -- Displays 3, including  overlaps
-- See Also RAT(), ATC(), AT2()  User-Defined Function 
-- UDF the name and functionality of which correspond  to the  Visual FoxPro function  
CREATE function [dbo].[AT]  (@cSearchExpression nvarchar(4000), @cExpressionSearched  nvarchar(4000), @nOccurrence  smallint = 1 )
returns smallint
as
    begin
      if @nOccurrence > 0
         begin
            declare @i smallint,  @StartingPosition  smallint
            select  @i = 0, @StartingPosition  = -1
            while  @StartingPosition <> 0 and @nOccurrence > @i
               select  @i = @i + 1, @StartingPosition  = charindex(@cSearchExpression COLLATE Latin1_General_BIN, @cExpressionSearched COLLATE Latin1_General_BIN,  @StartingPosition+1 )
         end
      else
         set @StartingPosition =  NULL

     return @StartingPosition
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[AT2]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AT2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
-- AT2() User-Defined Function 
-- Returns the beginning numeric position of the first occurrence of a character expression within another character expression, counting from the leftmost character.
-- (excluding  overlaps)
-- AT2(@cSearchExpression, @cExpressionSearched [, @nOccurrence]) Return Values smallint 
-- Parameters
-- @cSearchExpression nvarchar(4000) Specifies the character expression that AT2( ) searches for in @cExpressionSearched. 
-- @cExpressionSearched nvarchar(4000) Specifies the character expression @cSearchExpression searches for. 
-- @nOccurrence smallint Specifies which occurrence (first, second, third, and so on) of @cSearchExpression is searched for in @cExpressionSearched. By default, AT2() searches for the first occurrence of @cSearchExpression (@nOccurrence = 1). Including @nOccurrence lets you search for additional occurrences of @cSearchExpression in @cExpressionSearched. AT2( ) returns 0 if @nOccurrence is greater than the number of times @cSearchExpression occurs in @cExpressionSearched. 
-- Remarks
-- AT2() searches the second character expression for the first occurrence of the first character expression. It then returns an integer indicating the position of the first character in the character expression found. If the character expression is not found, AT2() returns 0. The search performed by AT2() is case-sensitive.
-- AT2 is nearly similar to a function Oracle PL/SQL INSTR
-- Example
-- declare @gcString nvarchar(4000), @gcFindString nvarchar(4000)
-- select @gcString = ''Now is the time for all good men'', @gcFindString = ''is the''
-- select dbo.AT2(@gcFindString, @gcString, default)  -- Displays 5
-- set @gcFindString = ''IS''
-- select dbo.AT2(@gcFindString, @gcString, default)  -- Displays 0, case-sensitive 
-- select @gcString = ''goood men'', @gcFindString = ''oo''
-- select dbo.AT2(@gcFindString, @gcString, 1)  -- Displays 2
-- select dbo.AT2(@gcFindString, @gcString, 2)  -- Displays 0, excluding  overlaps
-- See Also AT(), ATC(), ATC2()  User-Defined Function 
CREATE function [dbo].[AT2]  (@cSearchExpression nvarchar(4000), @cExpressionSearched  nvarchar(4000), @nOccurrence  smallint = 1 )
returns smallint
as
    begin
      declare  @LencSearchExpression smallint
      select    @LencSearchExpression  = datalength(@cSearchExpression)/(case SQL_VARIANT_PROPERTY(@cSearchExpression,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode

      if @nOccurrence > 0
         begin
            declare @i smallint,  @StartingPosition  smallint
            select  @i = 0, @StartingPosition  = -1 - @LencSearchExpression
            while  @StartingPosition <> 0 and @nOccurrence > @i
               select  @i = @i + 1, @StartingPosition  = charindex(@cSearchExpression COLLATE Latin1_General_BIN, @cExpressionSearched COLLATE Latin1_General_BIN,  @StartingPosition + @LencSearchExpression )
         end
      else
         set @StartingPosition =  NULL
  return @StartingPosition
 end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[ATC]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ATC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
-- ATC() User-Defined Function 
-- Returns the beginning numeric position of the first occurrence of a character expression within another character expression, counting from the leftmost character.
-- The search performed by ATC() is case-insensitive (including  overlaps). 
-- ATC(@cSearchExpression, @cExpressionSearched [, @nOccurrence]) Return Values smallint 
-- Parameters
-- @cSearchExpression nvarchar(4000) Specifies the character expression that ATC( ) searches for in @cExpressionSearched. 
-- @cExpressionSearched nvarchar(4000) Specifies the character expression @cSearchExpression searches for. 
-- @nOccurrence smallint Specifies which occurrence (first, second, third, and so on) of @cSearchExpression is searched for in @cExpressionSearched. By default, ATC() searches for the first occurrence of @cSearchExpression (@nOccurrence = 1). Including @nOccurrence lets you search for additional occurrences of @cSearchExpression in @cExpressionSearched.
-- ATC( ) returns 0 if @nOccurrence is greater than the number of times @cSearchExpression occurs in @cExpressionSearched. 
-- Remarks
-- ATC() searches the second character expression for the first occurrence of the first character expression,
-- without concern for the case (upper or lower) of the characters in either expression. Use AT( ) to perform a case-sensitive search.
-- It then returns an integer indicating the position of the first character in the character expression found. If the character expression is not found, ATC() returns 0. 
-- ATC is nearly similar to a function Oracle PL/SQL INSTR
-- Example
-- declare @gcString nvarchar(4000), @gcFindString nvarchar(4000)
-- select @gcString = ''Now is the time for all good men'', @gcFindString = ''is the''
-- select dbo.ATC(@gcFindString, @gcString, default)  -- Displays 5
-- set @gcFindString = ''IS''
-- select dbo.ATC(@gcFindString, @gcString, default)  -- Displays 5, case-insensitive
-- See Also AT()  User-Defined Function 
-- UDF the name and functionality of which correspond  to the  Visual FoxPro function  
CREATE function [dbo].[ATC]  (@cSearchExpression nvarchar(4000), @cExpressionSearched  nvarchar(4000), @nOccurrence  smallint = 1 )
returns smallint
as
    begin
      if @nOccurrence > 0
         begin
            declare @i smallint,  @StartingPosition  smallint
            select  @i = 0, @StartingPosition  = -1
            select  @cSearchExpression = lower(@cSearchExpression), @cExpressionSearched = lower(@cExpressionSearched)
            while  @StartingPosition <> 0 and @nOccurrence > @i
               select  @i = @i + 1, @StartingPosition  = charindex(@cSearchExpression COLLATE Latin1_General_CI_AS, @cExpressionSearched COLLATE Latin1_General_CI_AS,  @StartingPosition+1 )
         end
      else
         set @StartingPosition =  NULL

     return @StartingPosition
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[ATC2]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ATC2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
-- ATC2() User-Defined Function 
-- Returns the beginning numeric position of the first occurrence of a character expression within another character expression, counting from the leftmost character.
-- The search performed by ATC2() is case-insensitive (excluding  overlaps).
-- ATC2(@cSearchExpression, @cExpressionSearched [, @nOccurrence]) Return Values smallint 
-- Parameters
-- @cSearchExpression nvarchar(4000) Specifies the character expression that ATC2( ) searches for in @cExpressionSearched. 
-- @cExpressionSearched nvarchar(4000) Specifies the character expression @cSearchExpression searches for. 
-- @nOccurrence smallint Specifies which occurrence (first, second, third, and so on) of @cSearchExpression is searched for in @cExpressionSearched. By default, ATC2() searches for the first occurrence of @cSearchExpression (@nOccurrence = 1). Including @nOccurrence lets you search for additional occurrences of @cSearchExpression in @cExpressionSearched.
-- ATC2() returns 0 if @nOccurrence is greater than the number of times @cSearchExpression occurs in @cExpressionSearched. 
-- Remarks
-- ATC2() searches the second character expression for the first occurrence of the first character expression. It then returns an integer indicating the position of the first character in the character expression found. If the character expression is not found, ATC2() returns 0. 
-- ATC2 is nearly similar to a function Oracle PL/SQL INSTR
-- Example
-- declare @gcString nvarchar(4000), @gcFindString nvarchar(4000)
-- select @gcString = ''Now is the time for all good men'', @gcFindString = ''is the''
-- select dbo.ATC2(@gcFindString, @gcString, default)  -- Displays 5
-- set @gcFindString = ''IS''
-- select dbo.ATC2(@gcFindString, @gcString, default)  -- Displays 5, case-insensitive
-- select @gcString = ''goood men'', @gcFindString = ''oo''
-- select dbo.ATC2(@gcFindString, @gcString, 1)  -- Displays 2
-- select dbo.ATC2(@gcFindString, @gcString, 2)  -- Displays 0, excluding  overlaps
-- See Also AT(), AT2(), ATC2()  User-Defined Function 
CREATE function [dbo].[ATC2]  (@cSearchExpression nvarchar(4000), @cExpressionSearched  nvarchar(4000), @nOccurrence  smallint = 1 )
returns smallint
as
    begin
      declare  @LencSearchExpression smallint
      select    @LencSearchExpression  = datalength(@cSearchExpression)/(case SQL_VARIANT_PROPERTY(@cSearchExpression,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode

      if @nOccurrence > 0
         begin
            declare @i smallint,  @StartingPosition  smallint
            select  @i = 0, @StartingPosition  = -1 - @LencSearchExpression
            select  @cSearchExpression = lower(@cSearchExpression), @cExpressionSearched = lower(@cExpressionSearched)
            while  @StartingPosition <> 0 and @nOccurrence > @i
               select  @i = @i + 1, @StartingPosition  = charindex(@cSearchExpression COLLATE Latin1_General_CI_AS, @cExpressionSearched COLLATE Latin1_General_CI_AS,  @StartingPosition + @LencSearchExpression)
         end
      else
         set @StartingPosition =  NULL

 return @StartingPosition
 end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[CHARINDEX_BIN]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHARINDEX_BIN]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
-- Similar to the Transact-SQL function Charindex, but regardless of collation settings,  
-- executes case-sensitive search  
CREATE function [dbo].[CHARINDEX_BIN](@expression1 nvarchar(4000), @expression2  nvarchar(4000), @start_location  smallint = 1)
returns nvarchar(4000)
as
    begin
       return charindex( @expression1  COLLATE Latin1_General_BIN, @expression2   COLLATE Latin1_General_BIN, @start_location )
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[CHARINDEX_CI]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHARINDEX_CI]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
-- Similar to the Transact-SQL function Charindex, but regardless of collation settings,  
-- executes case-insensitive search  
CREATE function [dbo].[CHARINDEX_CI](@expression1 nvarchar(4000), @expression2  nvarchar(4000), @start_location  smallint = 1)
returns nvarchar(4000)
as
    begin
       return charindex( @expression1 COLLATE Latin1_General_CI_AS , @expression2   COLLATE Latin1_General_CI_AS , @start_location )
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[CHRTRAN]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHRTRAN]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
-- CHRTRAN() User-Defined Function
-- Replaces each character in a character expression that matches a character in a second character expression with the corresponding character in a third character expression.
-- CHRTRAN  (@cExpressionSearched,   @cSearchExpression,  @cReplacementExpression)
-- Return Values nvarchar(4000) 
-- Parameters
-- @cSearchedExpression   Specifies the expression in which CHRTRAN( ) replaces characters. 
-- @cSearchExpression  Specifies the expression containing the characters CHRTRAN( ) looks for in @cSearchedExpression. 
-- @cReplacementExpression Specifies the expression containing the replacement characters. 
-- If a character in@cSearchExpression is found in @cSearchedExpression, the character in @cSearchedExpression is replaced by a character from @cReplacementExpression
-- that is in the same position in @cReplacementExpression as the respective character in @cSearchExpression. 
-- If @cReplacementExpression has fewer characters than @cSearchExpression, the additional characters in @cSearchExpression are deleted from @cSearchedExpression. 
-- If @cReplacementExpression has more characters than @cSearchExpression, the additional characters in @cReplacementExpression are ignored. 
-- Remarks
-- CHRTRAN() translates the character expression @cSearchedExpression using the translation expressions @cSearchExpression and @cReplacementExpression and returns the resulting character string.
-- CHRTRAN similar to the Oracle function PL/SQL TRANSLATE
-- Example
-- select dbo.CHRTRAN(''ABCDEF'', ''ACE'', ''XYZ'')      -- Displays XBYDZF
-- select dbo.CHRTRAN(''ABCDEF'', ''ACE'', ''XYZQRST'')  -- Displays XBYDZF
-- See Also STRFILTER()  
-- UDF the name and functionality of which correspond  to the  Visual FoxPro function  
CREATE function [dbo].[CHRTRAN] (@cExpressionSearched nvarchar(4000),   @cSearchExpression nvarchar(256),  @cReplacementExpression nvarchar(256))
returns  nvarchar(4000)
as
    begin
      declare @lenExpressionSearched smallint, @lenSearchExpression smallint, @lenReplacementExpression smallint,
              @i  smallint,  @j  smallint,  @flag bit, @cExpressionTranslated  nvarchar(4000)
      
      select  @cExpressionTranslated = N'''',  @i = 1, @flag = 0, 
              @lenExpressionSearched =  datalength(@cExpressionSearched)/(case SQL_VARIANT_PROPERTY(@cExpressionSearched,''BaseType'') when ''nvarchar'' then 2  else 1 end),
              @lenSearchExpression =  datalength(@cSearchExpression)/(case SQL_VARIANT_PROPERTY(@cSearchExpression,''BaseType'') when ''nvarchar'' then 2  else 1 end),
              @lenReplacementExpression =  datalength(@cReplacementExpression)/(case SQL_VARIANT_PROPERTY(@cReplacementExpression,''BaseType'') when ''nvarchar'' then 2  else 1 end)  -- for unicode
    
     if @lenReplacementExpression > @lenSearchExpression
         select @cReplacementExpression = left(@cReplacementExpression, @lenSearchExpression),   @lenReplacementExpression = @lenSearchExpression

     while @i  <=   @lenReplacementExpression
       if  charindex(substring(@cReplacementExpression, @i, 1) COLLATE Latin1_General_BIN, @cSearchExpression COLLATE Latin1_General_BIN, @i + 1) > 0
         begin
            select  @flag = 1
            break
         end
       else
         select @i = @i + 1

   if @lenExpressionSearched = 4000  -- built-in function replace do not works correctly if the length of the string is 4000     MS SQL Server 2000, SP4
      if  charindex(right(@cExpressionSearched,1) COLLATE Latin1_General_BIN, @cSearchExpression COLLATE Latin1_General_BIN) > 0     -- I did run this example and validated the erroneous result
           select  @flag = 1                                                              -- select right(replace(replicate(N''z'',3999)+N''i'', N''i'', N''B''),1) -- Displays i  but this is incorrect result, correct result is B

   select @i = 1

    if @flag  =  0
       -- this algorithm does not work always as
       -- select dbo.CHRTRAN(''eaba'',''ba'',''a'') -- Displays  e  Error !!!  ea  Correctly
       begin
          while @i  <=   @lenSearchExpression
            select  @cExpressionSearched = replace(@cExpressionSearched  COLLATE Latin1_General_BIN, 
                                                   substring(@cSearchExpression, @i, 1)   COLLATE Latin1_General_BIN,
                                                   substring(@cReplacementExpression, @i, 1)   COLLATE Latin1_General_BIN ),
                    @i =  @i + 1 
          select  @cExpressionTranslated = @cExpressionSearched
       end
    else
       while @i  <=   @lenExpressionSearched
          begin
             select @j  =  charindex(substring(@cExpressionSearched, @i, 1) COLLATE Latin1_General_BIN, @cSearchExpression COLLATE Latin1_General_BIN)
               if  @j  > 0
                   select  @cExpressionTranslated = @cExpressionTranslated + substring(@cReplacementExpression, @j , 1)
               else
                  select  @cExpressionTranslated = @cExpressionTranslated + substring(@cExpressionSearched, @i, 1)
             select   @i =  @i + 1 
          end

   return  @cExpressionTranslated
  end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[GETALLWORDS]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GETALLWORDS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
 -- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com 
 -- GETALLWORDS() User-Defined Function Inserts the words from a string into the table.
 -- GETALLWORDS(@cString[, @cDelimiters])
 -- Parameters
 -- @cString  nvarchar(4000) - Specifies the string whose words will be inserted into the table @GETALLWORDS. 
 -- @cDelimiters nvarchar(256) - Optional. Specifies one or more optional characters used to separate words in @cString.
 -- The default delimiters are space, tab, carriage return, and line feed. Note that GETALLWORDS( ) uses each of the characters in @cDelimiters as individual delimiters, not the entire string as a single delimiter. 
 -- Return Value table 
 -- Remarks GETALLWORDS() by default assumes that words are delimited by spaces or tabs. If you specify another character as delimiter, this function ignores spaces and tabs and uses only the specified character.
 -- Example
 -- declare @cString nvarchar(4000)
 -- set @cString = ''The default delimiters are space, tab, carriage return, and line feed. If you specify another character as delimiter, this function ignores spaces and tabs and uses only the specified character.''
 -- select * from  dbo.GETALLWORDS(@cString, default)     
 -- select * from dbo.GETALLWORDS(@cString, '' ,.'')              
 -- See Also GETWORDNUM() , GETWORDCOUNT() User-Defined Functions   
CREATE function [dbo].[GETALLWORDS]  (@cString nvarchar(4000), @cDelimiters nvarchar(256))
returns  @GETALLWORDS  table (WORDNUM  smallint, WORD nvarchar(4000), STARTOFWORD smallint, LENGTHOFWORD  smallint)
    begin
         declare @k smallint, @wordcount smallint, @nEndString smallint, @BegOfWord smallint, @flag bit

         select   @k = 1, @wordcount = 1,  @BegOfWord = 1,  @flag = 0,  @cString =  isnull(@cString, ''''), 
                  @cDelimiters = isnull(@cDelimiters, nchar(32)+nchar(9)+nchar(10)+nchar(13)), -- if no break string is specified, the function uses spaces, tabs, carriage return and line feed to delimit words.
                  @nEndString = 1 + datalength(@cString) /(case SQL_VARIANT_PROPERTY(@cString,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode

                     while 1 > 0
                         begin
                                if  @k - @BegOfWord  >  0 
                                     begin
                                          insert into @GETALLWORDS (WORDNUM,  WORD, STARTOFWORD, LENGTHOFWORD)    values( @wordcount, substring(@cString, @BegOfWord, @k-@BegOfWord), @BegOfWord,  @k-@BegOfWord )   -- previous word
                                          select  @wordcount = @wordcount + 1,  @BegOfWord = @k 
                                      end   
                                 if  @flag  = 1 
                                        break

                                 while charindex(substring(@cString, @k, 1)  COLLATE Latin1_General_BIN,  @cDelimiters COLLATE Latin1_General_BIN) > 0  and  @nEndString > @k  -- skip  break characters, if any
                                        select @k = @k + 1,  @BegOfWord  = @BegOfWord +  1
                                 while charindex(substring(@cString, @k, 1)  COLLATE Latin1_General_BIN,  @cDelimiters COLLATE Latin1_General_BIN) = 0  and  @nEndString > @k  -- skip  the character in the word
                                        select  @k = @k + 1 
                                 if  @k >= @nEndString 
                                        select  @flag  = 1
                          end 
       return 
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[GETALLWORDS2]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GETALLWORDS2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
 -- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com 
 -- GETALLWORDS2() User-Defined Function Inserts the words from a string into the table.
 -- GETALLWORDS2(@cString[, @cStringSplitting])
 -- Parameters
 -- @cString  nvarchar(4000) - Specifies the string whose words will be inserted into the table @GETALLWORDS2. 
 -- @cStringSplitting nvarchar(256) - Optional. Specifies the string used to separate words in @cString.
 -- The default delimiter is space.
 -- Note that GETALLWORDS2( ) uses  @cStringSplitting as a single delimiter. 
 -- Return Value table 
 -- Remarks GETALLWORDS2() by default assumes that words are delimited by space. If you specify another string as delimiter, this function ignores spaces and uses only the specified string.
 -- Example
 -- declare @cString nvarchar(4000), @nIndex smallint 
 -- select @cString = ''We hold these truths to be self-evident, that all men are created equal, that they are endowed by their Creator with certain unalienable Rights, that among these are Life, Liberty and the pursuit of Happiness.'', @nIndex = 30
 -- select WORD from dbo.GETALLWORDS2(@cString, default) where WORDNUM = @nIndex  -- Displays ''Liberty''
 -- select top 1 WORDNUM from dbo.GETALLWORDS2(@cString, default) order by WORDNUM desc  -- Displays 35
 -- See Also GETWORDNUM() , GETWORDCOUNT() ,  GETALLWORDS()  User-Defined Functions   
CREATE function [dbo].[GETALLWORDS2]  (@cString nvarchar(4000), @cStringSplitting  nvarchar(256) = '' ''  )   -- if no break string is specified, the function uses space to delimit words.
returns  @GETALLWORDS2  table (WORDNUM  smallint, WORD nvarchar(4000), STARTOFWORD smallint, LENGTHOFWORD  smallint)
    begin
        declare @k smallint,   @BegOfWord smallint,  @wordcount  smallint,  @nEndString smallint,  @nLenSrtingSplitting smallint, @flag bit

        select   @cStringSplitting = isnull(@cStringSplitting, space(1)) ,
                    @cString = isnull(@cString, '''') ,
                    @BegOfWord = 1,   @wordcount = 1,  @k = 0 , @flag = 0,
                    @nEndString =  1+  datalength(@cString) /(case SQL_VARIANT_PROPERTY(@cString,''BaseType'') when ''nvarchar'' then 2  else 1 end),
                    @nLenSrtingSplitting =  datalength(@cStringSplitting) /(case SQL_VARIANT_PROPERTY(@cStringSplitting,''BaseType'') when ''nvarchar'' then 2  else 1 end)   -- for unicode

       while  1 > 0 
          begin
             if  @k - @BegOfWord  >  0  
                 begin
                      insert into @GETALLWORDS2 (WORDNUM,  WORD, STARTOFWORD, LENGTHOFWORD)    values( @wordcount,  substring(@cString,  @BegOfWord , @k - @BegOfWord ) , @BegOfWord,  @k - @BegOfWord)
                      select  @wordcount = @wordcount + 1,  @BegOfWord = @k 
                 end 

             if  @flag  = 1 
                 break

             while charindex( substring(@cString, @BegOfWord, @nLenSrtingSplitting) COLLATE Latin1_General_BIN, @cStringSplitting COLLATE Latin1_General_BIN) > 0 --  skip break strings, if any     
                 set  @BegOfWord  = @BegOfWord +  @nLenSrtingSplitting

             select   @k  = charindex(@cStringSplitting  COLLATE Latin1_General_BIN, @cString COLLATE Latin1_General_BIN, @BegOfWord)   

             if  @k = 0 
                select   @k  =  @nEndString,  @flag  = 1
          end

       return 
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[GETWORDCOUNT]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GETWORDCOUNT]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
 -- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com 
 -- GETWORDCOUNT() User-Defined Function Counts the words in a string.
 -- GETWORDCOUNT(@cString[, @cDelimiters])
 -- Parameters
 -- @cString  nvarchar(4000) - Specifies the string whose words will be counted. 
 -- @cDelimiters nvarchar(256) - Optional. Specifies one or more optional characters used to separate words in @cString.
 -- The default delimiters are space, tab, carriage return, and line feed. Note that GETWORDCOUNT( ) uses each of the characters in @cDelimiters as individual delimiters, not the entire string as a single delimiter. 
 -- Return Value smallint 
 -- Remarks GETWORDCOUNT() by default assumes that words are delimited by spaces or tabs. If you specify another character as delimiter, this function ignores spaces and tabs and uses only the specified character.
 -- If you use ''AAA aaa, BBB bbb, CCC ccc.'' as the target string for dbo.GETWORDCOUNT(), you can get all the following results.
 -- declare @cString nvarchar(4000)
 -- set @cString = ''AAA aaa, BBB bbb, CCC ccc.''
 -- select dbo.GETWORDCOUNT(@cString, default)           -- 6 - character groups, delimited by '' ''
 -- select dbo.GETWORDCOUNT(@cString, '','')               -- 3 - character groups, delimited by '',''
 -- select dbo.GETWORDCOUNT(@cString, ''.'')               -- 1 - character group, delimited by ''.''
 -- See Also GETWORDNUM(), GETALLWORDS() User-Defined Functions  
 -- UDF the name and functionality of which correspond  to the  Visual FoxPro function  
CREATE function [dbo].[GETWORDCOUNT]  (@cString nvarchar(4000), @cDelimiters nvarchar(256) )
returns smallint 
as
    begin
      declare @k smallint, @nEndString smallint, @wordcount smallint
      select  @k = 1, @wordcount = 0, @cDelimiters = isnull(@cDelimiters, nchar(32)+nchar(9)+nchar(10)+nchar(13)), -- if no break string is specified, the function uses spaces, tabs, carriage return and line feed to delimit words.
              @nEndString = 1 + datalength(@cString)/(case SQL_VARIANT_PROPERTY(@cString,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode

      while charindex(substring(@cString, @k, 1) COLLATE Latin1_General_BIN, @cDelimiters COLLATE Latin1_General_BIN) > 0  and  @nEndString > @k  -- skip opening break characters, if any
          set @k = @k + 1

      if @k < @nEndString
         begin
            set @wordcount = 1 -- count the one we are in now count transitions from ''not in word'' to ''in word'' 
                               -- if the current character is a break char, but the next one is not, we have entered a new word
            while @k < @nEndString
               begin
                  if @k +1 < @nEndString  and charindex(substring(@cString, @k, 1) COLLATE Latin1_General_BIN, @cDelimiters COLLATE Latin1_General_BIN) > 0
                                          and charindex(substring(@cString, @k+1, 1) COLLATE Latin1_General_BIN, @cDelimiters COLLATE Latin1_General_BIN) = 0
                        select @wordcount = @wordcount + 1, @k = @k + 1 -- Skip over the first character in the word. We know it cannot be a break character.
                  set @k = @k + 1
               end
         end

     return @wordcount
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[GETWORDNUM]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GETWORDNUM]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
 -- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
 -- GETWORDNUM() User-Defined Function 
 -- Returns a specified word from a string.
 -- GETWORDNUM(@cString, @nIndex[, @cDelimiters])
 -- Parameters @cString  nvarchar(4000) - Specifies the string to be evaluated 
 -- @nIndex smallint - Specifies the index position of the word to be returned. For example, if @nIndex is 3, GETWORDNUM( ) returns the third word (if @cString contains three or more words). 
 -- @cDelimiters nvarchar(256) - Optional. Specifies one or more optional characters used to separate words in @cString.
 -- The default delimiters are space, tab, carriage return, and line feed. Note that GetWordNum( ) uses each of the characters in @cDelimiters as individual delimiters, not the entire string as a single delimiter. 
 -- Return Value nvarchar(4000)
 -- Remarks Returns the word at the position specified by @nIndex in the target string, @cString. If @cString contains fewer than @nIndex words, GETWORDNUM( ) returns an empty string.
 -- Example
 -- select dbo.GETWORDNUM(''To be, or not to be: that is the question:'', 10, '' ,.:'') -- Displays ''question''
 -- See Also
 -- GETWORDCOUNT(), GETALLWORDS() User-Defined Functions 
 -- UDF the name and functionality of which correspond  to the Visual FoxPro function  
CREATE function [dbo].[GETWORDNUM]  (@cString nvarchar(4000), @nIndex smallint, @cDelimiters nvarchar(256) )
returns nvarchar(4000)
as
    begin
      declare @i smallint,  @j smallint, @k smallint, @l smallint, @lmin smallint, @nEndString smallint, @LenDelimiters smallint, @cWord  nvarchar(4000)
      select  @i = 1, @k = 1, @l = 0, @cWord = '''', @cDelimiters = isnull(@cDelimiters,  nchar(32)+nchar(9)+nchar(10)+nchar(13)), -- if no break string is specified, the function uses spaces, tabs, carriage return and line feed to delimit words.
              @nEndString = 1 + datalength(@cString)/(case SQL_VARIANT_PROPERTY(@cString,''BaseType'') when ''nvarchar'' then 2  else 1 end), -- for unicode
              @LenDelimiters = datalength(@cDelimiters)/(case SQL_VARIANT_PROPERTY(@cDelimiters,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode

      while @i <= @nIndex
         begin
            while charindex(substring(@cString, @k, 1) COLLATE Latin1_General_BIN, @cDelimiters COLLATE Latin1_General_BIN) > 0 and  @nEndString > @k   -- skip opening break characters, if any
               set @k = @k + 1

            if  @k >= @nEndString
               break

            select @j = 1, @lmin = @nEndString -- find next break character it marks the end of this word
            while @j <= @LenDelimiters
               begin
                  set @l = charindex(substring(@cDelimiters, @j, 1) COLLATE Latin1_General_BIN, @cString COLLATE Latin1_General_BIN, @k)
                  set @j = @j + 1
                  if @l > 0 and @lmin > @l
                     set @lmin = @l
               end

            if @i = @nIndex -- this is the actual word we are looking for
               begin
                  set @cWord =  substring(@cString, @k, @lmin-@k)
                  break
               end
             set @k = @lmin + 1

             if (@k >= @nEndString)
                 break
             set @i = @i + 1
         end

     return @cWord
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[OCCURS]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OCCURS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
 -- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
 -- OCCURS() User-Defined Function
 -- Returns the number of times a character expression occurs within another character expression (including  overlaps).
 -- OCCURS is slowly than OCCURS2.
 -- OCCURS(@cSearchExpression, @cExpressionSearched)
 -- Return Values smallint 
 -- Parameters
 -- @cSearchExpression nvarchar(4000) Specifies a character expression that OCCURS() searches for within @cExpressionSearched. 
 -- @cExpressionSearched nvarchar(4000) Specifies the character expression OCCURS() searches for @cSearchExpression. 
 -- Remarks
 -- OCCURS() returns 0 (zero) if @cSearchExpression is not found within @cExpressionSearched.
 -- Example
 -- declare @gcString nvarchar(4000)
 -- select  @gcString = ''abracadabra''
 -- select dbo.OCCURS(''a'', @gcString )  -- Displays 5
 -- select dbo.OCCURS(''b'', @gcString )  -- Displays 2
 -- select dbo.OCCURS(''c'', @gcString )  -- Displays 1
 -- select dbo.OCCURS(''e'', @gcString )  -- Displays 0
 -- Including  overlaps !!!
 -- select dbo.OCCURS(''ABCA'', ''ABCABCABCA'') -- Displays 3
 -- 1 occurrence of substring ''ABCA  .. BCABCA'' 
 -- 2 occurrence of substring ''ABC...ABCA...BCA'' 
 -- 3 occurrence of substring ''ABCABC...ABCA'' 
 -- See Also AT(), RAT(), OCCURS2(), AT2(), ATC(), ATC2()    
 -- UDF the name and functionality of which correspond to the  Visual FoxPro function  
 -- (but function OCCURS of Visual FoxPro counts the ''occurs'' excluding  overlaps !)
CREATE function [dbo].[OCCURS]  (@cSearchExpression nvarchar(4000), @cExpressionSearched nvarchar(4000))
returns smallint
as
    begin
      declare @start_location smallint,  @occurs  smallint
      select  @start_location = -1,   @occurs = -1
      while @start_location <> 0
          select  @occurs = @occurs + 1,  @start_location  = charindex(@cSearchExpression COLLATE Latin1_General_BIN, @cExpressionSearched COLLATE Latin1_General_BIN, @start_location+1)

     return @occurs
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[OCCURS2]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OCCURS2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
 -- Author: Stephen Dobson, Toronto, EMail: sdobson@acc.org   
 -- OCCURS2() User-Defined Function
 -- Returns the number of times a character expression occurs  within another character expression (excluding  overlaps).
 -- OCCURS2 is faster than OCCURS.
 -- OCCURS2(@cSearchExpression, @cExpressionSearched)
 -- Return Values smallint 
 -- Parameters
 -- @cSearchExpression nvarchar(4000) Specifies a character expression that OCCURS2() searches for within @cExpressionSearched. 
 -- @cExpressionSearched nvarchar(4000) Specifies the character expression OCCURS2() searches for @cSearchExpression. 
 -- Remarks
 -- OCCURS2() returns 0 (zero) if @cSearchExpression is not found within @cExpressionSearched.
 -- Example
 -- declare @gcString nvarchar(4000)
 -- select  @gcString = ''abracadabra''
 -- select dbo.OCCURS2(''a'', @gcString )  -- Displays 5
 -- Attention !!!
 -- This function counts the ''occurs'' excluding  overlaps !
 -- select dbo.OCCURS2(''ABCA'', ''ABCABCABCA'') -- Displays 2
 -- 1 occurrence of substring ''ABCA  .. BCABCA'' 
 -- 2 occurrence of substring ''ABCABC... ABCA'' 
 -- UDF the functionality of which correspond to the  Visual FoxPro function 
 -- See Also OCCURS()  
CREATE function [dbo].[OCCURS2]  (@cSearchExpression nvarchar(4000), @cExpressionSearched nvarchar(4000))
returns smallint
as
    begin
         return
           case  
              when datalength(@cSearchExpression) > 0
              then   ( datalength(@cExpressionSearched) 
                   - datalength(replace(@cExpressionSearched  COLLATE Latin1_General_BIN, 
                                         @cSearchExpression   COLLATE Latin1_General_BIN,  '''')))  
                  / datalength(@cSearchExpression)
             else 0 
          end
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[PADC]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PADC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
 -- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com 
 -- PADL(), PADR(), PADC() User-Defined Functions
 -- Returns a string from an expression, padded with spaces or characters to a specified length on the left or right sides, or both.
 -- PADL(@eExpression, @nResultSize [, @cPadCharacter]) -Or-
 -- PADR(@eExpression, @nResultSize [, @cPadCharacter]) -Or-
 -- PADC(@eExpression, @nResultSize [, @cPadCharacter])
 -- Return Values nvarchar(4000)
 -- Parameters
 -- @eExpression nvarchar(4000) Specifies the expression to be padded.
 -- @nResultSize  smallint Specifies the total number of characters in the expression after it is padded. 
 -- @cPadCharacter nvarchar(4000) Specifies the value to use for padding. This value is repeated as necessary to pad the expression to the specified number of characters. 
 -- If you omit @cPadCharacter, spaces (ASCII character 32) are used for padding. 
 -- Remarks
 -- PADL() inserts padding on the left, PADR() inserts padding on the right, and PADC() inserts padding on both sides.
 -- Example
 -- declare @gcString  nvarchar(4000)
 -- select @gcString  = ''TITLE'' 
 -- select dbo.PADL(@gcString, 40, default)
 -- select dbo.PADL(@gcString, 40, ''=!='')
 -- select dbo.PADR(@gcString, 40, ''=+='')
 -- select dbo.PADC(@gcString, 40, ''=~'')  
 -- UDF the name and functionality of which correspond  to the  Visual FoxPro function   
CREATE function [dbo].[PADC]  (@cString nvarchar(4000), @nLen smallint, @cPadCharacter nvarchar(4000) = '' '' )
returns nvarchar(4000)
as
  begin
        declare @length smallint, @lengthPadCharacter smallint
        if @cPadCharacter is NULL or  datalength(@cPadCharacter) = 0
           set @cPadCharacter = space(1) 
        select  @length  = datalength(@cString)/(case SQL_VARIANT_PROPERTY(@cString,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode
        select  @lengthPadCharacter  = datalength(@cPadCharacter)/(case SQL_VARIANT_PROPERTY(@cPadCharacter,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode
           
  	    if @length >= @nLen
	       set  @cString = left(@cString, @nLen)
 	    else
 	      begin
              declare @nLeftLen smallint, @nRightLen smallint
              set @nLeftLen = (@nLen - @length )/2            -- Quantity of characters, added at the left
              set @nRightLen  =  @nLen - @length - @nLeftLen  -- Quantity of characters, added on the right
              set @cString = left(replicate(@cPadCharacter, ceiling(@nLeftLen/@lengthPadCharacter) + 2), @nLeftLen)+ @cString + left(replicate(@cPadCharacter, ceiling(@nRightLen/@lengthPadCharacter) + 2), @nRightLen)
	      end

     return (@cString)
  end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[PADL]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PADL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
 -- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
 -- PADL(), PADR(), PADC() User-Defined Functions
 -- Returns a string from an expression, padded with spaces or characters to a specified length on the left or right sides, or both.
 -- PADL similar to the Oracle function PL/SQL  LPAD 
CREATE function [dbo].[PADL]  (@cString nvarchar(4000), @nLen smallint, @cPadCharacter nvarchar(4000) = '' '' )
returns nvarchar(4000)
as
  begin
        declare @length smallint, @lengthPadCharacter smallint
        if @cPadCharacter is NULL or  datalength(@cPadCharacter) = 0
           set @cPadCharacter = space(1) 
        select  @length = datalength(@cString)/(case SQL_VARIANT_PROPERTY(@cString,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode
        select  @lengthPadCharacter = datalength(@cPadCharacter)/(case SQL_VARIANT_PROPERTY(@cPadCharacter,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode

        if @length >= @nLen
           set  @cString = left(@cString, @nLen)
        else
	       begin
              declare @nLeftLen smallint
              set @nLeftLen = @nLen - @length  -- Quantity of characters, added at the left
              set @cString = left(replicate(@cPadCharacter, ceiling(@nLeftLen/@lengthPadCharacter) + 2), @nLeftLen)+ @cString
           end

    return (@cString)
  end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[PADR]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PADR]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
 -- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
 -- PADL(), PADR(), PADC() User-Defined Functions
 -- Returns a string from an expression, padded with spaces or characters to a specified length on the left or right sides, or both.
 -- PADR similar to the Oracle function PL/SQL RPAD 
CREATE function [dbo].[PADR]  (@cString nvarchar(4000), @nLen smallint, @cPadCharacter nvarchar(4000) = '' '' )
returns nvarchar(4000)
as
   begin
       declare @length smallint, @lengthPadCharacter smallint
       if @cPadCharacter is NULL or  datalength(@cPadCharacter) = 0
          set @cPadCharacter = space(1) 
       select  @length  = datalength(@cString)/(case SQL_VARIANT_PROPERTY(@cString,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode
       select  @lengthPadCharacter  = datalength(@cPadCharacter)/(case SQL_VARIANT_PROPERTY(@cPadCharacter,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode

       if @length >= @nLen
          set  @cString = left(@cString, @nLen)
       else
          begin
             declare  @nRightLen smallint
             set @nRightLen  =  @nLen - @length -- Quantity of characters, added on the right
             set @cString =  @cString + left(replicate(@cPadCharacter, ceiling(@nRightLen/@lengthPadCharacter) + 2), @nRightLen)
	  end

     return (@cString)
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[PROPER]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PROPER]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
 -- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
 -- PROPER( ) User-Defined Function
 -- Returns from a character expression a string capitalized as appropriate for proper names.
 -- PROPER(@cExpression)
 -- Return Values nvarchar(4000)
 -- Parameters
 -- @cExpression nvarchar(4000) Specifies the character expression from which PROPER( ) returns a capitalized character string. 
 -- Example
 -- declare @gcExpr1 nvarchar(4000), @gcExpr2 nvarchar(4000)
 -- select @gcExpr1 = ''Visual Basic.NET'', @gcExpr2 = ''VISUAL BASIC.NET''
 -- select dbo.PROPER(@gcExpr1)  -- Displays ''Visual Basic.net''
 -- select dbo.PROPER(@gcExpr2)  -- Displays ''Visual Basic.net''
 -- Remarks
 -- PROPER similar to the Oracle function PL/SQL  INITCAP 
 -- UDF the name and functionality of which correspond  to the  Visual FoxPro function  
CREATE function [dbo].[PROPER]  (@expression nvarchar(4000))
returns nvarchar(4000)
as
    begin
      declare @i  smallint,   @properexpression nvarchar(4000),  @lenexpression  smallint, @flag bit, @symbol nchar(1)
      select  @flag = 1, @i = 1, @properexpression = '''', @lenexpression =  datalength(@expression)/(case SQL_VARIANT_PROPERTY(@expression,''BaseType'') when ''nvarchar'' then 2  else 1 end) 

      while  @i <= @lenexpression
          begin
             select @symbol = lower(substring(@expression, @i, 1) )
               if @symbol in (nchar(32), nchar(9), nchar(10), nchar(11), nchar(12), nchar(13),  nchar(160)) and ascii(@symbol) <> 0
                   select @flag = 1
               else
                   if @flag = 1
                       select @symbol = upper(@symbol),  @flag = 0 
              select  @properexpression = @properexpression + @symbol,  @i = @i + 1 
          end

     return @properexpression 
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[RAT]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RAT]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com 
-- RAT( ) User-Defined Function
-- Returns the numeric position of the last (rightmost) occurrence of a character string within another character string.
-- (including  overlaps)
-- RAT(@cSearchExpression, @cExpressionSearched [, @nOccurrence])
-- Return Values smallint 
-- Parameters
-- @cSearchExpression nvarchar(4000) Specifies the character expression that RAT( ) looks for in @cExpressionSearched. 
-- @cExpressionSearched nvarchar(4000) Specifies the character expression that RAT() searches. 
-- @nOccurrence smallint Specifies which occurrence, starting from the right and moving left, of @cSearchExpression RAT() searches for in @cExpressionSearched. By default, RAT() searches for the last occurrence of @cSearchExpression (@nOccurrence = 1). If @nOccurrence is 2, RAT() searches for the next to last occurrence, and so on. 
-- Remarks
-- RAT(), the reverse of the AT() function, searches the character expression in @cExpressionSearched starting from the right and moving left, looking for the last occurrence of the string specified in @cSearchExpression.
-- RAT() returns an integer indicating the position of the first character in @cSearchExpression in @cExpressionSearched. RAT() returns 0 if @cSearchExpression is not found in @cExpressionSearched, or if @nOccurrence is greater than the number of times @cSearchExpression occurs in @cExpressionSearched.
-- The search performed by RAT() is case-sensitive.
-- Example
-- declare @gcString nvarchar(4000), @gcFindString nvarchar(4000)
-- select @gcString = ''abracadabra'', @gcFindString = ''a'' 
-- select dbo.RAT(@gcFindString , @gcString, default)  -- Displays 11
-- select dbo.RAT(@gcFindString , @gcString , 3)       -- Displays 6
-- select @gcString = ''goood men'', @gcFindString = ''oo''
-- select dbo.RAT(@gcFindString, @gcString, 1)  -- Displays 3
-- select dbo.RAT(@gcFindString, @gcString, 2)  -- Displays 2, including  overlaps
-- See Also AT()  User-Defined Function 
-- UDF the name and functionality of which correspond  to the  Visual FoxPro function     
CREATE function [dbo].[RAT]  (@cSearchExpression nvarchar(4000), @cExpressionSearched  nvarchar(4000), @nOccurrence  smallint = 1 )
returns smallint
as
    begin
      if @nOccurrence > 0
         begin
            declare @i smallint, @length smallint, @StartingPosition  smallint
            select  @length  = datalength(@cExpressionSearched)/(case SQL_VARIANT_PROPERTY(@cExpressionSearched,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode
            select  @cSearchExpression = reverse(@cSearchExpression), @cExpressionSearched = reverse(@cExpressionSearched)
            select  @i = 0, @StartingPosition  = -1 
            while @StartingPosition <> 0 and @nOccurrence > @i
               select  @i = @i + 1, @StartingPosition  = charindex(@cSearchExpression  COLLATE Latin1_General_BIN,
                                                                   @cExpressionSearched  COLLATE Latin1_General_BIN, @StartingPosition + 1)
            if @StartingPosition <> 0
              select @StartingPosition = 2 - @StartingPosition +  @length - datalength(@cSearchExpression)/(case SQL_VARIANT_PROPERTY(@cSearchExpression,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode
         end
      else
         set @StartingPosition =  NULL
         
      return @StartingPosition
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[RATC]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RATC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com 
-- RATC( ) User-Defined Function
-- Returns the numeric position of the last (rightmost) occurrence of a character string within another character string.
-- The search performed by RATC() is case-insensitive (including  overlaps). 
-- RATC(@cSearchExpression, @cExpressionSearched [, @nOccurrence])
-- Return Values smallint 
-- Parameters
-- @cSearchExpression nvarchar(4000) Specifies the character expression that RATC( ) looks for in @cExpressionSearched. 
-- @cExpressionSearched nvarchar(4000) Specifies the character expression that RATC() searches. 
-- @nOccurrence smallint Specifies which occurrence, starting from the right and moving left, of @cSearchExpression RATC() searches for in @cExpressionSearched. By default, RATC() searches for the last occurrence of @cSearchExpression (@nOccurrence = 1). If @nOccurrence is 2, RATC() searches for the next to last occurrence, and so on. 
-- Remarks
-- RATC(), the reverse of the ATC() function, searches the character expression in @cExpressionSearched starting from the right and moving left, looking for the last occurrence of the string specified in @cSearchExpression.
-- RATC() returns an integer indicating the position of the first character in @cSearchExpression in @cExpressionSearched. RATC() returns 0 if @cSearchExpression is not found in @cExpressionSearched, or if @nOccurrence is greater than the number of times @cSearchExpression occurs in @cExpressionSearched.
-- Example
-- declare @gcString nvarchar(4000), @gcFindString nvarchar(4000)
-- select @gcString = ''abracadabra'', @gcFindString = ''A'' 
-- select dbo.RATC(@gcFindString , @gcString, default)  -- Displays 11
-- select dbo.RATC(@gcFindString , @gcString , 3)       -- Displays 6
-- See Also ATC()  User-Defined Function 
-- UDF the name and functionality of which correspond  to the  Visual FoxPro function     
CREATE function [dbo].[RATC]  (@cSearchExpression nvarchar(4000), @cExpressionSearched  nvarchar(4000), @nOccurrence  smallint = 1 )
returns smallint
as
    begin
      if @nOccurrence > 0
         begin
            declare @i smallint, @length smallint, @StartingPosition  smallint
            select  @length  = datalength(@cExpressionSearched)/(case SQL_VARIANT_PROPERTY(@cExpressionSearched,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode
            select  @cSearchExpression = lower(reverse(@cSearchExpression)), @cExpressionSearched = lower(reverse(@cExpressionSearched))
            select  @i = 0, @StartingPosition  = -1 
            while @StartingPosition <> 0 and @nOccurrence > @i
               select  @i = @i + 1, @StartingPosition  = charindex(@cSearchExpression  COLLATE Latin1_General_CI_AS,
                                                                   @cExpressionSearched  COLLATE Latin1_General_CI_AS, @StartingPosition + 1)
            if @StartingPosition <> 0
              select @StartingPosition = 2 - @StartingPosition +  @length - datalength(@cSearchExpression)/(case SQL_VARIANT_PROPERTY(@cSearchExpression,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode
         end
      else
         set @StartingPosition =  NULL

     return @StartingPosition
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[RCHARINDEX]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RCHARINDEX]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
-- Similar to the Transact-SQL function Charindex, with a Right search
-- Example
-- select dbo.RCHARINDEX(''me'', ''Now is the time for all good men'', 1)  --  Displays 30
CREATE function [dbo].[RCHARINDEX](@expression1 nvarchar(4000), @expression2  nvarchar(4000), @start_location  smallint = 1 )
returns nvarchar(4000)
as
    begin
       declare @StartingPosition  smallint
       set  @StartingPosition = charindex( reverse(@expression1) COLLATE Latin1_General_BIN, reverse(@expression2) COLLATE Latin1_General_BIN, @start_location)

     return case 
               when  @StartingPosition > 0
               then  2 - @StartingPosition + datalength(@expression2)/(case SQL_VARIANT_PROPERTY(@expression2,''BaseType'') when ''nvarchar'' then 2  else 1 end) 
                       - datalength(@expression1)/(case SQL_VARIANT_PROPERTY(@expression1,''BaseType'') when ''nvarchar'' then 2  else 1 end)  -- for unicode  
            else 0 
            end
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[ROMANTOARAB]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ROMANTOARAB]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- ROMANTOARAB() Returns the number equivalent of a specified character Roman numeral expression (from I to MMMCMXCIX)
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com ,  25 April 2005 or XXV April MMV :-)
-- ROMANTOARAB(@tcRomanNumber) Return Values smallint
-- Parameters @tcRomanNumber  varchar(15) Roman number  
-- Example
-- select dbo.ROMANTOARAB(''MMMDCCCLXXXVIII'') -- Displays 3888
-- select dbo.ROMANTOARAB(''MDCCCLXXXVIII'')   -- Displays 1888
-- select dbo.ROMANTOARAB(''I'')               -- Displays 1
-- select dbo.ROMANTOARAB(''CCXXXIV'')         -- Displays 234
-- See also ARABTOROMAN()  
CREATE function [dbo].[ROMANTOARAB](@tcRomanNumber varchar(15))
returns smallint
as
   begin
      declare @lnResult smallint, @lcRomanNumber varchar(15), @lnI tinyint, @ROMANNUMERALS char(7)
      select @tcRomanNumber = ltrim(rtrim(upper(@tcRomanNumber))), @ROMANNUMERALS = ''IVXLCDM'', @lcRomanNumber = '''', @lnI = 1, @lnResult = 0
   
     while  @lnI <= datalength(@tcRomanNumber)
       begin 
         if charindex(substring(@tcRomanNumber, @lnI, 1), @ROMANNUMERALS) > 0
           set @lcRomanNumber = @lcRomanNumber + substring(@tcRomanNumber, @lnI, 1)
         else
           begin
             set @lnResult = -1
             break
            end
         set @lnI =  @lnI + 1
       end
    
     if @lnResult >  -1
       begin
         declare @lnJ tinyint, @lnDelim smallint, @lnK tinyint
         select  @lnK = datalength(@lcRomanNumber), @lnI = 1
   
         while  @lnI <= 4
            begin
              if @lnK = 0
                  break
              set @lnDelim = power(10, @lnI-1)
              if @lnK >= 2 and substring(@lcRomanNumber, @lnK - 1, 2) = (substring(@ROMANNUMERALS, @lnI*2 - 1, 1)+substring(@ROMANNUMERALS, @lnI*2, 1)) -- CD or XL or IV
                select @lnResult = @lnResult + 4*@lnDelim, @lnK = @lnK - 2
              else  
              if @lnK >= 2 and  substring(@lcRomanNumber, @lnK - 1, 2) = (substring(@ROMANNUMERALS, @lnI*2 - 1, 1)+substring(@ROMANNUMERALS, (@lnI+1)*2 - 1, 1)) -- CM or XC or IX
                select @lnResult = @lnResult + 9*@lnDelim, @lnK = @lnK - 2
              else
                begin 
                  set @lnJ = 1
                  while  @lnJ <= 3  -- MMM or CCC or XXX or III
                    begin
                      if  @lnK >=1 and substring(@lcRomanNumber, @lnK, 1) = substring(@ROMANNUMERALS, @lnI*2 - 1, 1)
                        select @lnResult = @lnResult + @lnDelim, @lnK = @lnK - 1
                      set @lnJ =  @lnJ + 1
                    end 
                  if @lnK = 0
                    break
                  if substring(@lcRomanNumber, @lnK, 1) = substring(@ROMANNUMERALS, @lnI*2, 1) -- D or L or V
                    select @lnResult = @lnResult + 5*@lnDelim, @lnK = @lnK - 1
                end 
             set @lnI =  @lnI + 1
            end
         end      
        
        if @lnK > 0
          set @lnResult = -1
     
     return  @lnResult
   end

' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[STRFILTER]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STRFILTER]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
-- STRFILTER() User-Defined Function
-- Removes all characters from a string except those specified.
-- STRFILTER(@cExpressionSearched, @cSearchExpression)
-- Return Values nvarchar(4000)
-- Parameters
-- @cExpressionSearched  Specifies the character string to search.
-- @cSearchExpression Specifies the characters to search for and retain in @cExpressionSearched.
-- Remarks
-- STRFILTER( ) removes all the characters from @cExpressionSearched that are not in @cSearchExpression, then returns the characters that remain.
-- Example
-- select dbo.STRFILTER(''asdfghh5hh1jk6f3b7mn8m3m0m6'',''0123456789'')   -- Displays 516378306
-- select dbo.STRFILTER(''ABCDABCDABCD'', ''AB'')   -- Displays ABABAB
-- See Also CHRTRAN()  
-- UDF the name and functionality of which correspond  to the Foxtools function ( Foxtools is a Visual FoxPro API library) 
CREATE function [dbo].[STRFILTER]  (@cExpressionSearched nvarchar(4000),   @cSearchExpression nvarchar(256))
returns  nvarchar(4000)
as
    begin
      declare @len smallint,  @i  smallint, @StrFiltred  nvarchar(4000)
      select  @StrFiltred = N'''', @i = 1,  @len =  datalength(@cExpressionSearched)/(case SQL_VARIANT_PROPERTY(@cExpressionSearched,''BaseType'') when ''nvarchar'' then 2  else 1 end) -- for unicode

      while  @i  <=  @len
          begin
               if charindex(substring(@cExpressionSearched, @i, 1) COLLATE Latin1_General_BIN, @cSearchExpression COLLATE Latin1_General_BIN) > 0
                     select  @StrFiltred = @StrFiltred + substring(@cExpressionSearched, @i, 1)
               select @i  =   @i  + 1
          end

     return  @StrFiltred
    end
' 
END

GO
/****** Object:  UserDefinedFunction [dbo].[STRTRAN]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STRTRAN]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- Author:  Igor Nikiforov,  Montreal,  EMail: udfunctions@gmail.com   
-- STRTRAN() User-Defined Function
-- Searches a character expression for occurrences of a second character expression,
-- and then replaces each occurrence with a third character expression.
-- STRTRAN  (@cSearched, @cExpressionSought , [@cReplacement]
-- [, @nStartOccurrence] [, @nNumberOfOccurrences] [, @nFlags])
-- Return Values nvarchar(4000) 
-- Parameters
-- @cSearched         Specifies the character expression that is searched.
-- @cExpressionSought Specifies the character expression that is searched for in @cSearched.
-- @cReplacement      Specifies the character expression that replaces every occurrence of @cExpressionSought in @cSearched.
-- If you omit @cReplacement, every occurrence of @cExpressionSought is replaced with the empty string. 
-- @nStartOccurrence  Specifies which occurrence of @cExpressionSought is the first to be replaced.
-- For example, if @nStartOccurrence is 4, replacement begins with the fourth occurrence of @cExpressionSought in @cSearched and the first three occurrences of @cExpressionSought remain unchanged.
-- The occurrence where replacement begins defaults to the first occurrence of @cExpressionSought if you omit @nStartOccurrence. 
-- @nNumberOfOccurrences  Specifies the number of occurrences of @cExpressionSought to replace.
-- If you omit @nNumberOfOccurrences, all occurrences of @cExpressionSought, starting with the occurrence specified with @nStartOccurrence, are replaced. 
-- @nFlags  Specifies the case-sensitivity of a search according to the following values:
---------------------------------------------------------------------------------------------------------------------------------------             
-- @nFlags     Description 
-- 0 (default) Search is case-sensitive, replace is with exact @cReplacement string.
-- 1           Search is case-insensitive, replace is with exact @cReplacement string. 
-- 2           Search is case-sensitive; replace is with the case of @cReplacement changed to match the case of the string found.
--             The case of @cReplacement will only be changed if the string found is all uppercase, lowercase, or proper case. 
-- 3           Search is case-insensitive; replace is with the case of @cReplacement changed to match the case of the string found.
--             The case of @cReplacement will only be changed if the string found is all uppercase, lowercase, or proper case. 
---------------------------------------------------------------------------------------------------------------------------------------             
-- Remarks
-- You can specify where the replacement begins and how many replacements are made.
-- STRTRAN( ) returns the resulting character string. 
-- Specify –1 for optional parameters you want to skip over if you just need to specify the @nFlags setting.
-- Example
-- select dbo.STRTRAN(''ABCDEF'', ''ABC'', ''XYZ'',-1,-1,0)      -- Displays XYZDEF
-- select dbo.STRTRAN(''ABCDEF'', ''ABC'', default,-1,-1,0)    -- Displays DEF
-- select dbo.STRTRAN(''ABCDEFABCGHJabcQWE'', ''ABC'', default,2,-1,0)      -- Displays ABCDEFGHJabcQWE
-- select dbo.STRTRAN(''ABCDEFABCGHJabcQWE'', ''ABC'', default,2,-1,1)      -- Displays ABCDEFGHJQWE
-- select dbo.STRTRAN(''ABCDEFABCGHJabcQWE'', ''ABC'', ''XYZ'',  2, 1, 1)      -- Displays ABCDEFXYZGHJabcQWE
-- select dbo.STRTRAN(''ABCDEFABCGHJabcQWE'', ''ABC'', ''XYZ'',  2, 3, 1)      -- Displays ABCDEFXYZGHJXYZQWE
-- select dbo.STRTRAN(''ABCDEFABCGHJabcQWE'', ''ABC'', ''XYZ'',  2, 1, 2)      -- Displays ABCDEFXYZGHJabcQWE
-- select dbo.STRTRAN(''ABCDEFABCGHJabcQWE'', ''ABC'', ''XYZ'',  2, 3, 2)      -- Displays ABCDEFXYZGHJabcQWE
-- select dbo.STRTRAN(''ABCDEFABCGHJabcQWE'', ''ABC'', ''xyZ'',  2, 1, 2)      -- Displays ABCDEFXYZGHJabcQWE
-- select dbo.STRTRAN(''ABCDEFABCGHJabcQWE'', ''ABC'', ''xYz'',  2, 3, 2)      -- Displays ABCDEFXYZGHJabcQWE
-- select dbo.STRTRAN(''ABCDEFAbcCGHJAbcQWE'', ''Aab'', ''xyZ'',  2, 1, 2)     -- Displays ABCDEFAbcCGHJAbcQWE
-- select dbo.STRTRAN(''abcDEFabcGHJabcQWE'', ''abc'', ''xYz'',  2, 3, 2)      -- Displays abcDEFxyzGHJxyzQWE
-- select dbo.STRTRAN(''ABCDEFAbcCGHJAbcQWE'', ''Aab'', ''xyZ'',  2, 1, 3)     -- Displays ABCDEFAbcCGHJAbcQWE
-- select dbo.STRTRAN(''ABCDEFAbcGHJabcQWE'', ''abc'', ''xYz'',  1, 3, 3)      -- Displays XYZDEFXyzGHJxyzQWE
-- See Also replace(), CHRTRAN()  
-- UDF the name and functionality of which correspond  to the  Visual FoxPro function  
CREATE FUNCTION [dbo].[STRTRAN] 
   (@cSearched nvarchar(4000),  @cExpressionSought nvarchar(4000), @cReplacement nvarchar(4000) = N'''',
     @nStartOccurrence smallint = -1, @nNumberOfOccurrences smallint = -1, @nFlags tinyint = 0)
returns nvarchar(4000)
as
begin 
   declare @StartPart nvarchar(4000),  @FinishPart nvarchar(4000),  @nAtStartOccurrence smallint, @nAtFinishOccurrence smallint, @LencSearched smallint,  @LenExpressionSought smallint

   select   @StartPart = N'''',  @FinishPart = N'''',   @nAtStartOccurrence = 0, @nAtFinishOccurrence = 0,
               @LencSearched  = datalength(@cSearched)/(case SQL_VARIANT_PROPERTY(@cSearched,''BaseType'') when ''nvarchar'' then 2  else 1 end) ,
               @LenExpressionSought  = datalength(@cExpressionSought)/(case SQL_VARIANT_PROPERTY(@cExpressionSought,''BaseType'') when ''nvarchar'' then 2  else 1 end)  -- for unicode

if @nStartOccurrence = -1
  select @nStartOccurrence = 1

if @nFlags in ( 0, 2)
    select  @nAtStartOccurrence = dbo.AT2( @cExpressionSought,  @cSearched, @nStartOccurrence), 
               @nAtFinishOccurrence = case  @nNumberOfOccurrences  when -1 then 0  else   dbo.AT2( @cExpressionSought,  @cSearched, @nStartOccurrence + @nNumberOfOccurrences ) end
else
if @nFlags in (1, 3)
    select  @nAtStartOccurrence = dbo.ATC2( @cExpressionSought,  @cSearched, @nStartOccurrence), 
               @nAtFinishOccurrence = case  @nNumberOfOccurrences  when -1 then 0  else   dbo.ATC2( @cExpressionSought,  @cSearched, @nStartOccurrence + @nNumberOfOccurrences ) end
else 
  select @cSearched  =  ''Error, sixth parameter must be 0, 1, 2, 3 ! ''

   if @nAtStartOccurrence > 0
      begin
         select @StartPart = left(@cSearched, @nAtStartOccurrence - 1)
           if  @nAtFinishOccurrence  > 0
                   select @FinishPart =  right(@cSearched,  @LencSearched - @nAtFinishOccurrence + 1) , @cSearched = substring(@cSearched,  @nAtStartOccurrence, @nAtFinishOccurrence - @nAtStartOccurrence )
           else           
                 select  @cSearched = substring(@cSearched,  @nAtStartOccurrence, @LencSearched - @nAtStartOccurrence + 1)
     
          if @nFlags = 0 or (@nFlags = 2 and datalength(@cReplacement) = 0)
               select  @cSearched  = replace(@cSearched  COLLATE Latin1_General_BIN, 
                                                                 @cExpressionSought   COLLATE Latin1_General_BIN,
                                                                 @cReplacement   COLLATE Latin1_General_BIN   )  
          else
                if @nFlags = 1 or (@nFlags = 3 and datalength(@cReplacement) = 0)
                     select  @cSearched  = replace(@cSearched  COLLATE Latin1_General_CI_AS, 
                                                                        @cExpressionSought   COLLATE Latin1_General_CI_AS,
                                                                        @cReplacement   COLLATE Latin1_General_CI_AS  ) 
               else
                      if @nFlags in (2,  3)
                            begin
                                  declare @cNewSearched  nvarchar(4000) , @cNewExpressionSought  nvarchar(4000), @cNewReplacement   nvarchar(4000), 
                                               @nAtPreviousOccurrence smallint, @occurs2 smallint, @i smallint, @j smallint
                                  select @i = 1,  @cNewSearched = N'''',  @nAtPreviousOccurrence =  1,
                                             @LencSearched  = datalength(@cSearched)/(case SQL_VARIANT_PROPERTY(@cSearched,''BaseType'') when ''nvarchar'' then 2  else 1 end) ,
                                             @nAtStartOccurrence =  1 - @LenExpressionSought, 
                                              @occurs2 = case   when   @nFlags = 3
                                                                             then    ( datalength(@cSearched) 
                                                                                        - datalength(replace(@cSearched  COLLATE Latin1_General_CI_AS, 
                                                                                          @cExpressionSought   COLLATE Latin1_General_CI_AS,  N'''')))  / datalength(@cExpressionSought)
                                                                             else  dbo.OCCURS2( @cExpressionSought,  @cSearched)  end
                                   while @i  <= @occurs2
                                        begin
                                              select  @nAtStartOccurrence = case 
                                                                                                 when   @nFlags = 3
                                                                                                 then    charindex(@cExpressionSought COLLATE Latin1_General_CI_AS, @cSearched COLLATE Latin1_General_CI_AS,  @nAtStartOccurrence + @LenExpressionSought)
                                                                                                 else     charindex(@cExpressionSought COLLATE Latin1_General_BIN, @cSearched COLLATE Latin1_General_BIN,  @nAtStartOccurrence + @LenExpressionSought ) end
                                              select @cNewSearched  = @cNewSearched + case
                                                                                                                          when @i > 1
                                                                                                                          then  substring(@cSearched,  @nAtPreviousOccurrence + @LenExpressionSought, @nAtStartOccurrence  - (@nAtPreviousOccurrence + @LenExpressionSought) )  
                                                                                                                          else  left(@cSearched, @nAtStartOccurrence - 1)  end ,
                                                        @cNewExpressionSought = substring(@cSearched,  @nAtStartOccurrence, @LenExpressionSought)
                                              select @cNewReplacement  =  case
                                                                                                when  lower(@cNewExpressionSought) = upper(@cNewExpressionSought)  -- no letters in string
                                                                                                then  @cReplacement
                                                                                                when  @cNewExpressionSought = upper(@cNewExpressionSought) 
                                                                                                then upper(@cReplacement)
                                                                                                when  @cNewExpressionSought = lower(@cNewExpressionSought) 
                                                                                                then  lower(@cReplacement)
                                                                                                else NULL  end
                                              if  @cNewReplacement is NULL
                                                     if upper(substring( @cNewExpressionSought, 1, 1) )  <> lower(substring( @cNewExpressionSought, 1, 1) )  and
                                                           upper(substring( @cNewExpressionSought, 1, 1) )  =  substring( @cNewExpressionSought, 1, 1)   and
                                                           lower(substring( @cNewExpressionSought, 2,  @LenExpressionSought - 1) )  = substring( @cNewExpressionSought, 2,  @LenExpressionSought - 1)
                                                                      select @cNewReplacement  =  upper(substring( @cReplacement, 1, 1) )+   lower(substring( @cReplacement, 2,  
                                                                                 datalength(@cReplacement)/(case SQL_VARIANT_PROPERTY(@cSearched,''BaseType'') when ''nvarchar'' then 2  else 1 end)  - 1) ) 
                                               else
                                                    begin
                                                          select @j = 1
                                                           while @j   <= @LenExpressionSought
                                                                begin  
                                                                      if upper(substring( @cNewExpressionSought, @j, 1) )  <> lower(substring( @cNewExpressionSought, @j, 1) )   -- this is letter    
                                                                           begin 
                                                                                if substring( @cNewExpressionSought, @j, 1)  =  lower(substring( @cNewExpressionSought, @j, 1) ) 
                                                                                    select @cNewReplacement  =   lower(@cReplacement)
                                                                               else
                                                                                    select @cNewReplacement  =  @cReplacement
                                                                                break
                                                                          end
                                                                      select @j = @j + 1                 
                                                                end
                                                    end
                                               if  @cNewReplacement is NULL
                                                     select @cNewReplacement  =  @cReplacement
                                              select @cNewSearched  = @cNewSearched + @cNewReplacement, @nAtPreviousOccurrence = @nAtStartOccurrence, @i = @i + 1
                                        end
                                  select  @cSearched = @cNewSearched  +  right(@cSearched,  @LencSearched +1 - (@nAtStartOccurrence + @LenExpressionSought) )
                            end
   end
  return  @StartPart + @cSearched + @FinishPart
end
' 
END

GO
/****** Object:  Table [dbo].[ApprovalValues]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ApprovalValues]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ApprovalValues](
	[Amount] [smallint] NOT NULL,
	[Tires] [smallint] NOT NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [dbo].[CodeRelations]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CodeRelations](
	[CodeRelationId] [int] IDENTITY(1,1) NOT NULL,
	[RelationType] [char](2) NOT NULL,
	[ParentCode] [varchar](20) NOT NULL,
	[ChildCode] [varchar](20) NOT NULL,
	[Category] [varchar](20) NULL,
	[SubCategory] [varchar](30) NULL,
	[Location] [varchar](15) NULL,
 CONSTRAINT [PK_CodeRelations_Primary] PRIMARY KEY CLUSTERED 
(
	[CodeRelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Customers]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Customers](
	[AccountId] [int] IDENTITY(1,1) NOT NULL,
	[Acct_No] [varchar](15) NOT NULL,
	[Acct_Name] [varchar](50) NOT NULL,
	[Sales] [numeric](18, 2) NOT NULL,
	[Inactive] [bit] NOT NULL,
	[Percentage] [smallint] NOT NULL,
 CONSTRAINT [PK_Accounts_New_Primary] PRIMARY KEY CLUSTERED 
(
	[AccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DamageCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DamageCodes]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DamageCodes](
	[DamageCode] [nvarchar](10) NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[Category] [varchar](25) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Depots]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Depots]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Depots](
	[Depot] [nchar](10) NOT NULL,
	[Depot_Loc] [nchar](15) NOT NULL,
	[Location] [varchar](25) NULL,
	[Use_Mech] [bit] NOT NULL,
	[Prefix] [char](3) NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EquipmentSize]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EquipmentSize]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[EquipmentSize](
	[EquipmentSizeId] [int] IDENTITY(1,1) NOT NULL,
	[EquipmentSize] [varchar](10) NOT NULL,
	[Inactive] [bit] NOT NULL,
 CONSTRAINT [PK_EquipmentSize] PRIMARY KEY CLUSTERED 
(
	[EquipmentSizeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[JobCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[JobCodes]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[JobCodes](
	[JobCode] [varchar](25) NOT NULL,
	[Description] [varchar](75) NULL,
	[Category] [varchar](50) NULL,
	[Cost] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_JobCodes] PRIMARY KEY CLUSTERED 
(
	[JobCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Locations]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Locations]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Locations](
	[LocationId] [int] IDENTITY(1,1) NOT NULL,
	[Location] [varchar](25) NOT NULL,
	[SubLocation] [varchar](40) NULL,
	[CustomerNumber] [varchar](10) NULL,
	[Prefix] [char](3) NULL,
 CONSTRAINT [PK_Locations_Primary] PRIMARY KEY CLUSTERED 
(
	[LocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Mech]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Mech]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Mech](
	[mech_no] [varchar](8) NOT NULL,
	[fname] [varchar](20) NULL,
	[lname] [varchar](20) NULL,
	[depot_loc] [varchar](15) NULL,
	[phone_no] [varchar](12) NULL,
	[active] [bit] NOT NULL,
	[mech_type] [varchar](2) NULL,
	[Password] [varchar](15) NULL,
 CONSTRAINT [PK_Mech] PRIMARY KEY CLUSTERED 
(
	[mech_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Positions]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Positions]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Positions](
	[Category] [varchar](20) NOT NULL,
	[Position] [varchar](6) NOT NULL,
	[Inactive] [bit] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RepairCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RepairCodes]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RepairCodes](
	[RepairCode] [nvarchar](5) NOT NULL,
	[Description] [nvarchar](100) NULL,
	[Category] [varchar](25) NULL,
 CONSTRAINT [PK_RepairCodes] PRIMARY KEY CLUSTERED 
(
	[RepairCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Repairs]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Repairs]') AND type in (N'U'))
BEGIN
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
	[SubmittedOn] [datetime] NULL,
	[Container] [varchar](15) NULL,
	[ContainerMounted] [bit] NULL,
	[Lot_Road] [varchar](15) NULL,
	[FMCSA] [date] NULL,
	[BIDStatus] [smallint] NOT NULL,
	[BIDEstimate] [int] NULL,
	[TestRecord] [bit] NOT NULL,
 CONSTRAINT [PK_Repairs] PRIMARY KEY CLUSTERED 
(
	[Consecutive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RepairsDetails]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RepairsDetails]') AND type in (N'U'))
BEGIN
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
	[DOTIn] [varchar](15) NULL,
	[DOTOut] [varchar](15) NULL,
	[SubCategory] [varchar](30) NULL,
	[RecapperOn] [varchar](15) NULL,
	[RecapperOff] [varchar](15) NULL,
	[Position] [varchar](5) NULL,
	[ItemCost] [decimal](12, 2) NOT NULL,
	[ActualCost] [decimal](12, 2) NOT NULL,
	[BIDItemCompleted] [bit] NOT NULL,
 CONSTRAINT [PK_RepairDetails_Primary] PRIMARY KEY CLUSTERED 
(
	[RepairDetailsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RepairsPictures]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RepairsPictures]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RepairsPictures](
	[RepairsPictureId] [int] IDENTITY(1,1) NOT NULL,
	[Consecutive] [int] NOT NULL,
	[PictureFileName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_RepairPictures] PRIMARY KEY CLUSTERED 
(
	[RepairsPictureId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SubCategories]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SubCategories]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SubCategories](
	[Category] [varchar](20) NOT NULL,
	[SubCategory] [varchar](30) NOT NULL,
	[RequiresPosition] [bit] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Translation]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Translation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Translation](
	[TranslationId] [int] IDENTITY(1,1) NOT NULL,
	[FormName] [varchar](50) NOT NULL,
	[ObjectName] [varchar](50) NOT NULL,
	[English] [varchar](250) NOT NULL,
	[Spanish] [varchar](250) NULL,
 CONSTRAINT [PK_Translation_Primary] PRIMARY KEY CLUSTERED 
(
	[TranslationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[View_CodeRelations]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_CodeRelations]'))
EXEC dbo.sp_executesql @statement = N'

/*
SELECT * FROM View_CodeRelations
*/
CREATE VIEW [dbo].[View_CodeRelations]
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
WHERE	RelationType = ''JC''
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
WHERE	RelationType = ''RC''
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
WHERE	RelationType = ''DC''
' 
GO
/****** Object:  View [dbo].[View_CustomerByLocation]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_CustomerByLocation]'))
EXEC dbo.sp_executesql @statement = N'
/*
SELECT * FROM View_CustomerByLocation
*/
CREATE VIEW [dbo].[View_CustomerByLocation]
AS
SELECT	CUS.Acct_No
		,CUS.Acct_Name
		,DEP.Depot_Loc
		,RTRIM(DEP.Depot_Loc) AS Location
		,LOC.SubLocation
		,CUS.Sales
		,CUS.Inactive
FROM	Customers CUS
		INNER JOIN Depots DEP ON LEFT(CUS.Acct_No, 3) = DEP.Prefix
		LEFT JOIN Locations LOC ON DEP.Depot_Loc = LOC.Location AND CUS.Acct_No = LOC.CustomerNumber
' 
GO
/****** Object:  View [dbo].[View_JobCodes]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_JobCodes]'))
EXEC dbo.sp_executesql @statement = N'
/*
SELECT * FROM View_JobCodes 
*/
CREATE VIEW [dbo].[View_JobCodes]
AS
SELECT	JobCode,
		ISNULL(Description, JobCode) AS Description,
		CASE WHEN JobCode <> Description THEN RTRIM(Description) + ''  ['' + RTRIM(JobCode) + '']'' ELSE JobCode END AS JobText,
		Category
FROM	JobCodes JC


' 
GO
/****** Object:  View [dbo].[View_Locations]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_Locations]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[View_Locations]
AS
SELECT	LOC.Location
		,LOC.SubLocation
		,LOC.CustomerNumber
		,CUS.Acct_Name AS CustomerName
FROM	Locations LOC
		LEFT JOIN Customers CUS ON LOC.CustomerNumber = CUS.Acct_No
'
GO

/****** Object:  StoredProcedure [dbo].[USP_Synchronize_Codes]    Script Date: 08/07/2012 10:56:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Synchronize_Codes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'/*
******************************************
Synchronize Server Codes Codes with the 
local database
******************************************
EXECUTE USP_Synchronize_Codes
******************************************
*/
CREATE PROCEDURE [dbo].[USP_Synchronize_Codes] (@Location Varchar(15) = Null)
AS
DECLARE	@SERVERONLINE Bit

BEGIN TRY
     SELECT @SERVERONLINE = ServerRunning 
     FROM	ILSINT02.FI_Data.dbo.ServerRunning
END TRY
BEGIN CATCH
     SET @SERVERONLINE = 0
END CATCH

IF @SERVERONLINE = 1
BEGIN
	IF RTRIM(@Location) = ''''
		SET @Location = NULL

	EXECUTE USP_Synchronize_DamageCodes
	EXECUTE USP_Synchronize_JobCodes
	EXECUTE USP_Synchronize_RepairCodes
	
	PRINT ''*** SUBCATEGORIES ***''
	TRUNCATE TABLE SubCategories
	
	INSERT INTO SubCategories
	SELECT	*
	FROM	ILSINT02.FI_Data.dbo.SubCategories
	
	PRINT ''*** POSITIONS ***''
	TRUNCATE TABLE Positions
	
	INSERT INTO Positions
	SELECT	*
	FROM	ILSINT02.FI_Data.dbo.Positions
	
	PRINT ''*** LOCATIONS ***''
	TRUNCATE TABLE Locations
	
	INSERT INTO Locations 
			(Location
			,SubLocation
			,CustomerNumber
			,Prefix)
	SELECT	Location
			,SubLocation
			,CustomerNumber
			,Prefix
	FROM	ILSINT02.FI_Data.dbo.Locations
	
	TRUNCATE TABLE CodeRelations

	PRINT ''*** CODE RELATIONS ***''
	
	INSERT INTO CodeRelations (RelationType, ParentCode, ChildCode, Category, SubCategory, Location)
	SELECT	RelationType, ParentCode, ChildCode, Category, SubCategory, Location
	FROM	ILSINT02.FI_Data.dbo.CodeRelations
	WHERE	@Location IS NULL
			OR (@Location IS NOT NULL AND Location = @Location)

	PRINT ''*** MECHANICS ***''
	SELECT	*
	INTO	#tmpMech
	FROM	ILSINT02.FI_Data.dbo.Mech

	UPDATE	Mech
	SET		FName		 = #tmpMech.FName,
			LName		= #tmpMech.LName,
			Depot_Loc	= #tmpMech.Depot_Loc,
			Active		= #tmpMech.Active,
			Password	= #tmpMech.Password
	FROM	#tmpMech
	WHERE	Mech.Mech_No = #tmpMech.Mech_No

	INSERT INTO Mech
	SELECT	*
	FROM	#tmpMech
	WHERE	Mech_No NOT IN (SELECT Mech_No FROM Mech)

	DROP TABLE #tmpMech

	PRINT ''*** TRANSLATIONS ***''
	SELECT	*
	INTO	#tmpTranslation
	FROM	ILSINT02.FI_Data.dbo.Translation

	UPDATE	Translation
	SET		FormName	= #tmpTranslation.FormName, 
			ObjectName	= #tmpTranslation.ObjectName, 
			English		= #tmpTranslation.English, 
			Spanish		= #tmpTranslation.Spanish
	FROM	#tmpTranslation
	WHERE	RTRIM(Translation.FormName) + ''_'' + RTRIM(Translation.ObjectName) = RTRIM(#tmpTranslation.FormName) + ''_'' + RTRIM(#tmpTranslation.ObjectName)

	INSERT INTO Translation (FormName, ObjectName, English, Spanish)
	SELECT	FormName, ObjectName, English, Spanish
	FROM	#tmpTranslation
	WHERE	RTRIM(FormName) + ''_'' + RTRIM(ObjectName) NOT IN (SELECT RTRIM(FormName) + ''_'' + RTRIM(ObjectName) FROM Translation)

	DROP TABLE #tmpTranslation

	PRINT ''*** DEPOTS ***''
	TRUNCATE TABLE Depots

	SELECT	*
	INTO	#tmpDepots
	FROM	ILSINT02.FI_Data.dbo.Depots

	INSERT INTO Depots
	SELECT	Depot
			,Depot_Loc
			,Location
			,Use_Mech
			,Prefix
	FROM	#tmpDepots

	DROP TABLE #tmpDepots

	PRINT ''*** CUSTOMERS ***''
	SELECT	Acct_No, Acct_Name, Sales, Inactive, Percentage
	INTO	#tmpCustomers
	FROM	ILSINT02.FI_Data.dbo.Customers
	WHERE	LEFT(Acct_No, 3) IN (SELECT Prefix FROM Depots WHERE Depot_Loc = @Location)

	UPDATE	Customers
	SET		Acct_Name	= #tmpCustomers.Acct_Name, 
			Sales		= #tmpCustomers.Sales, 
			Inactive	= #tmpCustomers.Inactive,
			Percentage	= #tmpCustomers.Percentage
	FROM	#tmpCustomers
	WHERE	Customers.Acct_No = #tmpCustomers.Acct_No

	INSERT INTO Customers
		(Acct_No,
		 Acct_Name,
		 Sales,
		 Inactive,
		 Percentage)
	SELECT	*
	FROM	#tmpCustomers
	WHERE	Acct_No NOT IN (SELECT Acct_No FROM Customers)

	DROP TABLE #tmpCustomers

	PRINT ''*** CUSTOMERS ***''
	SELECT	Amount, Tires
	INTO	#tmpApprovals
	FROM	ILSINT02.FI_Data.dbo.ApprovalValues

	UPDATE	ApprovalValues
	SET		ApprovalValues.Amount	= #tmpApprovals.Amount,
			ApprovalValues.Tires	= #tmpApprovals.Tires
	FROM	#tmpApprovals

	DROP TABLE #tmpApprovals

	PRINT ''*** EQUIPMENT SIZE ***''
	SELECT	*
	INTO	#tmpEqSize
	FROM	ILSINT02.FI_Data.dbo.EquipmentSize

	UPDATE	EquipmentSize
	SET		EquipmentSize.Inactive = #tmpEqSize.Inactive
	FROM	#tmpEqSize
	WHERE	EquipmentSize.EquipmentSize = #tmpEqSize.EquipmentSize

	INSERT INTO EquipmentSize (EquipmentSize, Inactive)
	SELECT EquipmentSize, Inactive 
	FROM	#tmpEqSize 
	WHERE	EquipmentSize NOT IN (SELECT EquipmentSize FROM EquipmentSize)

	DROP TABLE #tmpEqSize
END' 
END
GO

SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CodeRelations_Category]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND name = N'IX_CodeRelations_Category')
CREATE NONCLUSTERED INDEX [IX_CodeRelations_Category] ON [dbo].[CodeRelations]
(
	[Category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CodeRelations_Child]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND name = N'IX_CodeRelations_Child')
CREATE NONCLUSTERED INDEX [IX_CodeRelations_Child] ON [dbo].[CodeRelations]
(
	[ChildCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CodeRelations_Location]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND name = N'IX_CodeRelations_Location')
CREATE NONCLUSTERED INDEX [IX_CodeRelations_Location] ON [dbo].[CodeRelations]
(
	[Location] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CodeRelations_Parent]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND name = N'IX_CodeRelations_Parent')
CREATE NONCLUSTERED INDEX [IX_CodeRelations_Parent] ON [dbo].[CodeRelations]
(
	[ParentCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CodeRelations_Type]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CodeRelations]') AND name = N'IX_CodeRelations_Type')
CREATE NONCLUSTERED INDEX [IX_CodeRelations_Type] ON [dbo].[CodeRelations]
(
	[RelationType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Accounts_Account]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Customers]') AND name = N'IX_Accounts_Account')
CREATE NONCLUSTERED INDEX [IX_Accounts_Account] ON [dbo].[Customers]
(
	[Acct_No] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_JobCodes_Category]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[JobCodes]') AND name = N'IX_JobCodes_Category')
CREATE NONCLUSTERED INDEX [IX_JobCodes_Category] ON [dbo].[JobCodes]
(
	[Category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Locations_Location_Prefix]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Locations]') AND name = N'IX_Locations_Location_Prefix')
CREATE NONCLUSTERED INDEX [IX_Locations_Location_Prefix] ON [dbo].[Locations]
(
	[Prefix] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Locations_SubLocation]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Locations]') AND name = N'IX_Locations_SubLocation')
CREATE NONCLUSTERED INDEX [IX_Locations_SubLocation] ON [dbo].[Locations]
(
	[SubLocation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Repair_Consecutive]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Repairs]') AND name = N'IX_Repair_Consecutive')
CREATE NONCLUSTERED INDEX [IX_Repair_Consecutive] ON [dbo].[Repairs]
(
	[Consecutive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Repair_WorkOrder]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Repairs]') AND name = N'IX_Repair_WorkOrder')
CREATE NONCLUSTERED INDEX [IX_Repair_WorkOrder] ON [dbo].[Repairs]
(
	[WorkOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RepairDetails_Consecutive]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RepairsDetails]') AND name = N'IX_RepairDetails_Consecutive')
CREATE NONCLUSTERED INDEX [IX_RepairDetails_Consecutive] ON [dbo].[RepairsDetails]
(
	[Consecutive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Translation_FormName]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Translation]') AND name = N'IX_Translation_FormName')
CREATE NONCLUSTERED INDEX [IX_Translation_FormName] ON [dbo].[Translation]
(
	[FormName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Translation_ObjectName]    Script Date: 08/07/2012 10:56:22 AM ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Translation]') AND name = N'IX_Translation_ObjectName')
CREATE NONCLUSTERED INDEX [IX_Translation_ObjectName] ON [dbo].[Translation]
(
	[ObjectName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_CodeRelations_Category]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[CodeRelations] ADD  CONSTRAINT [DF_CodeRelations_Category]  DEFAULT ('TIRES') FOR [Category]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Customers_Sales]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [DF_Customers_Sales]  DEFAULT ((0)) FOR [Sales]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Customers_Inactive]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [DF_Customers_Inactive]  DEFAULT ((0)) FOR [Inactive]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Customers_Percentage]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [DF_Customers_Percentage]  DEFAULT ((100)) FOR [Percentage]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_EquipmentSize_Inactive]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[EquipmentSize] ADD  CONSTRAINT [DF_EquipmentSize_Inactive]  DEFAULT ((0)) FOR [Inactive]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_JobCodes_Cost]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[JobCodes] ADD  CONSTRAINT [DF_JobCodes_Cost]  DEFAULT ((0)) FOR [Cost]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Positions_Inactive]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Positions] ADD  CONSTRAINT [DF_Positions_Inactive]  DEFAULT ((0)) FOR [Inactive]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repair_Consecutive]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repair_Consecutive]  DEFAULT ((0)) FOR [Consecutive]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repair_RepairStatus]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repair_RepairStatus]  DEFAULT ('HH') FOR [RepairStatus]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repair_ChassisInspection]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repair_ChassisInspection]  DEFAULT ((0)) FOR [ChassisInspection]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repairs_ForSubmitting]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repairs_ForSubmitting]  DEFAULT ((0)) FOR [ForSubmitting]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repair_CreationDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repair_CreationDate]  DEFAULT (getdate()) FOR [CreationDate]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repair_ModificationDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repair_ModificationDate]  DEFAULT (getdate()) FOR [ModificationDate]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repairs_BIDStatus]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repairs_BIDStatus]  DEFAULT ((0)) FOR [BIDStatus]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Repairs_TestRecord]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Repairs] ADD  CONSTRAINT [DF_Repairs_TestRecord]  DEFAULT ((0)) FOR [TestRecord]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Sale_Equip_Id]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RepairsDetails] ADD  CONSTRAINT [DF_Sale_Equip_Id]  DEFAULT ((1)) FOR [LineItem]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Sale_DamageWidth]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RepairsDetails] ADD  CONSTRAINT [DF_Sale_DamageWidth]  DEFAULT ((0)) FOR [DamageWidth]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_RepairsDetails_ItemCost]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RepairsDetails] ADD  CONSTRAINT [DF_RepairsDetails_ItemCost]  DEFAULT ((0)) FOR [ItemCost]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_RepairsDetails_ActualCost]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RepairsDetails] ADD  CONSTRAINT [DF_RepairsDetails_ActualCost]  DEFAULT ((0)) FOR [ActualCost]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_RepairsDetails_BIDItemCompleted]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[RepairsDetails] ADD  CONSTRAINT [DF_RepairsDetails_BIDItemCompleted]  DEFAULT ((0)) FOR [BIDItemCompleted]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_SubCategories_RequiresPosition]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[SubCategories] ADD  CONSTRAINT [DF_SubCategories_RequiresPosition]  DEFAULT ((0)) FOR [RequiresPosition]
END

GO

USE [master]
GO
ALTER DATABASE [MobileEstimates] SET  READ_WRITE 
GO

USE [MobileEstimates]
GO

EXECUTE USP_Synchronize_Codes
