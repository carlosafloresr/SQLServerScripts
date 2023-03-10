/*
EXECUTE USP_Claims_FindParameters 'CLA201807171316','0-02-1800'
*/
CREATE PROCEDURE USP_Claims_FindParameters
		@BatchId	Varchar(20),
		@GLAccount	Varchar(20)
AS
SELECT	GLT.JRNENTRY,
		GLT.SQNCLINE
FROM	GL10001 GLT
		INNER JOIN GL00105 GLA ON GLT.ACTINDX = GLA.ACTINDX
WHERE	GLT.DEBITAMT + GLT.CRDTAMNT <> 0
		AND GLT.BACHNUMB = @BatchId
		AND GLA.ACTNUMST = @GLAccount