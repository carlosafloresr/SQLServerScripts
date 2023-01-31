USE Drivers;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Drivers
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE Drivers
SET RECOVERY FULL;


USE DriverFiles;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE DriverFiles
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE DriverFiles
SET RECOVERY FULL;


USE EmployeeFiles;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE EmployeeFiles
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE EmployeeFiles
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


USE Accounting;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Accounting
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE Accounting
SET RECOVERY FULL;


USE Claims;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Claims
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE Claims
SET RECOVERY FULL;


USE Insurance;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Insurance
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE Insurance
SET RECOVERY FULL;


USE Vopes;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Vopes
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE Vopes
SET RECOVERY FULL;