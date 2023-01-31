USE [FI_Data]
GO

/****** Object:  View [dbo].[View_CodeRelations]    Script Date: 07/10/2012 11:30:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
SELECT * FROM View_CodeRelations WHERE Location = 'DALLAS'
*/
ALTER VIEW [dbo].[View_CodeRelations]
AS
SELECT	COR.RelationType
		,COR.ParentCode
		,LOC.Location AS ParentDescription
		,COR.ChildCode
		,JOC.Description AS ChildDescription
		,COR.Category
		,COR.SubCategory
		,1 AS Sort
		,COR.Location
FROM	CodeRelations COR
		INNER JOIN Locations LOC ON COR.Location = LOC.Location
		INNER JOIN JobCodes JOC ON COR.ChildCode = JOC.JobCode
WHERE	RelationType = 'JC'
UNION
SELECT	COR.RelationType
		,COR.ParentCode
		,PAR.Description AS ParentDescription
		,COR.ChildCode
		,REC.Description AS ChildDescription
		,COR.Category
		,COR.SubCategory
		,2 AS Sort
		,COR.Location
FROM	CodeRelations COR
		INNER JOIN JobCodes PAR ON COR.ParentCode = PAR.JobCode
		INNER JOIN RepairCodes REC ON COR.ChildCode = REC.RepairCode
WHERE	RelationType = 'RC'
UNION
SELECT	COR.RelationType
		,COR.ParentCode
		,REC.Description AS ParentDescription
		,COR.ChildCode
		,DAC.Description AS ChildDescription
		,COR.Category
		,COR.SubCategory
		,3 AS Sort
		,COR.Location
FROM	CodeRelations COR
		INNER JOIN RepairCodes REC ON COR.ParentCode = REC.RepairCode
		INNER JOIN DamageCodes DAC ON COR.ChildCode = DAC.DamageCode
WHERE	RelationType = 'DC'



GO


