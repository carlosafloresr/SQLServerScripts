DECLARE @Account Int = 650
DECLARE @tblPeriods Table (Period Char(7), Debit Numeric(12,2), Credit Numeric(12,2), Balance Numeric(10, 2))

INSERT INTO @tblPeriods
SELECT	CAST(YEAR1 AS Varchar) + '-' + dbo.PADL(PERIODID, 2, '0') AS Period, 
		DEBITAMT,
		CRDTAMNT,
		PERDBLNC
FROM	GLSO.dbo.GL10111
WHERE	ACTINDX = @Account
		AND PERIODID > 0
UNION
SELECT	CAST(YEAR1 AS Varchar) + '-' + dbo.PADL(PERIODID, 2, '0') AS Period, 
		DEBITAMT,
		CRDTAMNT,
		PERDBLNC
FROM	GLSO.dbo.GL10110
WHERE	ACTINDX = @Account
		AND PERIODID > 0

SELECT * FROM @tblPeriods

--SELECT	SUM(PERDBLNC) AS BALANCE
--FROM	(
--		SELECT	*, ROW_NUMBER() OVER (ORDER BY YEAR1) AS RowNumber
--		FROM	(
--				SELECT	YEAR1, 
--						PERIODID,
--						PERDBLNC
--				FROM	GLSO.dbo.GL10111
--				WHERE	ACTINDX = 650
--						AND PERIODID > 0
--				UNION
--				SELECT	YEAR1, 
--						PERIODID,
--						PERDBLNC
--				FROM	GLSO.dbo.GL10110
--				WHERE	ACTINDX = 650
--						AND PERIODID > 0
--				) DATA
--		) TEMP
--WHERE	RowNumber < 37
		