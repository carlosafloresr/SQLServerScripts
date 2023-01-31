SELECT	ProNumber, SUM(Amount) AS Amount
FROM	GP_XCB_Prepaid
WHERE	Matched = 1
GROUP BY ProNumber
HAVING SUM(Amount) <> 0

SELECT	*
FROM	GP_XCB_Prepaid
WHERE	ProNumber IN ('96-223134')--,'96-223142')
order by ProNumber, ABS(Amount)


UPDATE	GP_XCB_Prepaid
SET		Matched = 0
FROM	(
		SELECT	ProNumber, SUM(Amount) AS Amount
		FROM	GP_XCB_Prepaid
		WHERE	Matched = 1
		GROUP BY ProNumber
		HAVING SUM(Amount) <> 0
		) DATA
WHERE	GP_XCB_Prepaid.ProNumber = DATA.ProNumber