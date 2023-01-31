DECLARE	@Query			Varchar(MAX),
		@Rundate		Date = GETDATE(),
		@BatchId		Varchar(25),
		@Company		Int,
		@PostedOn		Varchar(10),
		@PostingDate	Date

SET	@Query = 'SELECT DISTINCT cmpy_no, batch, postdate FROM DMInvoice WHERE postflag = ''Y'' AND PostDate BETWEEN ''' + CONVERT(Char(10), DATEADD(DD, -8, @RunDate), 101) + ''' AND ''' + CONVERT(Char(10), @RunDate, 101) + ''' UNION '
SET	@Query = @Query + 'SELECT DISTINCT cmpy_no, batch, postdate FROM dmmiscinvoice WHERE postflag = ''Y'' AND PostDate BETWEEN ''' + CONVERT(Char(10), DATEADD(DD, -8, @RunDate), 101) + ''' AND ''' + CONVERT(Char(10), @RunDate, 101) + ''' ORDER BY cmpy_no, PostDate DESC'

EXECUTE USP_QuerySWS @Query, '##tmpSWSData'

DECLARE curSWSBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	cmpy_no,
		batch,
		postdate
FROM	##tmpSWSData

OPEN curSWSBatches
FETCH FROM curSWSBatches INTO @Company, @BatchId, @PostedOn

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 batch_no FROM DMS_ReceivedTransactions WHERE batch_no = @BatchId AND cmpy_no = @Company)
	BEGIN
		PRINT 'Found Batch: ' + @BatchId + ' for Company ' + CAST(@Company AS Varchar) + ' from Date ' + @PostedOn
		
		SET @PostingDate =  CAST(@PostedOn AS Date)
		
		EXECUTE USP_DMS_ReceivedTransactions_Load @Company, @BatchId, @PostedOn
	END

	FETCH FROM curSWSBatches INTO @Company, @BatchId, @PostedOn
END	

CLOSE curSWSBatches
DEALLOCATE curSWSBatches

DROP TABLE ##tmpSWSData