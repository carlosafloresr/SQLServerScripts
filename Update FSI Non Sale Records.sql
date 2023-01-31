/*
SELECT	DISTINCT FSIN.Company,
		FSIN.IntegrationType,
		FSIN.TransType,
		FSIN.CreditAccount,
		FSIN.DebitAccount
FROM	FSI_NonSalesRecords FSIN
		INNER JOIN FSI_ReceivedHeader FSIH ON FSIN.BatchId = FSIH.BatchId
WHERE	FSIH.WeekEndDate > '01/01/2021'
ORDER BY 1,2,3
*/
SET NOCOUNT ON

DECLARE	@BatchId	Varchar(30)

DECLARE curFSIBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT FSIN.BatchId 
FROM	FSI_NonSalesRecords FSIN
		INNER JOIN FSI_ReceivedHeader FSIH ON FSIN.BatchId = FSIH.BatchId
WHERE	FSIH.WeekEndDate > '07/11/2021'

OPEN curFSIBatches 
FETCH FROM curFSIBatches INTO @BatchId 

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Batch ' + @BatchId

	EXECUTE Integrations.dbo.USP_FSI_NonSalesRecords @BatchId
	--EXECUTE Integrations.dbo.USP_FSI_TransactionDetails @BatchId

	FETCH FROM curFSIBatches INTO @BatchId
END

CLOSE curFSIBatches
DEALLOCATE curFSIBatches

/*
TRUNCATE TABLE FSI_TransactionDetails
*/