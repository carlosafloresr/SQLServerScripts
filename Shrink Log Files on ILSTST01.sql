--***********************************************************
--**                    I L S T S T 0 1                    **
--***********************************************************

USE Drivers;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Drivers
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE Drivers
SET RECOVERY FULL;
GO

USE DriverFiles;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE DriverFiles
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE DriverFiles
SET RECOVERY FULL;
GO

USE EmployeeFiles;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE EmployeeFiles
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE EmployeeFiles
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

USE Accounting;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Accounting
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE Accounting
SET RECOVERY FULL;
GO

USE Claims;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Claims
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE Claims
SET RECOVERY FULL;
GO

USE Insurance;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Insurance
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE Insurance
SET RECOVERY FULL;
GO

USE Vopes;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Vopes
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE Vopes
SET RECOVERY FULL;
GO