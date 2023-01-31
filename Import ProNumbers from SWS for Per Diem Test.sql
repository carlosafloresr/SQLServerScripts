-- TRUNCATE TABLE PerdiemTest
-- SELECT * FROM PerdiemTest

DECLARE @Query Varchar(MAX)
SET		@Query = N'SELECT bt_code, div_code || ''-'' || pro AS ProNumber, donedt, shdate, donedt - shdate
	    FROM TRK.Order WHERE shdate > ''2011/1/15'' AND bt_code IN (''4173'') ORDER BY 2 LIMIT 25'

EXECUTE USP_QuerySWS @Query, '##tmpData'

INSERT INTO PerdiemTest
SELECT	CAST(ProNumber AS Varchar(20))
FROM	##tmpData
WHERE	CAST(ProNumber AS Varchar(20)) NOT IN (SELECT Equipment FROM PerdiemTest)

SELECT * FROM ##tmpData

DROP TABLE ##tmpData