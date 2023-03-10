SELECT	GLT.JRNENTRY,
		GLT.REFRENCE,
		GLT.ORGNTSRC,
		GLT.ORGNATYP,
		GLT.ORCTRNUM,
		GLT.ORDOCNUM,
		GLT.OrigSeqNum,
		GLT.ORCRDAMT,
		GLT.ORDBTAMT,
		APF.Account,
		PMD.VCHRNMBR
INTO	#tmpRecords
FROM	APFix APF
		INNER JOIN PTS.dbo.GL00105 GLA ON APF.Account = GLA.ACTNUMST
		INNER JOIN PTS.dbo.GL20000 GLT ON APF.JrnlNo = GLT.JRNENTRY AND GLA.ACTINDX = GLT.ACTINDX
		LEFT JOIN PTS.dbo.PM30600 PMD ON GLT.ORGNTSRC = PMD.TRXSORCE AND GLT.OrigSeqNum = PMD.DSTSQNUM
WHERE	PMD.VCHRNMBR IS NULL

SELECT	*
FROM	#tmpRecords
WHERE	ORGNTSRC NOT IN (SELECT TRXSORCE FROM PTS.dbo.PM30200)

SELECT	*
FROM	#tmpRecords
WHERE	ORGNTSRC IN (SELECT TRXSORCE FROM PTS.dbo.PM10100)

DROP TABLE #tmpRecords

/*
SELECT	*
FROM	PTS.dbo.PM30600
*/