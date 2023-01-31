USE [master]
GO

/****** Object:  LinkedServer [POSTGRESQLPROD_RO]    Script Date: 3/15/2022 3:58:36 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'POSTGRESQLPROD_RO', @srvproduct=N'PostgreSQLPROD_RO', @provider=N'MSDASQL', @datasrc=N'PostgreSQLPROD_RO', @location=N'sws-ro-pg.imcc.com', @catalog=N'dta'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'POSTGRESQLPROD_RO',@useself=N'False',@locallogin=NULL,@rmtuser=N'ilsprod',@rmtpassword='gr8sushi4U'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'collation compatible', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'POSTGRESQLPROD_RO', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


