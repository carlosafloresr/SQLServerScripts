EXECUTE sp_MSforeachtable @command1="PRINT '?' DBCC DBREINDEX ('?', ' ', 80)"
GO

EXECUTE sp_updatestats
GO