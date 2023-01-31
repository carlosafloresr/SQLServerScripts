USE MASTER 
GO 

SP_CONFIGURE 'show advanced options', 1 
RECONFIGURE WITH OVERRIDE 
GO 

/* Enable Database Mail XPs Advanced Options in SQL Server */ 
SP_CONFIGURE 'Database Mail XPs', 1 
RECONFIGURE WITH OVERRIDE 
GO 

SP_CONFIGURE 'show advanced options', 0 
RECONFIGURE WITH OVERRIDE 
GO
