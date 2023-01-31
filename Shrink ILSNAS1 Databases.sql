USE TimeClockPlus;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE TimeClockPlus
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE TimeClockPlus
SET RECOVERY FULL;
GO

USE TCPCustom;
GO
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE TCPCustom
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO
-- Reset the database recovery model.
ALTER DATABASE TCPCustom
SET RECOVERY FULL;
GO