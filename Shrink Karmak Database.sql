ALTER DATABASE DirectorSeries
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
GO