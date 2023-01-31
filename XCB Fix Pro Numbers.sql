--GPCustom.dbo.FindProNumber(G2.REFRENCE)

UPDATE	GP_XCB_Prepaid
SET		GP_XCB_Prepaid.ProNumber = DATA.NewProNumber
FROM	(
		SELECT	RecordId,
				Reference,
				ProNumber,
				GPCustom.dbo.FindProNumber(Reference) AS NewProNumber
		FROM	GP_XCB_Prepaid
		WHERE	GLAccount = '0-88-1866'
				AND Matched = 0
				AND ProNumber <> ''
		) DATA
WHERE	DATA.ProNumber <> DATA.NewProNumber
		AND DATA.NewProNumber <> ''
		AND GP_XCB_Prepaid.RecordId = DATA.RecordId

SELECT	*
FROM	(
		SELECT	RecordId,
				Reference,
				ProNumber,
				GPCustom.dbo.FindProNumber(Reference) AS NewProNumber
		FROM	GP_XCB_Prepaid
		WHERE	GLAccount = '0-88-1866'
				AND Matched = 0
				AND ProNumber <> ''
		) DATA
WHERE	DATA.ProNumber <> DATA.NewProNumber
		AND DATA.NewProNumber <> ''