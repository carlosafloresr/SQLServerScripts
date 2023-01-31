DECLARE @ReturnValue	Char(20),
		@Query			Varchar(500)

SET @Query = 'SELECT ModuleDescription FROM EscrowModules WHERE EscrowModuleId = 1'

CREATE TABLE #ReturnData (ReturnValue CHAR(20))

INSERT INTO #ReturnData (ReturnValue)
EXECUTE(@Query)

SET @ReturnValue = (SELECT * FROM #ReturnData)

DROP TABLE #ReturnDatas

PRINT @ReturnValue