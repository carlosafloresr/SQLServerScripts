USE [Integrations]
GO

TRUNCATE TABLE FSI_Intercompany_ARAP
GO

INSERT INTO [dbo].[FSI_Intercompany_ARAP]
           ([Company]
           ,[LinkedCompany]
           ,[RecordType]
           ,[Account]
           ,[ForGLIntegration]
           ,[TransType])
SELECT	[Company]
           ,[LinkedCompany]
           ,[RecordType]
           ,[Account]
           ,[ForGLIntegration]
           ,[TransType]
FROM	[PRISQL004P].[Integrations].[dbo].[FSI_Intercompany_ARAP]