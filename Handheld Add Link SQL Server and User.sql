USE [master]
GO

EXECUTE sp_addlinkedserver @server = N'ILSINT02', @srvproduct=N'SQL Server' ;
GO

EXECUTE sp_addlinkedsrvlogin @rmtsrvname = N'ILSINT02', @useself = 'FALSE', @rmtuser = 'ADGSA', @rmtpassword = N'ILSMemphis201202' ;
GO

EXECUTE sp_serveroption @server = N'ILSINT02', @optname = 'collation compatible', @optvalue = 'TRUE';
GO

EXECUTE sp_serveroption @server = N'ILSINT02', @optname = 'data access', @optvalue = 'TRUE';
GO

EXECUTE sp_serveroption @server = N'ILSINT02', @optname = 'rpc', @optvalue = 'TRUE';
GO

EXECUTE sp_serveroption @server = N'ILSINT02', @optname = 'rpc out', @optvalue = 'TRUE';
GO

CREATE LOGIN MobileUser WITH PASSWORD = 'memphis1' ;
GO

USE [MobileEstimates]
GO

EXECUTE USP_ClearEntryTables;
GO

IF EXISTS(SELECT * FROM SysUsers WHERE Name = 'MobileUser')
	EXECUTE sp_dropuser @name_in_db = 'MobileUser'
GO

CREATE USER MobileUser FOR LOGIN MobileUser WITH DEFAULT_SCHEMA = dbo;
GO

EXECUTE sp_addrolemember @rolename = 'db_owner', @membername = 'MobileUser' ;
GO