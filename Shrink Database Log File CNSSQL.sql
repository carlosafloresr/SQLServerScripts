/*
EXECUTE USP_ShrinkDatabaseLogFiles
*/
CREATE PROCEDURE USP_ShrinkDatabaseLogFiles
AS
--USE BP_Content;
--
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE BP_Content
SET RECOVERY SIMPLE;
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
-- Reset the database recovery model.
ALTER DATABASE BP_Content
SET RECOVERY FULL;


--USE SharePoint_Config;
--
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE SharePoint_Config
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE SharePoint_Config
SET RECOVERY FULL;


--USE [SharePoint_AdminContent_29b3539c-0406-45aa-b99c-264be9a7ba23];
--
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE [SharePoint_AdminContent_29b3539c-0406-45aa-b99c-264be9a7ba23]
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE [SharePoint_AdminContent_29b3539c-0406-45aa-b99c-264be9a7ba23]
SET RECOVERY FULL;


--USE [StateService_c1c0428bdb5e4b19b76517c2bc103a07];
--
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE [StateService_c1c0428bdb5e4b19b76517c2bc103a07]
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE [StateService_c1c0428bdb5e4b19b76517c2bc103a07]
SET RECOVERY FULL;
