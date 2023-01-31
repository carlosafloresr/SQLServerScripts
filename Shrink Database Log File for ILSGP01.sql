USE DYNAMICS;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE DYNAMICS
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE DYNAMICS
SET RECOVERY FULL;

USE GPCustom;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE GPCustom
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE GPCustom
SET RECOVERY FULL;

USE Intranet;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Intranet
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE Intranet
SET RECOVERY FULL;

USE IMC;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE IMC
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE IMC
SET RECOVERY FULL;

USE ATEST;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE ATEST
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE ATEST
SET RECOVERY FULL;

USE FIDMO;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE FIDMO
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE FIDMO
SET RECOVERY FULL;

USE DNJ;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE DNJ
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE DNJ
SET RECOVERY FULL;


USE GIS;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE GIS
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE GIS
SET RECOVERY FULL;


USE FI;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE FI
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE FI
SET RECOVERY FULL;


USE RCMR;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE RCMR
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE RCMR
SET RECOVERY FULL;


USE IILS;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE IILS
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE IILS
SET RECOVERY FULL;


USE NDS;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE NDS
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE NDS
SET RECOVERY FULL;


USE [ABS];

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE [ABS]
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE [ABS]
SET RECOVERY FULL;


USE AIS;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE AIS
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE AIS
SET RECOVERY FULL;


USE RCCL;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE RCCL
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE RCCL
SET RECOVERY FULL;

USE ILS_Datawarehouse;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE ILS_Datawarehouse
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE ILS_Datawarehouse
SET RECOVERY FULL;

USE GLSO;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE GLSO
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE GLSO
SET RECOVERY FULL;

USE COIMC;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE COIMC
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE COIMC
SET RECOVERY FULL;

USE IMCC;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE IMCC
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE IMCC
SET RECOVERY FULL;

USE MCCP;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE MCCP
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE MCCP
SET RECOVERY FULL;

USE MHG;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE MHG
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE MHG
SET RECOVERY FULL;

USE MIT;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE MIT
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE MIT
SET RECOVERY FULL;

USE OIS;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE OIS
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE OIS
SET RECOVERY FULL;

USE PTS;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE PTS
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE PTS
SET RECOVERY FULL;

USE CollectIT;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE CollectIT
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE CollectIT
SET RECOVERY FULL;

USE GSA;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE GSA
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE GSA
SET RECOVERY FULL;