DECLARE @StartDate	Date = '12/04/2022',
		@UptoDate	Date = '12/31/2022'

SELECT	RecordId, JournalNo, Reference, ProNumber, Amount, FP_StartDate
FROM	GP_XCB_Prepaid XCB
WHERE	XCB.Company = 'GLSO'
		AND XCB.GLAccount = '0-88-1866'
		AND XCB.FP_StartDate < @StartDate
		AND (XCB.Matched = 0)-- OR (XCB.Matched = 1 AND XCB.MatchFrom >= @StartDate))
		AND XCB.Voided = 0
		AND XCB.JournalNo NOT IN (SELECT Journal FROM tmpXCB_DecemberXLS)
		AND XCB.Amount > 0
		--AND RECORDID NOT IN (26213, 845551)
ORDER BY ABS(Amount)DESC, Amount DESC

/*
UPDATE	GP_XCB_Prepaid
SET		Matched = 1,
		MatchFrom = '12/03/2022'
WHERE	RecordId IN (436504,1138653,615768,615769,973348,1155643,532104,532103)
*/
-- 16335.42
 PRINT 16267 - (8175.00 + 7950.00)
 --142
 PRINT 50.00 + 35.00 - 142
 