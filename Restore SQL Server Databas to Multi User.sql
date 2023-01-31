DECLARE	@SPId	Int

SET @SPId = (SELECT TOP 1 spid FROM sysprocesses p INNER JOIN sysdatabases d ON p.dbid = d.dbid WHERE d.name = 'DocumentApproval')

KILL @SPId
GO

ALTER DATABASE DocumentApproval
SET MULTI_USER;
GO