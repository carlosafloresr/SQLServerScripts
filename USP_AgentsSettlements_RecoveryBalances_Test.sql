/*
EXECUTE USP_AgentsSettlements_RecoveryBalances_Test '07/21/2018','31'
*/
ALTER PROCEDURE [USP_AgentsSettlements_RecoveryBalances_Test]
	@WeekendingDate		Date,
	@Agent				Varchar(3) = Null
AS
SET NOCOUNT ON

DECLARE	@PreviousDate		Date = DATEADD(dd, -7, @WeekendingDate),
		@BatchId			Varchar(15),
		@AccountNumber		Varchar(15),
		@Query				Varchar(Max)

DECLARE @tblEscrowReport Table (
	[EscrowTransactionId]	[int] NOT NULL,
	[Source]				[char](2) NOT NULL,
	[VoucherNumber]			[varchar](22) NOT NULL,
	[ItemNumber]			[int] NULL,
	[CompanyId]				[char](6) NOT NULL,
	[Fk_EscrowModuleId]		[int] NOT NULL,
	[AccountNumber]			[char](15) NOT NULL,
	[AccountType]			[int] NOT NULL,
	[VendorId]				[varchar](10) NOT NULL,
	[DriverId]				[varchar](10) NULL,
	[Division]				[varchar](4) NULL,
	[Amount]				[money] NOT NULL,
	[ClaimNumber]			[varchar](15) NULL,
	[DriverClass]			[int] NULL,
	[AccidentType]			[int] NULL,
	[Status]				[int] NULL,
	[DMSubmitted]			[int] NULL,
	[DeductionPlan]			[char](5) NULL,
	[Comments]				[varchar](1000) NULL,
	[ProNumber]				[varchar](50) NULL,
	[TransactionDate]		[datetime] NOT NULL,
	[PostingDate]			[datetime] NULL,
	[EnteredBy]				[varchar](25) NOT NULL,
	[EnteredOn]				[datetime] NOT NULL,
	[ChangedBy]				[varchar](25) NOT NULL,
	[ChangedOn]				[datetime] NOT NULL,
	[Void]					[bit] NOT NULL,
	[InvoiceNumber]			[varchar](30) NULL,
	[OtherStatus]			[varchar](20) NULL,
	[DeletedBy]				[varchar](25) NULL,
	[DeletedOn]				[datetime] NULL,
	[BatchId]				[varchar](25) NULL,
	[SOPDocumentNumber]		[varchar](25) NULL,
	[UnitNumber]			[varchar](90) NULL,
	[RepairDate]			[date] NULL,
	[ETA]					[date] NULL,
	[RecordType]			[varchar](1) NOT NULL,
	[ChassisNumber]			[varchar](15) NULL,
	[TrailerNumber]			[varchar](15) NULL,
	[AccountIndex]			[int] NOT NULL,
	[AccountAlias]			[varchar](50) NULL,
	[Balance]				[money] NULL,
	[EndBalance]			[money] NULL,
	[FinalBalance]			[money] NULL,
	[PeriodSummary]			[int] NULL,
	[TransDescription]		[varchar](500) NULL,
	[CompanyName]			[varchar](50) NULL,
	[VendName]				[varchar](50) NULL,
	[ActDescr]				[varchar](51) NULL,
	[ProNumberMain]			[varchar](50) NULL,
	[DocNumber]				[varchar](20) NULL,
	[PostDate]				[datetime] NULL,
	[Module]				[varchar](50) NULL,
	[HireDate]				[datetime] NULL,
	[TerminationDate]		[datetime] NULL,
	[DriverType]			[varchar](3) NOT NULL,
	[RowNumber]				[bigint] NULL,
	[AccountStartBalance]	[money] NULL,
	[AccountEndingBalance]	[money] NULL,
	[ReportEndingBalance]	[money] NULL,
	[RecordStatus]			[varchar](25) NULL)

DECLARE	@tblAccount		Table (AccountNumber Varchar(15) Null)

SET @BatchId = 'NDS' + CAST(YEAR(@WeekendingDate) AS Varchar) + dbo.PADL(CAST(MONTH(@WeekendingDate) AS Varchar), 2, '0') + dbo.PADL(CAST(DAY(@WeekendingDate) AS Varchar), 2, '0')

DECLARE curAgents CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Agent
FROM	AgentsSettlementsCommisions
WHERE	BatchId = @BatchId
		AND (@Agent IS Null OR (@Agent IS NOT Null AND Agent = @Agent))

