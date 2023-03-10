USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AgentsSettlements_Report]    Script Date: 9/12/2018 4:04:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
NDS20180908
EXECUTE USP_AgentsSettlements_Report '09/08/2018', '22', 1, 0, 0
EXECUTE USP_AgentsSettlements_Report '08/25/2018', '10', 1, 0, 0
EXECUTE USP_AgentsSettlements_Report '07/21/2018', '31', 1, 0, 0
EXECUTE USP_AgentsSettlements_Report '07/28/2018', '46', 0, 0, 0

UPDATE AgentsSettlementsCommisions SET ReportsCreated = 0 WHERE BatchId = 'NDS20180908' AND Agent = '10'
*/
ALTER PROCEDURE [dbo].[USP_AgentsSettlements_Report]
		@WeekendDate		Date,
		@Agent				Varchar(3) = Null,
		@FrontPage			Bit = 1,
		@JustForDate		Bit = 0,
		@SummaryReport		Bit = 0
AS
SET NOCOUNT ON

IF @Agent = ''
	SET @Agent = Null

DECLARE	@BatchId			Varchar(25),
		@Commission			Numeric(5,2),
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
		@AgentAmount		Numeric(10,2),
		@AgentAmountReport	Numeric(10,2),
		@ExtraDeductions	Numeric(10,2) = 0,
		@AgentCommission	Numeric(10,2) = 0,
		@AgentNetCommission	Numeric(10,2) = 0,
		@AgentChassisUsage	Numeric(10,2) = 0,
		@VendorId			Varchar(15),
		@PayrollDate		Date,
		@ACTINDX			Int,
		@Query				Varchar(Max),
		@ChassisBillDef		Bit = 0

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
--INSERT INTO @tblCodes VALUES ('XFR', 'XFR')

INSERT INTO @AgentsSettlements
SELECT	*
FROM	AgentsSettlements
WHERE	WeekendDate = @WeekendDate
		AND (@Agent IS Null
		OR (@Agent IS NOT Null AND Agent = @Agent))
		
SET @BatchId = 'NDS' + CAST(YEAR(@WeekendDate) AS Varchar) + dbo.PADL(CAST(MONTH(@WeekendDate) AS Varchar), 2, '0') + dbo.PADL(CAST(DAY(@WeekendDate) AS Varchar), 2, '0')
SET @DateIni = (SELECT TOP 1 DateFrom FROM AgentsSettlements WHERE WeekendDate = @WeekendDate)
SET @DateEnd = (SELECT TOP 1 DateTo FROM AgentsSettlements WHERE WeekendDate = @WeekendDate)

DECLARE curAgents CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT Agent
FROM	@AgentsSettlements

