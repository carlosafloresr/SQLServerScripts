SET NOCOUNT OFF

/*
SELECT	RTRIM(BACHNUMB) AS BATCHES, * 
FROM	oIS.dbo.SY00500 
WHERE	BACHNUMB <> '' 
ORDER BY BACHNUMB

-- DELETE GIS.dbo.SY00500 WHERE BACHNUMB = 'PD220323225206P'

PPD20221208
*/

DECLARE @BulkUpdate		Bit = 0,
		@Company		Varchar(5) = 'OIS',
		@BatchId		Varchar(30) = 'PMPAY00006508',
		@Query			Varchar(2000)

IF @BulkUpdate = 0
BEGIN
	SET @Query = N'UPDATE ' + @Company + '.dbo.SY00500
	SET		Mkdtopst = 0, 
			BRKDNALL = 0, 
			BchSttus = 0, 
			PostToGL = 0, 
			ErrState = 0, 
			userid = ''''
	WHERE	BACHNUMB = ''' + @BatchId + ''''

	EXECUTE(@Query)

	DELETE	Dynamics.dbo.SY00801 
	WHERE	RSRCID = @BatchId

	DELETE	Dynamics.dbo.SY00800 
	WHERE	BACHNUMB = @BatchId

	UPDATE	Dynamics.dbo.ESS80000
	SET		STATUS = 0
	WHERE	BACHNUMB  = @BatchId
END
ELSE
BEGIN
	SET @Query = N'UPDATE ' + @Company + '.dbo.SY00500
	SET		Mkdtopst = 0, 
			BRKDNALL = 0, 
			BchSttus = 0, 
			PostToGL = 0, 
			ErrState = 0, 
			userid = ''''
	WHERE	BACHNUMB LIKE ''' + @BatchId + '%'''

	EXECUTE(@Query)

	DELETE	Dynamics.dbo.SY00801 
	WHERE	RSRCID LIKE (RTRIM(@BatchId) + '%')

	DELETE	Dynamics.dbo.SY00800 
	WHERE	BACHNUMB LIKE (RTRIM(@BatchId) + '%')

	UPDATE	Dynamics.dbo.ESS80000
	SET		STATUS = 0
	WHERE	INTERID = 'IMC'
			AND BACHNUMB LIKE (RTRIM(@BatchId) + '%')
END