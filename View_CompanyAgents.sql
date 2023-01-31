USE [GPCustom]
GO

/****** Object:  View [dbo].[View_CompanyAgents]    Script Date: 9/16/2021 9:04:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_CompanyAgents]
AS
SELECT	DISTINCT COM.CompanyId,
		ISNULL(COM.CompanyAlias, COM.CompanyId) AS CompanyAlias,
		CAST(CASE WHEN COM.CompanyId = 'NDS' THEN ISNULL(AGE.Agent, COM.CompanyNumber) ELSE COM.CompanyNumber END AS Varchar) AS CompanyNumber,
		COM.CompanyName,
		COM.Trucking
FROM	Companies COM
		LEFT JOIN Agents AGE ON COM.CompanyId = AGE.Company
WHERE	COM.IsTest = 0
GO


