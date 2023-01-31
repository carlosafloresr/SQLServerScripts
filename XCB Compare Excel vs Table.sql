SELECT	DISTINCT TMP.*,
		XCB.*
FROM	tmpXCBData TMP
		FULL JOIN tmpXCBNovember XCB ON TMP.Journal = XCB.JournalNo AND (TMP.Pro = XCB.ProNumber OR TMP.Reference = XCB.[Distribution Reference])
ORDER BY XCB.ProNumber, XCB.[Distribution Reference], XCB.JournalNo

/*
SELECT	*
FROM	GLSO..GL20000
WHERE	JRNENTRY IN (3458882,3458883,3458886)
		AND ACTINDX = 650

SELECT	count(*), sum(amount)
FROM	GP_XCB_Prepaid
WHERE	gpperiod = 'nov-20'
*/

--update	GP_XCB_Prepaid
--set		Reference = '95-276925',
--		pronumber = '95-276925'
--WHERE	JournalNo IN (3385569)