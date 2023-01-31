SELECT	GL2.JRNENTRY AS JOURNAL,
		GL5.ACTNUMST AS ACCOUNT,
		GPCustom.dbo.FindProNumber(GL2.REFRENCE) AS PRONUMBER,
		GL2.REFRENCE AS DESCRIPTION,
		CAST(GL2.TRXDATE AS Date) AS DATE,
		CAST(GL2.CRDTAMNT AS Numeric(10,2)) AS CREDIT,
		CAST(GL2.DEBITAMT AS Numeric(10,2)) AS DEBIT,
		CAST(GL2.DEBITAMT + GL2.CRDTAMNT AS Numeric(10,2)) AS AMOUNT,
		GL2.ORGNTSRC AS BATCHID
INTO	GPCustom.dbo.JournalNumbers
FROM	GL20000 GL2
		INNER JOIN GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX
		INNER JOIN (
SELECT	DESCRIPTION,
		MAX(JOURNAL) AS JOURNAL,
		COUNT(*) AS COUNTER
FROM	(
SELECT	GL2.JRNENTRY AS JOURNAL,
		GL5.ACTNUMST AS ACCOUNT,
		GL2.REFRENCE AS DESCRIPTION,
		CAST(GL2.TRXDATE AS Date) AS DATE,
		CAST(GL2.CRDTAMNT AS Numeric(10,2)) AS CREDIT,
		CAST(GL2.DEBITAMT AS Numeric(10,2)) AS DEBIT,
		CAST(GL2.DEBITAMT + GL2.CRDTAMNT AS Numeric(10,2)) AS AMOUNT,
		GL2.ORGNTSRC AS BATCHID
FROM	GL20000 GL2
		INNER JOIN GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX
WHERE	GL2.ORGNTSRC LIKE '9FSI%'
		AND GL5.ACTNUMST IN ('1-00-5199','0-99-1866')
		AND ((GL5.ACTNUMST = '1-00-5199' AND GL2.DEBITAMT > 0)
		OR (GL5.ACTNUMST = '0-99-1866' AND GL2.CRDTAMNT > 0))
		AND GL2.TRXDATE > '12/05/2020'
		) DATA
GROUP BY DESCRIPTION
HAVING	COUNT(*) > 3) DATA ON GL2.JRNENTRY = DATA.JOURNAL
ORDER BY 3