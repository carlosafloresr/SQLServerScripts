SELECT	GL5.ACTNUMST,
		CAST(GLO.TRXDATE AS Date) AS TRXDATE,
		GLO.JRNENTRY,
		GLO.ORTRXSRC,
		GLO.DSCRIPTN,
		GLO.ORDOCNUM,
		GLO.ORMSTRNM,
		CAST(GLO.DEBITAMT AS Numeric(10,2)) AS DEBITAMT,
		CAST(GLO.CRDTAMNT AS Numeric(10,2)) AS CRDTAMNT
FROM	GL20000 GLO
		INNER JOIN GL00100 GLA ON GLO.ACTINDX = GLA.ACTINDX
		INNER JOIN GL00105 GL5 ON GLO.ACTINDX = GL5.ACTINDX
WHERE	GLA.ACTNUMBR_3 BETWEEN '5010' AND '5019'
		AND GLO.TRXDATE BETWEEN '04/01/2018' AND '04/28/2018'
ORDER BY 
		GL5.ACTNUMST,
		GLO.JRNENTRY