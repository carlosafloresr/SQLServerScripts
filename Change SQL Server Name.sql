EXECUTE sp_dropserver 'PRISQL01P' -- Old SQL Server Name 
GO
EXECUTE sp_addserver 'SECSQL01T', local -- New SQL Server Name
GO
select * from sys.servers
-- PRINT @@SERVERNAME 