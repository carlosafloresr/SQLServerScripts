--***********************************************************
--**                    I L S G P 0 1                      **
--***********************************************************

USE ADG;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE ADG
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE ADG
SET RECOVERY FULL;
GO

USE Intranet;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Intranet
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE Intranet
SET RECOVERY FULL;
GO

USE DYNAMICS;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE DYNAMICS
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE DYNAMICS
SET RECOVERY FULL;
GO

USE GPCustom;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE GPCustom
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE GPCustom
SET RECOVERY FULL;
GO

USE IMC;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE IMC
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE IMC
SET RECOVERY FULL;
GO

USE DNJ;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE DNJ
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE DNJ
SET RECOVERY FULL;
GO

USE GIS;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE GIS
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE GIS
SET RECOVERY FULL;
GO

USE FI;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE FI
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE FI
SET RECOVERY FULL;
GO

USE RCMR;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE RCMR
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE RCMR
SET RECOVERY FULL;
GO

USE IILS;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE IILS
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE IILS
SET RECOVERY FULL;
GO

USE NDS;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE NDS
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE NDS
SET RECOVERY FULL;
GO

USE [ABS];
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE [ABS]
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE [ABS]
SET RECOVERY FULL;
GO

USE AIS;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE AIS
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE AIS
SET RECOVERY FULL;
GO

USE RCCL;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE RCCL
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE RCCL
SET RECOVERY FULL;
GO

USE COIMC;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE COIMC
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE COIMC
SET RECOVERY FULL;
GO

USE ATEST;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE ATEST
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE ATEST
SET RECOVERY FULL;
GO

USE FIDMO;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE FIDMO
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE FIDMO
SET RECOVERY FULL;
GO

USE IMCC;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE IMCC
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE IMCC
SET RECOVERY FULL;
GO

USE MHG;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE MHG
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE MHG
SET RECOVERY FULL;
GO

USE MIT;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE MIT
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE MIT
SET RECOVERY FULL;
GO

USE ILS_Datawarehouse;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE ILS_Datawarehouse
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE ILS_Datawarehouse
SET RECOVERY FULL;
GO

USE RCCON;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE RCCON
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE RCCON
SET RECOVERY FULL;
GO

USE ManagementReporter;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE ManagementReporter
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE ManagementReporter
SET RECOVERY FULL;
GO

USE ManagementReporterDM;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE ManagementReporterDM
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE ManagementReporterDM
SET RECOVERY FULL;
GO