SELECT	RTRIM(G5.ACTNUMST) AS ACTNUMST,
		G1.ACTDESCR
FROM	GL00105 G5
		INNER JOIN GL00100 G1 ON G5.ACTINDX = G1.ACTINDX
WHERE	G1.ACTIVE = 1
ORDER BY 1