SELECT	b.fileOSName, 
		a.fileNumber, 
		a.PRODID, 
		a.Status, 
		a.errornum, 
		a.errordes, 
		c.CMPANYID, 
		c.INTERID
FROM	DYNAMICS.dbo.DU000030 a
		JOIN DYNAMICS.dbo.DU000010 b ON a.fileNumber = b.fileNumber AND a.PRODID = b.PRODID
		JOIN DYNAMICS.dbo.SY01500 c ON a.companyID = c.CMPANYID
WHERE	(a.Status <> 0 
		OR a.errornum <> 0) 
		AND a.Status <> 15
