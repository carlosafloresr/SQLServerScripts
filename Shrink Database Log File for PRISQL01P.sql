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

USE ILS_Datawarehouse;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE ILS_Datawarehouse
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE ILS_Datawarehouse
SET RECOVERY FULL;