ALTER DATABASE DirectorSeries
SET RECOVERY SIMPLE;
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
-- Reset the database recovery model.
ALTER DATABASE DirectorSeries
SET RECOVERY FULL;