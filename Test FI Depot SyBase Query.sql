SELECT * INTO #tmpParts FROM OPENQUERY([FIDepot_SyBase], 'SELECT * FROM FI_JOBCODES_MEMPHIS')

SELECT	TMP.Depot_Loc,
		TMP.ACCT_NO AS Customer,
		ISNULL(REL.Category, TMP.BIN) AS Category,
		ISNULL(REL.SubCategory, '') AS SubCategory,
		TMP.PART_NO AS JobCode,
		TMP.Descript AS Description,
		CASE WHEN REL.Category IS NULL THEN 'No' ELSE 'Yes' END AS In_MIDAS
FROM	#tmpParts TMP
		LEFT JOIN CodeRelations REL ON TMP.DEPOT_LOC = REL.Location AND TMP.PART_NO = REL.ChildCode AND REL.RelationType = 'JC' AND REL.DeletedOn IS NULL
ORDER BY 1, 2, 3, 4, 5

DROP TABLE #tmpParts