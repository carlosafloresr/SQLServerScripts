USE [GPCustom]
GO

INSERT INTO [dbo].[Parameters]
           ([Company]
           ,[ParameterCode]
           ,[Description]
           ,[VarType]
           ,[VarC]
           ,[ApplicationName])
     VALUES
           ('ALL'
           ,'FUELTAXFILESPATH'
           ,'Folder location of Driver Fuel Tax Files'
           ,'C'
           ,'\\ilsint02\FTP\DriverFuelTax\'
           ,'OOS')
GO

/*
SELECT	*
FROM	Parameters
*/