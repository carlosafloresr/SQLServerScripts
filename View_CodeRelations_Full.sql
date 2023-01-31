USE [MobileEstimates]
GO

/****** Object:  View [dbo].[View_CodeRelations_Full]    Script Date: 10/05/2012 8:18:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
SELECT * FROM View_CodeRelations_Full WHERE Location = 'DALLAS'
*/

CREATE VIEW [dbo].[View_CodeRelations_Full]
AS
SELECT	CR.CodeRelationId
		,CR.RelationType
		,CR.ParentCode
		,CR.ChildCode
		,UPPER(RTRIM(CR.Category)) AS Category
		,ISNULL(T1.Spanish, CR.Category) AS Category_Spanish
		,CR.SubCategory
		,ISNULL(T2.Spanish, CR.SubCategory) AS SubCategory_Spanish
		,CR.Location
		,CASE WHEN CR.RelationType = 'JC' THEN JC.Description
			  WHEN CR.RelationType = 'DC' THEN DC.Description
			  WHEN CR.RelationType = 'RC' THEN RC.Description
		END AS EnglishText
		,CASE WHEN CR.RelationType = 'JC' THEN ISNULL(TR.Spanish, JC.Description)
			  WHEN CR.RelationType = 'DC' THEN ISNULL(TR.Spanish, DC.Description)
			  WHEN CR.RelationType = 'RC' THEN ISNULL(TR.Spanish, RC.Description)
		END AS SpanishText
FROM	dbo.CodeRelations CR
		LEFT JOIN JobCodes JC ON CR.ChildCode = JC.JobCode AND CR.RelationType = 'JC'
		LEFT JOIN DamageCodes DC ON CR.ChildCode = DC.DamageCode AND CR.RelationType = 'DC'
		LEFT JOIN RepairCodes RC ON CR.ChildCode = RC.RepairCode AND CR.RelationType = 'RC'
		LEFT JOIN Translation TR ON CR.RelationType = TR.FormName AND CR.ChildCode = TR.ObjectName
		LEFT JOIN Translation T1 ON T1.FormName = 'CATEGORY' AND CR.Category = T1.ObjectName
		LEFT JOIN Translation T2 ON T2.FormName = 'SUBCATEGORY' AND CR.SubCategory = T2.ObjectName
GO


