USE LoadMaster;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE LoadMaster
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE LoadMaster
SET RECOVERY FULL;

USE ReportServer;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE ReportServer
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE ReportServer
SET RECOVERY FULL;


USE ReportServerTempDB;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE ReportServerTempDB
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE ReportServerTempDB
SET RECOVERY FULL;

USE SSISDB;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE SSISDB
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE SSISDB
SET RECOVERY FULL;