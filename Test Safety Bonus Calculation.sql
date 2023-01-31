
DECLARE	@Company Varchar(5),
		@RunDate Datetime

SET	@Company = 'GIS'
SET @RunDate = '03/08/2012'

DECLARE	@BenStartDate	Datetime,
		@BenPeriods		Int,
		@BenPayRate		Numeric(10,2),
		@VendorId		varchar(10),
		@OldDriverId	varchar(10),
		@VendorName		varchar(50),
		@HireDate		datetime,
		@Period			char(6),
		@PayDate		smalldatetime,
		@BonusPayDate	datetime,
		@Miles			int,
		@ToPay			numeric(38,2),
		@PeriodMiles	int,
		@PeriodPay		numeric(38,2),
		@PeriodToPay	numeric(38,2),
		@SortColumn		int,
		@WeeksCounter	int,
		@PayDriverBonus	Bit
		
SELECT	@PayDriverBonus = PayDriverBonus
FROM	dbo.Companies
WHERE	CompanyId = @Company

-- DELETE SafetyBonus WHERE Company = 'GIS'

	IF @RunDate IS Null
	BEGIN
		SET	@RunDate = dbo.TTOD(dbo.DayFwdBack(GETDATE(),'N','Thursday'))
	END
	ELSE
	BEGIN
		IF DATENAME(weekday, @RunDate) <> 'Thursday'
			SET	@RunDate = dbo.TTOD(dbo.DayFwdBack(@RunDate,'N','Thursday'))
	END
			
	SELECT	@BenStartDate = VarD
	FROM	Parameters
	WHERE	ParameterCode = 'SAFBON_STARTDATE'
			AND Company = @Company

	SELECT	@BenPeriods = VarI
	FROM	Parameters
	WHERE	ParameterCode = 'SAFBON_PAYPERIODS'
			AND Company = @Company
			
	SELECT	@BenPayRate = VarN
	FROM	Parameters
	WHERE	ParameterCode = 'SAFBON_PAYRATE'
			AND Company = @Company

	SELECT	VM.VendorId
			,UPPER(VM.Company) AS Company
			,ISNULL(VO.HireDate,VM.HireDate) AS HireDate
			,VM.TerminationDate
			,VM.SubType
			,VM.Division
			,VM.OldDriverId
	INTO	#TempVendorMaster
	FROM	VendorMaster VM
			LEFT JOIN VendorMaster VO ON VM.Company = VO.Company AND VM.OldDriverId = VO.VendorId
	WHERE	VM.Company = @Company
			AND VM.TerminationDate IS Null

	DELETE	#TempVendorMaster
	WHERE	VendorId IN (SELECT OldDriverId FROM #TempVendorMaster WHERE OldDriverId IS NOT Null)
	
	SELECT	UPPER(VS.Company) AS Company
			,VM.VendorId
			,VM.OldDriverId
			,VM.HireDate
			,dbo.GetVendorName(@Company, VM.VendorId) AS VendorName
			,dbo.DayFwdBack(VS.WeekEndDate,'N','Thursday') AS PayDate
			,dbo.FindBonusPeriod(VM.HireDate, @BenPeriods, VS.WeekEndDate + 5) AS Period
			,dbo.FindBonusPeriodDates(VM.HireDate, @BenPeriods, VS.WeekEndDate + 5) AS BonusPayDate
			,VS.WeekEndDate
			,SUM(VS.Miles) AS Miles
	INTO	#tmpRecords
	FROM	View_DPYTransactions VS
			INNER JOIN #TempVendorMaster VM ON VM.Company = VS.Company AND (VM.VendorId = VS.DriverId OR VM.OldDriverId = VS.DriverId)
			LEFT JOIN SafetyBonus SF ON VS.Company = SF.Company AND VM.VendorId = SF.VendorId AND SF.Period = dbo.FindBonusPeriod(VM.HireDate, @BenPeriods, VS.WeekEndDate + 5)
	WHERE	VM.Company = @Company
			AND VM.TerminationDate IS Null
			AND dbo.DayFwdBack(VS.WeekEndDate,'N','Thursday') BETWEEN @BenStartDate AND @RunDate + 0.99
			AND VS.Miles <> 0
			AND ISNULL(SF.Paid, 0) = 0
	GROUP BY
			VS.Company
			,VM.VendorId
			,VM.OldDriverId
			,VS.WeekEndDate
			,VM.HireDate

	SELECT	Company
			,VendorId
			,OldDriverId
			,VendorName
			,HireDate
			,Period
			,PayDate
			,BonusPayDate
			,Miles
			,ToPay
			,PeriodMiles
			,PeriodMiles * @BenPayRate AS PeriodPay
			,PeriodToPay = (SELECT ISNULL(SUM(DPY.Miles), 0) FROM View_DPYTransactions DPY WHERE DPY.Company = @Company AND DPY.DriverId = DATA.VendorId AND DPY.WeekEndDate < DATA.PayDate) * @BenPayRate
			,SortColumn
			,WeeksCounter
	FROM	(
			SELECT	Company
					,VendorId
					,OldDriverId
					,VendorName
					,HireDate
					,Period
					,PayDate
					,BonusPayDate
					,Miles
					,Miles * @BenPayRate AS ToPay
					--,dbo.FindPeriodMiles(@Company, VendorId, PayDate) AS PeriodMiles
					--,dbo.FindPreviousMiles(@Company, VendorId, PayDate) * @BenPayRate AS PeriodToPay
					,PeriodMiles = (SELECT ISNULL(SUM(DPY.Miles), 0) FROM View_DPYTransactions DPY WHERE DPY.Company = @Company AND DPY.DriverId = RECS.VendorId AND dbo.DayFwdBack(DPY.WeekEndDate,'N','Thursday') = RECS.PayDate)
					--,PeriodToPay = (SELECT ISNULL(SUM(DPY.Miles), 0) FROM View_DPYTransactions DPY WHERE DPY.Company = @Company AND DPY.DriverId = RECS.VendorId AND DPY.WeekEndDate < RECS.PayDate) * @BenPayRate
					,1 AS SortColumn
					,0 AS WeeksCounter
			FROM	#tmpRecords RECS
			) DATA
	ORDER BY
			BonusPayDate 
			,VendorId
			,Period
			,SortColumn
			,PayDate DESC
			
DROP TABLE #TempVendorMaster
DROP TABLE #tmpRecords

-- SELECT * FROM #tmpRecords
/*
SELECT	*
FROM	(
		SELECT	*
				,dbo.FindBonusPeriodDates(HireDate, Period, WeekEnd) AS BonusPayDate2
		FROM	#TEMP
		) RECS
WHERE	YEAR(BonusPayDate2) > 2013
*/