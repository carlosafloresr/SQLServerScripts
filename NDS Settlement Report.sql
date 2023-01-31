USE [GPCustom]
GO
/*
EXECUTE USP_AgentsSettlements_Report '02/17/2018'
EXECUTE USP_AgentsSettlements_Report '02/17/2018', '10', 0
EXECUTE USP_AgentsSettlements_Report '02/17/2018', '10', 1
*/
ALTER PROCEDURE USP_AgentsSettlements_Report
		@WeekendDate		Date,
		@Agent				Varchar(3) = Null,
		@FrontPage			Bit = 1
AS
SET NOCOUNT ON

DECLARE	@Commission			Numeric(5,2),
		@Counter			Int = 0,
		@Description		Varchar(50),
		@Amount1			Numeric(10,2),
		@Amount2			Numeric(10,2),
		@Amount3			Numeric(10,2),
		@tmpAmount			Numeric(10,2),
		@Section			Varchar(50),
		@DateIni			Date,
		@DateEnd			Date,
		@AccountNumber		Varchar(15),
		@IniBalance			Numeric(10,2),
		@EndBalance			Numeric(10,2),
		@Activity			Numeric(10,2) = 0,
		@Deductions			Numeric(10,2),
		@Query				Varchar(Max)

DECLARE	@tblCodes Table (Code Char(3), CodeType Char(3))

DECLARE	@AgentsSettlements	Table (
	[AgentsSettlementsId]	bigint NOT NULL,
	[Company]				varchar(5) NOT NULL,
	[WeekendDate]			date NOT NULL,
	[DateFrom]				date NOT NULL,
	[DateTo]				date NOT NULL,
	[Agent]					varchar(3) NOT NULL,
	[RecordType]			char(3) NOT NULL,
	[RecordDescription]		varchar(45) NOT NULL,
	[Total]					numeric(10, 2) NOT NULL,
	[Percentage]			numeric(8, 4) NOT NULL,
	[Amount]				numeric(10, 2) NOT NULL,
	[AccessorialCode]		char(3) NULL,
	[ReceivedOn]			datetime NOT NULL)

DECLARE	@tblData Table (
	RowId				Int,
	Agent				Varchar(3),
	RowDescription		Varchar(50),
	Amount1				Numeric(10,2) Null,
	Amount2				Numeric(10,2) Null,
	Amount3				Numeric(10,2) Null,
	Section				Varchar(2),
	IsTotal				Bit)

DECLARE	@tblAccount		Table (
	AccountNumber		Varchar(15) Null)

INSERT INTO @tblCodes VALUES ('FRT', 'FRT')
INSERT INTO @tblCodes VALUES ('FSC', 'FRT')
INSERT INTO @tblCodes VALUES ('BRO', 'BRO')
INSERT INTO @tblCodes VALUES ('XFR', 'XFR')

INSERT INTO @AgentsSettlements
SELECT	*
FROM	AgentsSettlements
WHERE	WeekendDate = @WeekendDate
		AND (@Agent IS Null
		OR (@Agent IS NOT Null AND Agent = @Agent))

SET @DateIni = (SELECT TOP 1 DateFrom FROM AgentsSettlements WHERE WeekendDate = @WeekendDate)
SET @DateEnd = (SELECT TOP 1 DateTo FROM AgentsSettlements WHERE WeekendDate = @WeekendDate)

DECLARE curAgents CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT Agent
FROM	@AgentsSettlements

