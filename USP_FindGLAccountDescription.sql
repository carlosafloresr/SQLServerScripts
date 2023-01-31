ALTER PROCEDURE USP_FindGLAccountDescription
	@Company	Varchar(5),
	@Account	Varchar(15)
AS
DECLARE	@Query	Varchar(Max)
SET		@Query = 'INSERT INTO #GLAccountDescrip SELECT GL1.ActDescr AS AccountDescription FROM ' + @Company + '.dbo.GL00100 GL1 INNER JOIN ' + @Company + '.dbo.GL00105 GL2 ON GL1.ActIndx = GL2.ActIndx WHERE GL2.ActNumSt = ''' + @Account + ''''

SELECT	ActDescr AS AccountDescription
INTO	#GLAccountDescrip	
FROM	AIS.dbo.GL00100
WHERE	ActIndx = -1

EXECUTE(@Query)

SELECT * FROM #GLAccountDescrip

DROP TABLE #GLAccountDescrip

/*
EXECUTE USP_FindGLAccountDescription 'AIS', '1-05-6140'
SELECT GL1.ActDescr FROM AIS.dbo.GL00100 GL1 INNER JOIN AIS.dbo.GL00105 GL2 ON GL1.ActIndx = GL2.ActIndx WHERE GL2.ActNumSt = '1-05-6140'
SELECT * FROM AIS.dbo.GL00100
SELECT * FROM AIS.dbo.GL00105
*/