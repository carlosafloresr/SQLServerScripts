SELECT	GLO.JRNENTRY,
		GLO.REFRENCE,
		CAST(GLO.TRXDATE AS Date) AS TRXDATE,
		CAST(GLO.ORPSTDDT AS Date) AS POSTINGDATE,
		GLO.USWHPSTD AS PostingUser,
		RTRIM(GLA.ACTNUMST) AS ACTNUMST,
		CAST(GLO.CRDTAMNT AS Numeric(10,2)) AS CRDTAMNT,
		CAST(GLO.DEBITAMT AS Numeric(10,2)) AS DEBITAMT,
		GLO.ORGNTSRC AS BATCHID,
		GLO.TRXSORCE,
		GLO.SOURCDOC
FROM	GL20000 GLO
		INNER JOIN GL00105 GLA ON GLO.ACTINDX = GLA.ACTINDX
WHERE	GLO.JRNENTRY = 211955