OPEN curAgents 
FETCH FROM curAgents INTO @Agent

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Agent

	SET @Query = N'SELECT TOP 1 RTRIM(ACTNUMBR_1) + ''-'' + RTRIM(ACTNUMBR_2) + ''-'' + RTRIM(ACTNUMBR_3) AS ACTNUMST FROM NDS.dbo.GL00100 WHERE ACTIVE = 1 AND ACTDESCR LIKE ''AGENT RECOVERY%''  AND RTRIM(ACTNUMBR_1) = ''' + RTRIM(@Agent) + ''''
	
	DELETE @tblAccount

	INSERT INTO @tblAccount
	EXECUTE(@Query)

	SET @AccountNumber = (SELECT TOP 1 AccountNumber FROM @tblAccount)
	SET @ACTINDX = (SELECT TOP 1 ACTINDX FROM NDS.dbo.GL00105 WHERE ACTNUMST = @AccountNumber)
	SET @Counter = 0
	SET @PayrollDate = DATEADD(dd, -2, @WeekendDate)
	SET @VendorId = (SELECT TOP 1 VendorId FROM Agents WHERE Agent = @Agent)
	SET @ChassisBillDef = (SELECT TOP 1 ChassisBillingDeferral FROM Agents WHERE Agent = @Agent)
	SET @AgentAmount = (SELECT TOP 1 Amount FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription = 'Agent Amount')
	SET @Commission = (SELECT TOP 1 Percentage FROM @AgentsSettlements WHERE Agent = @Agent AND RecordType = 'ACC' AND AccessorialCode = 'FRT')
	SET	@IniBalance = (SELECT SUM(BalanceEnd) FROM AgentsSettlementsTransactions WHERE WeekendDate = @WeekendDate AND Agent = @Agent)
	SET @PayrollDate = DATEADD(dd, 5, @WeekendDate)
	SET	@EndBalance = ABS(dbo.GetAgentDeductionBalance(@VendorId, @AccountNumber, 0, @PayrollDate))
	--SET @Activity = (SELECT	SUM(DEBITAMT)
	--				FROM	NDS.dbo.GL20000 
	--				WHERE	ACTINDX = @ACTINDX
	--						AND TRXDATE BETWEEN DATEADD(dd, 1, @WeekendDate) AND @PayrollDate)
	SET @Activity = (SELECT	SUM(Amount)
					FROM	EscrowTransactions
					WHERE	CompanyId = 'NDS'
							AND AccountNumber = @AccountNumber
							AND EnteredBy <> 'Agent Settlement App'
							AND PostingDate BETWEEN DATEADD(dd, -6, @WeekendDate) AND @WeekendDate)
	print DATEADD(dd, 1, @WeekendDate)
	print @PayrollDate
	PRINT 'GL Account: ' + @AccountNumber

	SET @ExtraDeductions = ISNULL((SELECT ROUND((Total - Amount) / 2, 2) FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription = '326 OVERWEIGHT'),0)
	SET @Counter = @Counter + 1
	SET @Description = 'Manifest'
	SET @Amount3 = ISNULL((SELECT Amount FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription = 'Base Drayage Revenue') - (SELECT SUM(Amount) FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription IN ('Brokered Base Revenue')),0)
	SET @Amount2 = ISNULL((SELECT SUM(Total) FROM @AgentsSettlements WHERE Agent = @Agent AND AccessorialCode NOT IN (SELECT Code FROM @tblCodes)), 0)
	SET @Amount1 = @Amount3 - @Amount2
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Fuel Surcharge'
	SET @Amount1 = ISNULL((SELECT SUM(Total * -1) FROM @AgentsSettlements WHERE Agent = @Agent AND AccessorialCode = 'FSC'), 0)
	SET @Amount2 = 0
	SET @Amount3 = @Amount1 + @Amount2
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Net Revenue'
	SET @Amount1 = ISNULL((SELECT SUM(Amount1) FROM @tblData WHERE Agent = @Agent AND RowId < 3),0)
	SET @Amount2 = (SELECT SUM(Amount2) FROM @tblData WHERE Agent = @Agent AND RowId < 3)
	SET @Amount3 = (SELECT SUM(Amount3) FROM @tblData WHERE Agent = @Agent AND RowId < 3)
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)
	
	SET @Counter = @Counter + 1
	SET @Description = 'Driver Pay'
	SET @Amount1 = ISNULL((((SELECT Amount FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription = 'Driver Payout')) - (SELECT Amount FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription = 'Brokered Driver Payout') - (SELECT Total FROM @AgentsSettlements WHERE Agent = @Agent AND AccessorialCode = 'FSC')) * -1,0)
	SET @Amount2 = 0
	SET @Amount3 = @Amount1
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Carrier Fee (' + FORMAT(@Commission / 100.00, '###.#0%)')
	SET @Amount1 = ISNULL((SELECT SUM(Amount1 * -1) FROM @tblData WHERE Agent = @Agent AND RowId = 3) * (@Commission / 100),0)
	SET @Amount2 = ISNULL((SELECT SUM(Amount * -1) FROM @AgentsSettlements WHERE Agent = @Agent AND AccessorialCode NOT IN (SELECT Code FROM @tblCodes)),0)
	SET @Amount3 = @Amount1 + @Amount2
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Agent Payout'
	SET @Amount1 = ISNULL((SELECT SUM(Amount1) FROM @tblData WHERE Agent = @Agent AND RowId BETWEEN 3 AND 5),0)
	SET @Amount2 = ISNULL((SELECT SUM(Amount2) FROM @tblData WHERE Agent = @Agent AND RowId BETWEEN 3 AND 5),0)
	SET @Amount3 = ISNULL((SELECT SUM(Amount3) FROM @tblData WHERE Agent = @Agent AND RowId BETWEEN 3 AND 5),0)
	SET @Section = '01'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 1)

	SET @AgentAmountReport = (SELECT @Amount3 FROM @tblData WHERE Agent = @Agent AND RowDescription = 'Agent Payout')
	SET @Commission = ISNULL((SELECT Percentage FROM @AgentsSettlements WHERE Agent = @Agent AND RecordType = 'ACC' AND AccessorialCode = 'BRO'), 0.00)
	SET @Counter = @Counter + 1
	SET @Description = 'Manifest'
	SET @Amount1 = ISNULL((SELECT Amount FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription = 'Brokered Base Revenue'), 0)
	SET @Amount2 = 0
	SET @Amount3 = ISNULL(@Amount1 - @Amount2, 0)
	SET @Section = '02'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Vendor'
	SET @Amount1 = (SELECT SUM(-Amount) FROM @AgentsSettlements WHERE Agent = @Agent AND RecordDescription IN ('Brokered Driver Payout','Brokered Vendor Payout'))
	SET @Amount2 = 0
	SET @Amount3 = @Amount1
	SET @Section = '02'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = @Counter + 1
	SET @Description = 'Net Revenue'
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
	SET @Amount1 = 0
	SET @Amount2 = 0
	SET @Amount3 = (SELECT SUM(ABS(Amount3)) FROM @tblData WHERE Agent = @Agent AND RowDescription = 'Agent Payout')
	SET @AgentCommission = @Amount3
	SET @Section = '03'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 1)

	PRINT 'Agent Amount: ' + CAST(@AgentAmount AS Varchar)
	print @Amount3
	
	IF @Amount3 <> @AgentAmount
	BEGIN
		DECLARE @tmpCarrierFee	Numeric(10,2),
				@tmpNetSales	Numeric(10,2),
				@tmpCarrierPrc	Numeric(10,2)

		SET @tmpNetSales = (SELECT Amount1 FROM @tblData WHERE RowDescription = 'Net Revenue' AND Section = '01')
		SET @tmpCarrierFee = (SELECT Amount1 - (@Amount3 - @AgentAmount) FROM @tblData WHERE RowDescription LIKE 'Carrier Fee (%' AND Section = '01')
		SET @tmpCarrierPrc = (ABS(@tmpCarrierFee) / @tmpNetSales) * 100.00

		UPDATE	@tblData 
		SET		Amount1 = Amount1 - (@Amount3 - @AgentAmount),
				Amount3 = Amount3 - (@Amount3 - @AgentAmount),
				RowDescription = 'Carrier Fee (' + CAST(ROUND(@tmpCarrierPrc, 2) AS Varchar) + '%)'
		WHERE	Agent = @Agent 
				AND RowDescription LIKE 'Carrier Fee (%'
				AND Section = '01'

		UPDATE	@tblData 
		SET		Amount1 = Amount1 - (@Amount3 - @AgentAmount),
				Amount3 = Amount3 - (@Amount3 - @AgentAmount)
		WHERE	Agent = @Agent 
				AND RowDescription = 'Agent Payout'
				AND Section = '01'

		UPDATE	@tblData 
		SET		Amount3 = (SELECT SUM(ABS(Amount3)) FROM @tblData WHERE Agent = @Agent AND RowDescription LIKE 'Carrier Fee (%')
		WHERE	Agent = @Agent 
				AND RowDescription LIKE 'Total Carrier Fee'
				AND Section = '03'

		UPDATE	@tblData 
		SET		Amount3 = @AgentAmount
		WHERE	Agent = @Agent 
				AND RowDescription LIKE 'Total Agent Payout'
				AND Section = '03'

		SET @AgentCommission = @AgentAmount
	END

	EXECUTE USP_AgentsSettlementsCommisions 'NDS', @Agent, @BatchId, @AgentCommission, Null, Null

	INSERT INTO @tblData
	SELECT	ROW_NUMBER() OVER (ORDER BY Total DESC) + @Counter AS RowId,
			Agent,
			dbo.PROPER(REPLACE(RecordDescription, AccessorialCode + ' ', '')),
			ISNULL(Total,0) AS Total,
			ISNULL(Percentage, 0) AS Percentage,
			ISNULL(Amount, 0) AS Amount,
			'04',
			0
	FROM	@AgentsSettlements 
	WHERE	Agent = @Agent 
			AND RecordType = 'ACC' 
			AND AccessorialCode NOT IN ('FRT','FSC','BRO') --,CASE WHEN @JustForDate = 0 THEN 'XFR' ELSE 'NON' END)
			--AND Amount <> 0

	SET @Counter = ISNULL((SELECT MAX(RowId) FROM @tblData WHERE Agent = @Agent),0) + 1
	SET @Description = 'Total Freight Accessorials'
	SET @Amount1 = ISNULL((SELECT SUM(Amount1) FROM @tblData WHERE Agent = @Agent AND Section = '04'),0)
	SET @Amount2 = 0
	SET @Amount3 = ISNULL((SELECT SUM(Amount3) FROM @tblData WHERE Agent = @Agent AND Section = '04'),0)
	SET @Section = '04'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 1)

	SET @AgentChassisUsage = (SELECT Amount1 - Amount3 FROM @tblData WHERE Agent = @Agent AND Section = '04' AND RowDescription LIKE 'Chassis Usage %')
	EXECUTE USP_AgentsSettlementsCommisions 'NDS', @Agent, @BatchId, Null, Null, @AgentChassisUsage

	SET @Counter = (SELECT MAX(RowId) FROM @tblData WHERE Agent = @Agent) + 1
	SET @Description = 'Beginning AR'
	SET @Amount1 = 0
	SET @Amount2 = 0
	SET @Amount3 = ISNULL(@IniBalance,0) - ISNULL(@Activity,0)
	SET @Section = '05'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 1)

	SET @Counter = (SELECT MAX(RowId) FROM @tblData WHERE Agent = @Agent) + 1
	SET @Description = 'Activity'
	SET @Amount1 = 0
	SET @Amount2 = 0
	SET @Amount3 = ISNULL(@Activity,0)
	SET @Section = '05'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Deductions = (SELECT	SUM(Amount)
						FROM	AgentsSettlementsTransactions
						WHERE	Company = 'NDS'
								AND WeekendDate = @WeekendDate
								AND Agent = @Agent
								AND Hold = 0
								AND Amount <> 0)

	--SET @Deductions = (SELECT SUM(Amount) FROM (SELECT SUM(PRI.DeductionAmount) AS Amount
	--FROM	View_AgentsSettlements_WeeklyBatch PRI
	--WHERE	PRI.Company = 'NDS'
	--		AND PRI.WeekendDate = @WeekendDate
	--		AND PRI.Agent = @Agent
	--		AND PRI.Hold = 0
	--		AND PRI.BatchId = @BatchId
	--UNION
	--SELECT	SUM(Amount)
	--FROM	AgentsSettlementsTransactions
	--WHERE	Company = 'NDS'
	--		AND WeekendDate = @WeekendDate
	--		AND Agent = @Agent
	--		AND Hold = 0
	--		AND Amount <> 0) DATA)

	SET @Counter = (SELECT MAX(RowId) FROM @tblData WHERE Agent = @Agent) + 1
	SET @Description = 'Deductions'
	SET @Amount1 = 0
	SET @Amount2 = 0
	SET @Amount3 = ISNULL(@Deductions, 0.00)
	SET @Section = '05'
	INSERT INTO @tblData VALUES (@Counter, @Agent, @Description, @Amount1, @Amount2, @Amount3, @Section, 0)

	SET @Counter = (SELECT MAX(RowId) FROM @tblData WHERE Agent = @Agent) + 1
	SET @Description = 'Ending AR'
	SET @Amount1 = 0
	SET @Amount2 = 0
	SET @Amount3 = ISNULL(@IniBalance,0) - ISNULL(@Deductions, 0.00)  --ISNULL(@EndBalance,0)
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
		Amount		Numeric(12,2),
		Balance		Numeric(12,2),
		BalanceType	Smallint,
		IsTotal		Bit)

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
			'Base Drayage Revenue',
			SUM(Amount1),
			0, 0, 0
	FROM	@tblData
	WHERE	Section IN ('01','02')
			AND RowDescription = 'Net Revenue'
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Assessorial Revenue',
			Amount2,
			0, 0, 0
	FROM	@tblData
	WHERE	Section = '01'
			AND RowDescription = 'Net Revenue'
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Fuel Surcharge Revenue',
			ABS(Amount3),
			0, 0, 0
	FROM	@tblData
	WHERE	Section = '01'
			AND RowDescription = 'Fuel Surcharge'
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Total Revenue',
			SUM(Amount3),
			0, 0, 0
	FROM	@tblData
	WHERE	Agent = @Agent
			AND ((Section = '01'
			AND RowDescription = 'Manifest')
			OR (Section = '02'
			AND RowDescription = 'Net Revenue'))

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Driver Pay',
			SUM(ABS(Amount3)),
			0, 0, 0
	FROM	@tblData
	WHERE	Section = '01'
			AND RowDescription IN ('Driver Pay','Fuel Surcharge')
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Carrier Fees',
			ABS(SUM(Amount3)),
			0, 0, 0
	FROM	@tblData
	WHERE	Section IN ('01','02')
			AND RowDescription LIKE 'Carrier Fee%'
			AND Agent = @Agent

	IF @ChassisBillDef = 1
	BEGIN
		INSERT INTO @tblFrontPageData
		SELECT	@Agent,
				1,
				'Chassis Billing Deferral',
				ABS(Amount1 - Amount3),
				0, 0, 0
		FROM	@tblData
		WHERE	Section = '04'
				AND RowDescription = 'Chassis Usage Charges'
				AND Agent = @Agent
	END
	PRINT 'Deduct Chassis Billing Deferral:' + CASE WHEN @ChassisBillDef = 1 THEN 'YES' ELSE 'NO' END

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			1,
			'Total Payouts',
			SUM(Amount),
			0, 0, 1
	FROM	@tblFrontPageData
	WHERE	DataType = 1
			AND Concept IN ('Driver Pay','Carrier Fees','Chassis Billing Deferral')
			AND Agent = @Agent

	INSERT INTO @tblFrontPageData
	SELECT	Agent,
			IsTotal,
			'Agent Balance Before Expenses',
			Amount3,
			0, 0, 0
	FROM	@tblData 
	WHERE	Agent = @Agent 
			AND RowDescription LIKE 'Total Agent Payout'
			AND Section = '03'
	
	IF @ChassisBillDef = 1
	BEGIN
		UPDATE	@tblFrontPageData
		SET		Amount = Amount - DATA.DedAmount
		FROM	(
				SELECT	Amount1 - Amount3 AS DedAmount
				FROM	@tblData
				WHERE	Section = '04'
						AND RowDescription = 'Chassis Usage Charges'
						AND Agent = @Agent
				) DATA
		WHERE	Agent = @Agent
				AND Concept = 'Agent Balance Before Expenses'
	END

	INSERT INTO @tblFrontPageData
	SELECT	PRI.Agent,
			3,
			PRI.DeductionDescription,
			PRI.DeductionAmount,
			ISNULL(CASE WHEN PRI.MaintainBalance = 0 THEN 0 ELSE 
				CASE WHEN PRI.NumberOfDeductions > 0 THEN PRI.InitialBalance - PRI.DeductionAmount 
						WHEN PRI.MaxDeduction > 0 THEN PRI.MaxDeduction - PRI.InitialBalance - PRI.DeductionAmount 
						ELSE PRI.Balance
				END
			END, 0) AS Balance,
			CASE WHEN PRI.MaintainBalance = 0 THEN 0 ELSE 
				CASE WHEN PRI.NumberOfDeductions > 0 THEN 2
						WHEN PRI.MaxDeduction > 0 THEN 3
						ELSE 4 END
			END AS BalanceType,
			0
	FROM	View_AgentsSettlements_WeeklyBatch PRI
	WHERE	PRI.Company = 'NDS'
			AND PRI.WeekendDate = @WeekendDate
			AND PRI.Agent = @Agent
			AND PRI.Hold = 0
			AND PRI.BatchId = @BatchId

	INSERT INTO @tblFrontPageData
	SELECT	Agent,
			3,
			ProNumber AS Description,
			Amount,
			(BalanceIni - Amount) AS Balance,
			1 AS BalanceType,
			0
	FROM	AgentsSettlementsTransactions
	WHERE	Company = 'NDS'
			AND WeekendDate = @WeekendDate
			AND Agent = @Agent
			AND Hold = 0
			AND Amount <> 0

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			3,
			'Total Deductions',
			ISNULL(SUM(Amount), 0) AS Amount,
			0, 0, 1
	FROM	@tblFrontPageData
	WHERE	Agent = @Agent
			AND DataType = '3'

	INSERT INTO @tblFrontPageData
	SELECT	@Agent,
			4,
			'Balance Due Agent',
			SUM(Amount * CASE WHEN DataType = 3 THEN -1 ELSE 1 END),
			0, 0, 1
	FROM	@tblFrontPageData
	WHERE	Concept IN ('Agent Balance Before Expenses','Total Deductions') -- 'Total Expenses',
			AND Agent = @Agent

	SET @AgentNetCommission = (SELECT Amount FROM @tblFrontPageData WHERE DataType = 4 AND Concept = 'Balance Due Agent' AND Agent = @Agent)

	EXECUTE USP_AgentsSettlementsCommisions 'NDS', @Agent, @BatchId, Null, @AgentNetCommission, Null

	FETCH FROM curAgents INTO @Agent
END

CLOSE curAgents
DEALLOCATE curAgents

IF @SummaryReport = 0
BEGIN
	IF @FrontPage = 1
	BEGIN
		UPDATE	AgentsSettlementsCommisions
		SET		ReportsCreated = 1,
				SubmitForApproval = 0
		WHERE	BatchId = @BatchId
				AND Agent = @Agent

		SELECT	DISTINCT 'NDS' AS Company,
				CAST(@WeekendDate AS Datetime) AS WeekendDate,
				RTRIM(CAG.Agent) + ' - ' + RTRIM(LTRIM(SUBSTRING(CAG.Name, dbo.AT(':', CAG.Name, 1) + 1, 50))) AS CompanyName,
				DAT.*
		FROM	@tblFrontPageData DAT
				LEFT JOIN View_CompaniesAndAgents CAG ON CAG.CompanyId = 'NDS' AND CAG.Agent = DAT.Agent
		ORDER BY 1, 4, 5, 10
	END
	ELSE
		SELECT	DISTINCT 'NDS' AS Company,
				RTRIM(CAG.Agent) + ' - ' + RTRIM(LTRIM(SUBSTRING(CAG.Name, dbo.AT(':', CAG.Name, 1) + 1, 50))) AS CompanyName,
				CAST(@WeekendDate AS Datetime) AS WeekendDate,
				@DateIni AS DateIni,
				@DateEnd AS DateEnd,
				DAT.RowId,
				DAT.Agent,
				CASE WHEN DAT.RowDescription LIKE 'Carrier Fee (%' THEN 'Carrier Fee' ELSE DAT.RowDescription END AS RowDescription,
				--DAT.RowDescription,
				DAT.Amount1,
				DAT.Amount2,
				DAT.Amount3,
				DAT.Section,
				DAT.IsTotal
		FROM	@tblData DAT
				LEFT JOIN View_CompaniesAndAgents CAG ON CAG.CompanyId = 'NDS' AND CAG.Agent = DAT.Agent
		ORDER BY Agent, RowId	
END
ELSE
BEGIN
	DECLARE @tblSummary Table (
	Concept		Varchar(100),
	Freight		Numeric(10,2),
	Brokerage	Numeric(10,2) Null,
	Accesorial	Numeric(10,2),
	Total		Numeric(10,2) Null,
	Section		Smallint)
	
	INSERT INTO @tblSummary (Concept, Freight, Accesorial, Section)
	SELECT	RowDescription,
			Amount1,
			Amount2,
			1
	FROM	@tblData
	WHERE	RowDescription = 'Manifest'
			AND Section = '01'

	UPDATE	@tblSummary
	SET		Brokerage	= DATA.Amount1,
			Total		= DATA.Amount1 + Freight + Accesorial
	FROM	@tblData DATA
	WHERE	Concept = DATA.RowDescription
			AND DATA.Section = '02'

	INSERT INTO @tblSummary (Concept, Freight, Accesorial, Section)
	SELECT	'Fuel Surcharge/Vendor Pay' AS RowDescription,
			Amount1,
			Amount2,
			1
	FROM	@tblData
	WHERE	RowDescription = 'Fuel Surcharge'
			AND Section = '01'

	UPDATE	@tblSummary
	SET		Brokerage	= DATA.Amount1,
			Total		= DATA.Amount1 + Freight + Accesorial
	FROM	@tblData DATA
	WHERE	Concept = 'Fuel Surcharge/Vendor Pay'
			AND DATA.RowDescription = 'Vendor'
			AND DATA.Section = '02'

	INSERT INTO @tblSummary (Concept, Freight, Accesorial, Section)
	SELECT	RowDescription,
			Amount1,
			Amount2,
			1
	FROM	@tblData
	WHERE	RowDescription = 'Net Revenue'
			AND Section IN ('01','02')

	UPDATE	@tblSummary
	SET		Brokerage	= DATA.Amount1,
			Total		= DATA.Amount1 + Freight + Accesorial
	FROM	@tblData DATA
	WHERE	Concept = DATA.RowDescription
			AND DATA.Section = '02'

	INSERT INTO @tblSummary (Concept, Freight, Accesorial, Brokerage, Total, Section)
	SELECT	RowDescription,
			Amount1,
			Amount2,
			0,
			Amount1 + Amount2,
			1
	FROM	@tblData
	WHERE	RowDescription = 'Driver Pay'
			AND Section = '01'

	INSERT INTO @tblSummary (Concept, Freight, Accesorial, Section)
	SELECT	'Carrier Fee' AS RowDescription,
			Amount1,
			Amount2,
			1
	FROM	@tblData
	WHERE	RowDescription LIKE 'Carrier Fee%'
			AND Section IN ('01','02')

	UPDATE	@tblSummary
	SET		Brokerage	= DATA.Amount1,
			Total		= DATA.Amount1 + Freight + Accesorial
	FROM	@tblData DATA
	WHERE	Concept = 'Carrier Fee'
			AND DATA.RowDescription LIKE 'Carrier Fee%'
			AND DATA.Section = '02'

	INSERT INTO @tblSummary (Concept, Freight, Accesorial, Section)
	SELECT	RowDescription,
			Amount1,
			Amount2,
			2
	FROM	@tblData
	WHERE	RowDescription = 'Agent Payout'
			AND Section = '01'

	UPDATE	@tblSummary
	SET		Brokerage	= DATA.Amount1,
			Total		= DATA.Amount1 + Freight + Accesorial
	FROM	@tblData DATA
	WHERE	Concept = DATA.RowDescription
			AND DATA.Section = '02'

	SELECT	*
	FROM	@tblSummary
END
