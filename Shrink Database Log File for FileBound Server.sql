USE FB;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE FB
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE FB
SET RECOVERY FULL;

USE FileBound;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE FileBound
SET RECOVERY SIMPLE;

-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (2, 1);

-- Reset the database recovery model.
ALTER DATABASE FileBound
SET RECOVERY FULL;