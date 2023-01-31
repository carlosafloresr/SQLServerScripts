USE [master]
GO

/****** Object:  LinkedServer [DSSQL3.DEPOTSYSTEMS.COM,443]    Script Date: 5/11/2021 1:20:58 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DSSQL3.DEPOTSYSTEMS.COM,443', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DSSQL3.DEPOTSYSTEMS.COM,443',@useself=N'False',@locallogin=NULL,@rmtuser=N'gis_user3874',@rmtpassword='Ghuywwhow372#'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'collation compatible', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DSSQL3.DEPOTSYSTEMS.COM,443', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

