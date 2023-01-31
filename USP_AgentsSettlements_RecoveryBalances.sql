/*
EXECUTE USP_AgentsSettlements_RecoveryBalances '04/14/2018'
*/
CREATE PROCEDURE USP_AgentsSettlements_RecoveryBalances
	@WeekendingDate		Date
AS
DECLARE	@PreviousDate		Date = DATEADD(dd, -7, @WeekendingDate),
		@BatchId			Varchar(15),
		@Agent				Varchar(3),
		@AccountNumber		Varchar(15),
		@Query				Varchar(Max)

DECLARE	@tblAccount		Table (AccountNumber Varchar(15) Null)

SET @BatchId = 'NDS' + CAST(YEAR(@WeekendingDate) AS Varchar) + dbo.PADL(CAST(MONTH(@WeekendingDate) AS Varchar), 2, '0') + dbo.PADL(CAST(DAY(@WeekendingDate) AS Varchar), 2, '0')

DECLARE curAgents CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Agent
FROM	AgentsSettlementsCommisions
WHERE	BatchId = @BatchId

OPEN curAgents 
FETCH FROM curAgents INTO @Agent

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'AGENT: ' + @Agent

	SET @Query = N'SELECT TOP 1 RTRIM(ACTNUMBR_1) + ''-'' + RTRIM(ACTNUMBR_2) + ''-'' + RTRIM(ACTNUMBR_3) AS ACTNUMST FROM NDS.dbo.GL00100 WHERE ACTIVE = 1 AND ACTDESCR LIKE ''AGENT RECOVERY%''  AND RTRIM(ACTNUMBR_1) = ''' + RTRIM(@Agent) + ''''
	
	DELETE @tblAccount

	INSERT INTO @tblAccount
	EXECUTE(@Query)

	SET @AccountNumber = (SELECT AccountNumber FROM @tblAccount)

	INSERT INTO AgentsSettlementsTransactions
	SELECT	'NDS' AS Company,
			@WeekendingDate AS WeekendDate,
			@Agent AS Agent,
			ProNumber,
			ISNULL((SELECT TOP 1 EST.Comments FROM EscrowTransactions EST WHERE EST.CompanyId = 'NDS' AND EST.AccountNumber = @AccountNumber AND EST.ProNumber = DATA.ProNumber ORDER BY EST.PostingDate DESC),'No Description') AS Description,
			StartingBalance,
			0 AS Activity,
			StartingBalance + Activity AS EndBalance,
			0 AS Hold,
			'UPLOADER' AS EnteredBy,
			GETDATE() AS EnteredOn
	FROM	(
			SELECT	RTRIM(UPPER(COALESCE(ProNumber,SOPDocumentNumber,'NO-PRO'))) AS ProNumber,
					SUM(CASE WHEN PostingDate <= @PreviousDate THEN Amount ELSE 0 END) AS StartingBalance,
					SUM(CASE WHEN PostingDate > @PreviousDate THEN Amount ELSE 0 END) AS Activity
			FROM	View_EscrowTransactions
			WHERE	CompanyId = 'NDS'
					AND AccountNumber = @AccountNumber
					AND PostingDate IS NOT Null
					AND DeletedOn IS Null
					AND PostingDate <= @WeekendingDate
			GROUP BY RTRIM(UPPER(COALESCE(ProNumber,SOPDocumentNumber,'NO-PRO')))
			) DATA
	WHERE	(StartingBalance + Activity) <> 0

	FETCH FROM curAgents INTO @Agent
END

CLOSE curAgents
DEALLOCATE curAgents