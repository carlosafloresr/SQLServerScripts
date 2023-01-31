SELECT	FIL.ProjectId, 
		PRO.ProjectName,
		COUNT(*) AS Counter
FROM	DOCUMENTS DOC
		INNER JOIN Files FIL ON DOC.FileId = FIL.FileId
		INNER JOIN Projects PRO ON FIL.ProjectId = PRo.ProjectId
WHERE	DOC.DateFiled BETWEEN '07/01/2014' AND '07/30/2014 11:59:59 PM'
GROUP BY FIL.ProjectId, PRO.ProjectName
order by 3 desc