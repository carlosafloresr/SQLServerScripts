INSERT INTO TiresByLocation
SELECT	CD.Location,
		TP.PARTNO,
		JC.Description,
		TP.CATEGORY,
		TP.TYPE
FROM	CodeRelations CD
		INNER JOIN TireParts TP ON CD.ParentCode = TP.PARTNO
		LEFT JOIN JobCodes JC ON TP.PARTNO = JC.JobCode
