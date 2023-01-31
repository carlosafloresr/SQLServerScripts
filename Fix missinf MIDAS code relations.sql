--insert into CodeRelations ([RelationType]
--      ,[ParentCode]
--      ,[ChildCode]
--      ,[Category]
--      ,[SubCategory]
--      ,[Location]
--      ,[TimeStamp]
--      ,[DeletedOn])
SELECT [RelationType]
      ,[ParentCode]
      ,[ChildCode]
      ,[Category]
      ,[SubCategory]
      ,'HOUSTON' AS [Location]
      ,GETDATE() AS [TimeStamp]
      ,[DeletedOn]
FROM	CodeRelations
WHERE	RelationType = 'RC'
		and Location <> 'HOUSTON'
		and ParentCode IN ('15FSILL','
4BR','
4RBP','
4TNR','
4TUN','
5TNR12','
6RPT12','
6RPT24','
6RPT36','
6RPT6','
8CM','
8COCM','
8ROOF12','
8ROOF24','
8TNR','
8TUN','
CARGILL','
COCM','
RMP','
15FSILL','
4BR','
4RBP','
4TNR','
4TUN','
5TNR12','
6RPT12','
6RPT24','
6RPT36','
6RPT6','
8CM','
8COCM','
8ROOF12','
8ROOF24','
8TNR','
8TUN','
CARGILL','
COCM','
RMP')

/*
SELECT	*
FROM	View_CodeRelations_Full 
WHERE	RelationType = 'JC' 
		AND Category = 'CONTAINER'
		AND SubCategory = 'MISC'
		AND ChildCode NOT IN (
						SELECT	ParentCode 
						FROM	View_CodeRelations
						WHERE	RelationType = 'RC' 
								AND Category = 'CONTAINER'
								AND SubCategory = 'MISC'
						)

SELECT	*
FROM	FI_Data.dbo.RepairCodes RC 
		LEFT JOIN (SELECT * FROM FI_Data.dbo.CodeRelations WHERE RelationType = 'RC' AND Category = 'CONTAINER' AND SubCategory = 'MISC' AND ParentCode = '8TNR' AND Location = 'HOUSTON') CR ON RC.RepairCode = CR.ChildCode

SELECT	* 
FROM	FI_Data.dbo.DamageCodes DC 
		LEFT JOIN (SELECT * FROM FI_Data.dbo.CodeRelations WHERE RelationType = 'DC' AND Category = 'CONTAINER' AND SubCategory = 'MISC'  AND Location <> 'HOUSTON') CR ON DC.DamageCode = CR.ChildCode--AND ParentCode = 'GS'
*/