USE [master]
GO

/****** Object:  LinkedServer [SECFBSQL01D]    Script Date: 4/12/2022 9:49:14 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'SECFBSQL01D', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SECFBSQL01D',@useself=N'False',@locallogin=NULL,@rmtuser=N'sa',@rmtpassword='adgaccess1!'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'collation compatible', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SECFBSQL01D', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


