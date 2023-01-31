USE [master]
GO
EXEC sp_msforeachdb 'USE [?]; EXEC sp_Drop_OrphanedUsers'