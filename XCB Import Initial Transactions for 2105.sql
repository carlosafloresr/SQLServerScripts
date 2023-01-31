SELECT	XCB.RecordId, XCB.FP_StartDate, DATA.RecordId
FROM	GP_XCB_Prepaid XCB
		LEFT JOIN (
					SELECT	XCB.RecordId,
							XCB.FP_StartDate
					FROM	tmpXCB_DecemberXLS_2105 XLS
							LEFT JOIN GP_XCB_Prepaid XCB ON XLS.Journal = XCB.JournalNo AND XLS.Pro = XCB.ProNumber AND XLS.Amount = XCB.Amount AND XCB.GLAccount = '0-00-2105'
				  ) DATA ON XCB.RecordId = DATA.RecordId
WHERE	XCB.GLAccount = '0-00-2105'
		AND DATA.RecordId IS not Null
		--AND XCB.FP_StartDate < '12/04/2022'

DELETE	GP_XCB_Prepaid
WHERE	RecordId IN (SELECT	XCB.RecordId
					FROM	GP_XCB_Prepaid XCB
							LEFT JOIN (
										SELECT	XCB.RecordId,
												XCB.FP_StartDate
										FROM	tmpXCB_DecemberXLS_2105 XLS
												LEFT JOIN GP_XCB_Prepaid XCB ON XLS.Journal = XCB.JournalNo AND XLS.Pro = XCB.ProNumber AND XLS.Amount = XCB.Amount AND XCB.GLAccount = '0-00-2105'
									  ) DATA ON XCB.RecordId = DATA.RecordId
					WHERE	XCB.GLAccount = '0-00-2105'
							AND DATA.RecordId IS Null)
		AND XCB.FP_StartDate < '12/04/2022'
/*
DELETE	GP_XCB_Prepaid_Matched
WHERE	RecordId IN (
					SELECT	RecordId
					FROM	GP_XCB_Prepaid
					WHERE	GLAccount = '0-00-2105')

UPDATE	GP_XCB_Prepaid
SET		Matched = 0
WHERE	GLAccount = '0-00-2105'

SELECT	COUNT(*) AS Count
FROM	tmpXCB_DecemberXLS_2105
*/