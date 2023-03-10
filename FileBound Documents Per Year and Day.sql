-- BY YEAR
SELECT	FI.ProjectID
		,PR.ProjectName
		,YEAR([DateChanged])
		,COUNT(DateChanged) AS Counter
FROM	[FB].[dbo].[Files] FI
		INNER JOIN Projects PR ON FI.ProjectID = PR.ProjectID
WHERE	YEAR([DateChanged]) > 2011
GROUP BY FI.ProjectID
      ,YEAR([DateChanged])
	  ,PR.ProjectName
ORDER BY 1, 3

-- BY DATE 
SELECT	FI.ProjectID
		,PR.ProjectName
		,CAST(FI.DateChanged AS Date)
		,COUNT(DateChanged) AS Counter
FROM	[FB].[dbo].[Files] FI
		INNER JOIN Projects PR ON FI.ProjectID = PR.ProjectID
WHERE	DateChanged BETWEEN '01/01/2016' AND '01/12/2016'
GROUP BY FI.ProjectID
		,PR.ProjectName
		,CAST(FI.DateChanged AS Date)
ORDER BY 1, 3

-- Documents by OCR and None OCR
SELECT	FI.ProjectID,
		PR.ProjectName,
		SUM(CASE WHEN DC.Contents <> '' THEN 1 ELSE 0 END) AS ByOCR,
		SUM(CASE WHEN DC.Contents = '' THEN 1 ELSE 0 END) AS NonOCR
FROM	Files FI
		INNER JOIN Projects PR ON FI.ProjectID = PR.ProjectID
		INNER JOIN Documents DC ON FI.FileID = DC.FileID
WHERE	PR.ProjectName LIKE 'Accounts Payable APflow %'
		AND PR.ProjectName NOT LIKE '%Department LookUp%'
GROUP BY
		FI.ProjectID,
		PR.ProjectName
ORDER BY
		FI.ProjectID,
		PR.ProjectName