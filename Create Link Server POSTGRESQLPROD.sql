USE [master]
GO

/****** Object:  LinkedServer [POSTGRESQLPROD]    Script Date: 3/15/2022 4:16:35 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'POSTGRESQLPROD', @srvproduct=N'POSTGRESQLPROD', @provider=N'MSDASQL', @datasrc=N'POSTGRESQLPROD', @location=N'swsdbv.iilogistics.com', @catalog=N'dta'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'POSTGRESQLPROD',@useself=N'False',@locallogin=NULL,@rmtuser=N'ilsprod',@rmtpassword='gr8sushi4U'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'collation compatible', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


