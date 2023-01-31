DECLARE @BatchId Varchar(25) = LEFT('1FSI20211012_13', 15)

SELECT	'GL' AS DATATYPE, BACHNUMB, JRNENTRY, REFRENCE, 'WORK' AS DATASOURCE
FROM	GL10000
WHERE	BACHNUMB = @BatchId
UNION
SELECT	'GL' AS DATATYPE, ORGNTSRC, JRNENTRY, REFRENCE, 'OPEN' AS DATASOURCE
FROM	GL20000
WHERE	ORGNTSRC = @BatchId

SELECT	'AP' AS DATATYPE, BACHNUMB, VCHRNMBR, VENDORID, DOCNUMBR, DOCAMNT, CURTRXAM, 'WORK' AS DATASOURCE
FROM	PM10000
WHERE	BACHNUMB = @BatchId
UNION
SELECT	'AP' AS DATATYPE, BACHNUMB, VCHRNMBR, VENDORID, DOCNUMBR, DOCAMNT, CURTRXAM, 'OPEN' AS DATASOURCE
FROM	PM20000
WHERE	BACHNUMB = @BatchId
UNION
SELECT	'AP' AS DATATYPE, BACHNUMB, VCHRNMBR, VENDORID, DOCNUMBR, DOCAMNT, CURTRXAM, 'HISTORY' AS DATASOURCE
FROM	PM30200
WHERE	BACHNUMB = @BatchId
ORDER BY 8 DESC, 3