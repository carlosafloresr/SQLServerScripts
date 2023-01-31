/*
UPDATE CM20200 SET TRXAMNT=(FLOOR((TRXAMNT * 100)))*.01 
WHERE TRXAMNT <> 0 and TRXAMNT > 0

UPDATE CM20200 SET TRXAMNT=(CEILING((TRXAMNT * 100)))*.01 
WHERE TRXAMNT <> 0 and TRXAMNT < 0 

SELECT * FROM CM00100

UPDATE	CM00100 SET CURRBLNC =(CEILING((CURRBLNC  * 100)))*.01 
WHERE	CURRBLNC <> 0 
		AND CURRBLNC  < 0 

SELECT * FROM GL00105 WHERE ACTNUMST = '0-01-1013'

UPDATE	GL10110 
SET		PerdBlnc = ROUND(PerdBlnc, 2),
		CrdtAmnt = ROUND(CrdtAmnt, 2)
WHERE	Year1 = 2009 
		AND CrdtAmnt <> ROUND(CrdtAmnt, 2)

UPDATE	GL20000
SET		CrdtAmnt = ROUND(CrdtAmnt, 2), 
		OrCrdAmt = ROUND(OrCrdAmt, 2)
WHERE	CrdtAmnt <> ROUND(CrdtAmnt, 2)

UPDATE	GL20000
SET		CrdtAmnt = 7.66,
		OrCrdAmt = 7.66
WHERE	Dex_Row_Id = 204422

UPDATE	GL20000
SET		CrdtAmnt = 1773.07,
		OrCrdAmt = 1773.07
WHERE	Dex_Row_Id = 205160

UPDATE	GL20000
SET		CrdtAmnt = 1773.07,
		OrCrdAmt = 1773.07
WHERE	Dex_Row_Id = 205160

SELECT	* 
FROM	GL10110 
WHERE	Year1 = 2009
		AND CrdtAmnt <> ROUND(CrdtAmnt, 2)
		
UPDATE	CM20200 
SET		TrxAmnt	= ROUND(TrxAmnt, 2),
		ClrdAmt	= ROUND(ClrdAmt, 2),
		OrigAmt	= ROUND(OrigAmt, 2),
		Checkbook_Amount = ROUND(Checkbook_Amount, 2)
WHERE	ROUND(TrxAmnt, 2) <> TrxAmnt

UPDATE	GL20000
SET		CrdtAmnt = ROUND(CrdtAmnt, 2),
		DebitAmt = ROUND(DebitAmt, 2),
		OrCrdAmt = ROUND(OrCrdAmt, 2),
		OrDbtAmt = ROUND(OrDbtAmt, 2)
WHERE	ROUND(CrdtAmnt, 2) <> CrdtAmnt
		OR ROUND(DebitAmt, 2) <> DebitAmt

*/

SELECT	* 
FROM	CM20200 
WHERE	ROUND(TrxAmnt, 2) <> TrxAmnt

SELECT	*
FROM	GL20000
WHERE	ROUND(CrdtAmnt, 2) <> CrdtAmnt
		OR ROUND(DebitAmt, 2) <> DebitAmt

