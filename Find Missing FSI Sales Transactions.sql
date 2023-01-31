SET NOCOUNT ON

DECLARE	@Company		Varchar(5) = 'PTS',
		@WeekEndDate	Date = '01/25/2020',
		@BatchId		Varchar(25),
		@Query			Varchar(MAX)

BEGIN TRY
	DROP TABLE ##tmpData
END TRY
BEGIN CATCH
	PRINT ''
END CATCH

DECLARE	@tblData		Table (
		Company			Varchar(5),
		BatchId			Varchar(25), 
		CustomerNumber	Varchar(15),
		InvoiceNumber	Varchar(30),
		InvoiceTotal	Numeric(10,2),
		Intercompany	Bit)

DECLARE curBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company,
		BatchId
FROM	IntegrationsDB.Integrations.dbo.FSI_ReceivedHeader
WHERE	Company = @Company
		AND WeekEndDate = @WeekEndDate
ORDER BY 1, 2

OPEN curBatches 
FETCH FROM curBatches INTO @Company, @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Batch Id' + @BatchId

	SET @Query = 'SELECT ''' + @Company + ''',	
						FSI.batchId, 
						FSI.CustomerNumber,
						FSI.InvoiceNumber,
						FSI.InvoiceTotal,
						FSI.Intercompany
				FROM	IntegrationsDB.Integrations.dbo.FSI_ReceivedDetails FSI 
						INNER JOIN GPCustom.dbo.CustomerMaster CM ON CM.CompanyId = ''' + @Company + ''' AND ISNULL(CM.SWSCustomerID, CM.CustNmbr) = FSI.CustomerNumber
						LEFT JOIN ' + @Company + '.dbo.RM00401 GP ON CM.CustNmbr = GP.CUSTNMBR AND FSI.InvoiceNumber = GP.DOCNUMBR 
				WHERE	FSI.BatchId = ''' + @BatchId + ''' 
						AND FSI.InvoiceTotal <> 0 
						AND FSI.Intercompany = 0 
						AND GP.DOCNUMBR IS Null'
	
	PRINT @Query
	INSERT INTO @tblData
	EXECUTE(@Query)

	FETCH FROM curBatches INTO @Company, @BatchId
END

CLOSE curBatches
DEALLOCATE curBatches

SELECT	ISNULL(SUM(InvoiceTotal), 0.00) AS InvoiceTotal
FROM	@tblData
ORDER BY 1

SELECT	*
INTO	##tmpData
FROM	@tblData
ORDER BY 1

SELECT	*
FROM	##tmpData

/*
SELECT	CustNmbr
FROM	GPCustom.dbo.CustomerMaster
WHERE	CompanyId = 'PTS'
		AND ISNULL(SWSCustomerID, CustNmbr) = 'CMACGM'
*/