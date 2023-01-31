SET NOCOUNT ON

DECLARE	@Company			Varchar(5), 
		@Weekending			Date, 
		@BatchId			Varchar(25),
		@UserId				Varchar(25) = 'FSI_VERIFY'

DECLARE @tblFSIBatchData	Table (
		Id					int,
		Company				varchar(6),
		BatchId				varchar(30),
		Integration			varchar(15),
		CustVnd				varchar(25),
		DocRef				varchar(50),
		Amount				numeric(10,2),
		RecordId			int,
		WeekEndDate			date,
		RecordType			varchar(15),
		UserId				varchar(25))

DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT FSIT.Company, 
		CAST(CASE WHEN DATENAME(Weekday, FSIH.WeekendDate) = 'Saturday' THEN FSIH.WeekendDate 
		ELSE dbo.DayFwdBack(FSIH.WeekendDate, 'P', 'Saturday') END AS Date) AS WeekendDate,
		FSIH.BatchId
FROM	PRISQL004P.Integrations.dbo.FSI_TransactionDetails FSIT
		INNER JOIN PRISQL004P.Integrations.dbo.FSI_ReceivedHeader FSIH ON FSIT.Company = FSIH.Company AND FSIT.BatchId = FSIH.BatchId
		LEFT JOIN FSI_VerifiedBatches FSIV ON FSIT.Company = FSIV.Company AND FSIT.BatchId = FSIV.BatchId
WHERE	FSIH.WeekendDate >= DATEADD(DD, -20, GETDATE())
		AND FSIT.BatchId NOT LIKE '%_SUM'
		AND FSIV.BatchId IS Null
		--AND FSIT.Company <> 'PDS'
		AND FSIT.BatchId in ('7FSI20211111_1640')
ORDER BY 2, 1, 3

OPEN curTransactions 
FETCH FROM curTransactions INTO @Company, @Weekending, @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_FindMissingFSI @Company, @Weekending, @BatchId, @UserId, 1

	IF NOT EXISTS(SELECT TOP 1 Id FROM MissingIntegrations WHERE Company = @Company AND BatchId = @BatchId AND UserId = @UserId)
		INSERT INTO FSI_VerifiedBatches (Company, BatchId) VALUES (@Company, @BatchId)
	ELSE
		INSERT INTO @tblFSIBatchData
		SELECT	Id,
				Company,
				BatchId,
				Integration,
				CustVnd,
				DocRef,
				Amount,
				RecordId,
				WeekEndDate,
				RecordType,
				UserId
		FROM	MissingIntegrations
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND UserId = @UserId

	ORDER BY Company, BatchId, Integration, CustVnd

	FETCH FROM curTransactions INTO @Company, @Weekending, @BatchId
END

CLOSE curTransactions
DEALLOCATE curTransactions

SELECT	Company,
		BatchId,
		Integration,
		CustVnd,
		DocRef,
		Amount,
		CAST(RecordId AS Varchar) + ',' AS RecordId,
		WeekEndDate,
		RecordType
FROM	@tblFSIBatchData