OPEN curAgents 
FETCH FROM curAgents INTO @Agent

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT RTRIM(ACTNUMBR_1) + ''-'' + RTRIM(ACTNUMBR_2) + ''-'' + RTRIM(ACTNUMBR_3) AS ACTNUMST FROM NDS.dbo.GL00100 WHERE ACTDESCR LIKE ''AGENT RECOVERY - AGENT ' + RTRIM(@Agent) + '%'''
	
	DELETE @tblAccount
	INSERT INTO @tblAccount
	EXECUTE(@Query)
	
	SET @AccountNumber = (SELECT AccountNumber FROM @tblAccount)
	SET @Counter = 0
	SET @Commission = (SELECT Percentage FROM @AgentsSettlements WHERE Agent = @Agent AND RecordType = 'ACC' AND AccessorialCode = 'FRT')
	SET	@IniBalance = (SELECT	SUM(Amount) AS Balance
							FROM	View_EscrowTransactions
							WHERE	CompanyId = 'NDS'
									AND AccountNumber = @AccountNumber
									AND PostingDate <= DATEADD(dd, -7, @WeekendDate)
									AND PostingDate IS NOT Null
									AND DeletedOn IS Null)
	SET	@EndBalance = (SELECT	SUM(Amount) AS Balance
							FROM	View_EscrowTransactions
							WHERE	CompanyId = 'NDS'
									AND AccountNumber = @AccountNumber
									AND PostingDate <= @WeekendDate
									AND PostingDate IS NOT Null
									AND DeletedOn IS Null)
	SET @Deductions = (SELECT	SUM(Amount)
						FROM	AgentsSettlementsTransactions
						WHERE	Company = 'NDS'
								AND Agent = @Agent
								AND WeekendDate = @WeekendDate)
	SET @Counter = @Counter + 1
	SET @Description = 'Manifest'
	SET @Amount3 = (SELECT Amount FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription = 'Base Drayage Sales') - (SELECT SUM(Amount) FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription IN ('Brokered Base Sales'))
	SET @Amount2 = (SELECT SUM(Total) FROM @AgentsSettlements WHERE Agent = @Agent AND AccessorialCode NOT IN (SELECT Code FROM @tblCodes))
	SET @Amount1 = @Amount3 - @Amount2
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Fuel Surcharge'
	SET @Amount1 = (SELECT SUM(Total * -1) FROM @AgentsSettlements WHERE Agent = @Agent AND AccessorialCode = 'FSC')
	SET @Amount2 = 0
	SET @Amount3 = @Amount1 + @Amount2
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Net Sales'
	SET @Amount1 = (SELECT SUM(Amount1) FROM @tblData WHERE Agent = @Agent AND RowId < 3)
	SET @Amount2 = (SELECT SUM(Amount2) FROM @tblData WHERE Agent = @Agent AND RowId < 3)
	SET @Amount3 = (SELECT SUM(Amount3) FROM @tblData WHERE Agent = @Agent AND RowId < 3)
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Driver Pay'
	SET @Amount1 = -((SELECT Amount FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription = 'Driver Payout') - (SELECT Amount FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription = 'Brokered Driver Payout')) + (SELECT Total FROM @AgentsSettlements WHERE Agent = @Agent AND AccessorialCode = 'FSC')
	SET @Amount2 = 0
	SET @Amount3 = @Amount1 + @Amount2
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Carrier Fee (' + FORMAT(@Commission / 100.00, '###.#0%)')
	SET @Amount1 = (SELECT SUM(Amount1 * -1) FROM @tblData WHERE Agent = @Agent AND RowId = 3) * (@Commission / 100)
	SET @Amount2 = (SELECT SUM(Amount * -1) FROM @AgentsSettlements WHERE Agent = @Agent AND AccessorialCode NOT IN (SELECT Code FROM @tblCodes))
	SET @Amount3 = @Amount1 + @Amount2
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Agent Payout'
	SET @Amount1 = (SELECT SUM(Amount1) FROM @tblData WHERE Agent = @Agent AND RowId BETWEEN 3 AND 5)
	SET @Amount2 = (SELECT SUM(Amount2) FROM @tblData WHERE Agent = @Agent AND RowId BETWEEN 3 AND 5)
	SET @Amount3 = (SELECT SUM(Amount3) FROM @tblData WHERE Agent = @Agent AND RowId BETWEEN 3 AND 5)
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 1)

	SET @Commission = ISNULL((SELECT Percentage FROM @AgentsSettlements WHERE Agent = @Agent AND RecordType = 'ACC' AND AccessorialCode = 'BRO'), 0.00)
	PRINT @Commission

	SET @Counter = @Counter + 1
	SET @Description = 'Manifest'
	SET @Amount1 = (SELECT Amount FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription = 'Brokered Base Sales')
	SET @Amount2 = 0
	SET @Amount3 = @Amount1 - @Amount2
	SET @Section = '02'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Vendor'
	SET @Amount1 = (SELECT SUM(-Amount) FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription IN ('Brokered Driver Payout','Brokered Vendor Payout'))
	SET @Amount2 = 0
	SET @Amount3 = @Amount1 + @Amount2
	SET @Section = '02'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Net Sales'
	SET @Amount1 = (SELECT SUM(Amount1) FROM @tblData WHERE Agent = @Agent AND Section = '02' AND RowId < @Counter)
	SET @Amount2 = 0
	SET @Amount3 = @Amount1 + @Amount2
	SET @Section = '02'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Carrier Fee (' + FORMAT(@Commission / 100.00, '###.#0%)')
	SET @Amount1 = ISNULL((SELECT SUM(-Amount1) FROM @tblData WHERE Agent = @Agent AND Section = '02' AND RowId = (@Counter - 1)) * (30.00 / 100), 0)
	SET @Amount2 = 0
	SET @Amount3 = @Amount1 + @Amount2
	SET @Section = '02'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Agent Payout'
	SET @Amount1 = (SELECT SUM(Amount1) FROM @tblData WHERE Agent = @Agent AND Section = '02' AND RowId > (@Counter - 3))
	SET @Amount2 = 0
	SET @Amount3 = @Amount1 + @Amount2
	SET @Section = '02'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 1)

	SET @Counter = @Counter + 1
	SET @Description = 'Total Carrier Fee'
	SET @Amount1 = 0
	SET @Amount2 = 0
	SET @Amount3 = (SELECT SUM(ABS(Amount3)) FROM @tblData WHERE Agent = @Agent AND RowDescription LIKE 'Carrier Fee (%')
	SET @Section = '03'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 1)

	SET @Counter = @Counter + 1
	SET @Description = 'Total Agent Payout'
	SET @Amount1 = 0 --(SELECT SUM(ABS(Amount1)) FROM @tblData WHERE Agent = @Agent AND RowDescription = 'Agent Payout')
	SET @Amount2 = 0 --(SELECT SUM(ABS(Amount2)) FROM @tblData WHERE Agent = @Agent AND RowDescription = 'Agent Payout')
	SET @Amount3 = (SELECT SUM(ABS(Amount3)) FROM @tblData WHERE Agent = @Agent AND RowDescription = 'Agent Payout')
	SET @Section = '03'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 1)

	INSERT INTO @tblData
	SELECT	ROW_NUMBER() OVER (ORDER BY Total DESC) + @Counter AS RowId,
			Agent,
			dbo.PROPER(REPLACE(RecordDescription, AccessorialCode + ' ', '')),
			Total,
			Percentage,
			Amount,
			'04',
			0
	FROM	@AgentsSettlements 
	WHERE	Agent = @Agent 
			AND RecordType = 'ACC' 
			AND AccessorialCode NOT IN ('FRT','FSC','BRO','XFR')

	SET @Counter = (SELECT MAX(RowId) FROM @tblData WHERE Agent = @Agent) + 1
	SET @Description = 'Total Freight Accessorials'
	SET @Amount1 = (SELECT SUM(Amount1) FROM @tblData WHERE Agent = @Agent AND Section = '04')
	SET @Amount2 = 0
	SET @Amount3 = (SELECT SUM(Amount3) FROM @tblData WHERE Agent = @Agent AND Section = '04')
	SET @Section = '04'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 1)

	SET @Counter = (SELECT MAX(RowId) FROM @tblData WHERE Agent = @Agent) + 1
	SET @Description = 'Beginning AR'
	SET @Amount1 = 0
	SET @Amount2 = 0
	SET @Amount3 = @IniBalance
	SET @Section = '05'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 1)

	SET @Counter = (SELECT MAX(RowId) FROM @tblData WHERE Agent = @Agent) + 1
	SET @Description = 'Activity'
	SET @Amount1 = 0
	SET @Amount2 = 0
	SET @Amount3 = ISNULL(@Activity, 0.00)
	SET @Section = '05'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = (SELECT MAX(RowId) FROM @tblData WHERE Agent = @Agent) + 1
	SET @Description = 'Deductions'
	SET @Amount1 = 0
	SET @Amount2 = 0
	SET @Amount3 =ISNULL(@Deductions, 0.00)
	SET @Section = '05'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = (SELECT MAX(RowId) FROM @tblData WHERE Agent = @Agent) + 1
	SET @Description = 'Ending AR'
	SET @Amount1 = 0
	SET @Amount2 = 0
	SET @Amount3 = @EndBalance
	SET @Section = '05'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 1)

	FETCH FROM curAgents INTO @Agent
END

CLOSE curAgents
DEALLOCATE curAgents

DECLARE	@tblFrontPageData Table (
		Agent		Varchar(3),
		DataType	Smallint,
		Concept		Varchar(50),
		Amount		Numeric(12,2))

DECLARE curAgents CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT Agent
FROM	@AgentsSettlements

OPEN curAgents 
FETCH FROM curAgents INTO @Agent

WHILE @@FETCH_STATUS = 0 
BEGIN
	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Base Drayage Sales',
			Amount1
	FROM	@tblData
	WHERE	Section = '01'
			AND RowDescription = 'Net Sales'
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Assessorial Sales',
			Amount2
	FROM	@tblData
	WHERE	Section = '01'
			AND RowDescription = 'Net Sales'
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Fuel Surcharge Sales',
			ABS(Amount3)
	FROM	@tblData
	WHERE	Section = '01'
			AND RowDescription = 'Fuel Surcharge'
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Total Sales',
			Amount3
	FROM	@tblData
	WHERE	Section = '01'
			AND RowDescription = 'Manifest'
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Driver Pay',
			SUM(ABS(Amount3))
	FROM	@tblData
	WHERE	Section = '01'
			AND RowDescription IN ('Driver Pay','Fuel Surcharge')
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Carrier Fees',
			ABS(Amount3)
	FROM	@tblData
	WHERE	Section = '01'
			AND RowDescription LIKE 'Carrier Fee%'
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Chassis Billing Deferral',
			ABS(Amount1 - Amount3)
	FROM	@tblData
	WHERE	Section = '04'
			AND RowDescription = 'Chassis Usage Charges'
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Total Payouts',
			SUM(Amount)
	FROM	@tblFrontPageData
	WHERE	DataType = 1
			AND Concept IN ('Driver Pay','Carrier Fees','Chassis Billing Deferral')
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Agent Balance Before Expenses',
			SUM(CASE WHEN Concept = 'Total Sales' THEN Amount ELSE -Amount END)
	FROM	@tblFrontPageData
	WHERE	DataType = 1
			AND Concept IN ('Total Sales','Total Payouts')
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	Agent,
			2,
			Description,
			Amount
	FROM	AgentsSettlementsTransactions
	WHERE	Company = 'NDS'
			AND Agent = @Agent
			AND WeekendDate = @WeekendDate

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			2,
			'Total Expenses',
			ISNULL(SUM(Amount), 0.00)
	FROM	@tblFrontPageData
	WHERE	DataType = 2
			AND Agent =  @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			3,
			'Balance Due Agent',
			SUM(Amount)
	FROM	@tblFrontPageData
	WHERE	Concept IN ('Agent Balance Before Expenses','Total Expenses')
			AND Agent = @Agent

	FETCH FROM curAgents INTO @Agent
END

CLOSE curAgents
DEALLOCATE curAgents

PRINT @AccountNumber

IF @FrontPage = 1
	SELECT	'NDS' AS Company,
			CAST(@WeekendDate AS Datetime) AS WeekendDate,
			CAG.Name AS CompanyName,
			DAT.*
	FROM	@tblFrontPageData DAT
			LEFT JOIN View_CompaniesAndAgents CAG ON CAG.CompanyId = 'NDS' AND CAG.Agent = DAT.Agent
ELSE
	SELECT	'NDS' AS Company,
			CAG.Name AS CompanyName,
			CAST(@WeekendDate AS Datetime) AS WeekendDate,
			@DateIni AS DateIni,
			@DateEnd AS DateEnd,
			DAT.*
	FROM	@tblData DAT
			LEFT JOIN View_CompaniesAndAgents CAG ON CAG.CompanyId = 'NDS' AND CAG.Agent = DAT.Agent
	ORDER BY Agent, RowId	
