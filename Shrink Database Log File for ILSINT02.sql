USE Integrations
	
-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE Integrations
SET RECOVERY SIMPLE;
	
-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);
	
-- Reset the database recovery model.
ALTER DATABASE Integrations
SET RECOVERY FULL;