/*
EXECUTE USP_Manifest_JobCodes
*/
ALTER PROCEDURE USP_Manifest_JobCodes
AS
SELECT	*
INTO	#tmpCodes
FROM	(
SELECT	JobCode,
		Description,
		'FUEL' AS CodeType
FROM	JobCodes
WHERE	JobCode IN (
					SELECT	DISTINCT ChildCode
					FROM	CodeRelations
					WHERE	RelationType = 'JC'
							AND SubCategory = 'FUEL'
					)
		AND Description = 'FUEL'
UNION
SELECT	JobCode,
		Description,
		'TIRES' AS CodeType
FROM	JobCodes
WHERE	JobCode IN (
					SELECT	DISTINCT ChildCode
					FROM	CodeRelations
					WHERE	RelationType = 'JC'
							AND Category = 'TIRES'
							AND SubCategory = 'REPLACE'
					)
		) DATA

SELECT	JobCode,
		Description,
		'OTHER' AS CodeType
FROM	JobCodes
WHERE	JobCode NOT IN (SELECT JobCode FROM #tmpCodes)
UNION
SELECT	*
FROM	#tmpCodes
ORDER BY 1

DROP TABLE #tmpCodes