DECLARE	@BatchId	Varchar(20) = '8FSI20210118_1645'

DECLARE	@Company	Varchar(5) = (SELECT Company FROM IntegrationsDB.Integrations.dbo.FSI_ReceivedHeader WHERE BatchId = @BatchId),
		@ProjectId	Int,
		@Query		Varchar(MAX)

DECLARE	@tblAPDocs	Table (Vendor Varchar(15), Document Varchar(30), Project Int Null)

SET @ProjectId = (SELECT ProjectId FROM GPCustom.dbo.DexCompanyProjects WHERE Company = @Company AND ProjectType = 'AP')
SET @Query = N'SELECT	RTRIM(GP.VENDORID) AS VENDORID,
		RTRIM(GP.DOCNUMBR) AS DOCNUMBER,
		DX.FileId
FROM	' + @Company + '.dbo.PM20000 GP
		LEFT JOIN PRIFBSQL01P.FB.dbo.View_DEXDocuments DX ON DX.ProjectID = ' + CAST(@ProjectId AS Varchar) + ' AND GP.VENDORID = DX.Field8 AND GP.DOCNUMBR = DX.Field4
WHERE	GP.BACHNUMB = ''' + LEFT(@BatchId, 15) + ''''

INSERT INTO @tblAPDocs
EXECUTE(@Query)

SELECT	*
INTO	##tmpAPDocs
FROM	@tblAPDocs

SET @Query = N'UPDATE ' + @Company + '.dbo.PM20000 SET HOLD = 1 FROM ##tmpAPDocs DAT WHERE VENDORID = VENDOR AND DOCNUMBR = Document AND Project IS Null AND HOLD = 0'

EXECUTE(@Query)

DROP TABLE ##tmpAPDocs