OPEN curAgents 
FETCH FROM curAgents INTO @Agent

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'AGENT: ' + @Agent

	DELETE @tblEscrowReport

	SET @Query = N'SELECT TOP 1 RTRIM(ACTNUMBR_1) + ''-'' + RTRIM(ACTNUMBR_2) + ''-'' + RTRIM(ACTNUMBR_3) AS ACTNUMST FROM NDS.dbo.GL00100 WHERE ACTIVE = 1 AND ACTDESCR LIKE ''AGENT RECOVERY%''  AND RTRIM(ACTNUMBR_1) = ''' + RTRIM(@Agent) + ''''
	
	DELETE @tblAccount

	INSERT INTO @tblAccount
	EXECUTE(@Query)

	SET @AccountNumber = (SELECT AccountNumber FROM @tblAccount)
	SET @Query = N'NDS.dbo.USP_Report_ExpenseRecovery ''NDS'',''' + RTRIM(@AccountNumber) + ''',''2017-01-01'',''' + CONVERT(Char(10), @WeekendingDate, 120) + ''''

	INSERT INTO @tblEscrowReport
	EXECUTE(@Query)

	SELECT	'NDS' AS Company,
			@WeekendingDate AS WeekendDate,
			@Agent AS Agent,
			DATA.ProNumber,
			MAX(ISNULL(DATA.Comments, DATA.ProNumber)) AS Description,
			MAX(DATA.AccountStartBalance) AS AccountStartBalance,
			0 AS Activity,
			MAX(DATA.EndBalance) AS EndBalance,
			0 AS Hold,
			'UPLOADER' AS EnteredBy,
			GETDATE() AS EnteredOn
	FROM	@tblEscrowReport DATA
	GROUP BY DATA.ProNumber

	--SELECT	'NDS' AS Company,
	--		@WeekendingDate AS WeekendDate,
	--		@Agent AS Agent,
	--		ProNumber,
	--		ISNULL((SELECT TOP 1 EST.Comments FROM EscrowTransactions EST WHERE EST.CompanyId = 'NDS' AND EST.AccountNumber = @AccountNumber AND EST.ProNumber = DATA.ProNumber ORDER BY EST.PostingDate DESC),'No Description') AS Description,
	--		StartingBalance,
	--		0 AS Activity,
	--		StartingBalance + Activity AS EndBalance,
	--		0 AS Hold,
	--		'UPLOADER' AS EnteredBy,
	--		GETDATE() AS EnteredOn
	--INTO	#tmpAgentsData
	--FROM	(
	--		SELECT	RTRIM(UPPER(COALESCE(ProNumber,SOPDocumentNumber,'NO-PRO'))) AS ProNumber,
	--				SUM(CASE WHEN PostingDate <= @PreviousDate THEN Amount ELSE 0 END) AS StartingBalance,
	--				SUM(CASE WHEN PostingDate > @PreviousDate THEN Amount ELSE 0 END) AS Activity
	--		FROM	View_EscrowTransactions
	--		WHERE	CompanyId = 'NDS'
	--				AND AccountNumber = @AccountNumber
	--				AND PostingDate IS NOT Null
	--				AND DeletedOn IS Null
	--				AND PostingDate <= @WeekendingDate
	--		GROUP BY RTRIM(UPPER(COALESCE(ProNumber,SOPDocumentNumber,'NO-PRO')))
	--		) DATA
	--WHERE	(StartingBalance + Activity) <> 0

	--INSERT INTO AgentsSettlementsTransactions
	--SELECT	*
	--FROM	#tmpAgentsData
	--WHERE	ProNumber NOT IN (SELECT ProNumber FROM AgentsSettlementsTransactions WHERE Agent = @Agent AND WeekendDate = @WeekendingDate)

	--UPDATE	AgentsSettlementsTransactions
	--SET		AgentsSettlementsTransactions.BalanceIni	= DATA.StartingBalance,
	--		AgentsSettlementsTransactions.BalanceEnd	= DATA.EndBalance
	--FROM	#tmpAgentsData DATA
	--WHERE	AgentsSettlementsTransactions.WeekendDate = DATA.WeekendDate
	--		AND AgentsSettlementsTransactions.Agent = DATA.Agent
	--		AND AgentsSettlementsTransactions.ProNumber = DATA.ProNumber
	--		AND (AgentsSettlementsTransactions.BalanceIni <> DATA.StartingBalance
	--		OR AgentsSettlementsTransactions.BalanceEnd	<> DATA.EndBalance)

	--DROP TABLE #tmpAgentsData

	FETCH FROM curAgents INTO @Agent
END

CLOSE curAgents
DEALLOCATE curAgents