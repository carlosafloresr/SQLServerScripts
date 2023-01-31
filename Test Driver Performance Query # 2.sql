DECLARE	@Company	Varchar(5) = 'DNJ', 
		@OnlyDetail Bit = 0, 
		@DriverType Int = 0, 
		@RunDate	Datetime = '02/02/2017',
		@DriverId	Varchar(12) = Null,
		@Division	Char(2) = Null,
		@Terminated	Bit = 1

DECLARE	@MinDate	Datetime,
		@MaxDate	Datetime,
		@SD1		Datetime,
		@ED1		Datetime,
		@SD2		Datetime,
		@ED2		Datetime,
		@CompanyNo	Int,
		@CompanyStr	Varchar(50),
		@Query		Varchar(500),
		@WithAgents	Bit

PRINT 'Starting... ' + CONVERT(Varchar, GETDATE(), 109)

IF @RunDate IS Null
	SET @RunDate = CAST(CONVERT(Char(10), GETDATE(), 101) AS Datetime)

IF DATENAME(weekday, @RunDate) <> 'Thursday'
	SET	@RunDate = GPCustom.dbo.TTOD(GPCustom.dbo.DayFwdBack(@RunDate,'N','Thursday'))

IF NOT EXISTS(SELECT TOP 1 DOCDATE FROM GPCustom.dbo.PM10300 WHERE Company = @Company AND DocDate BETWEEN @RunDate - 3 AND @RunDate)
	SET	@RunDate = @RunDate - 7

SET @MinDate	= DATEADD(dd, -365, @RunDate)
SET	@MaxDate	= CAST(CONVERT(Char(10), @RunDate, 101) + ' 11:59:59 pm' AS Datetime)
SET	@SD1		= CAST(CONVERT(Char(10), DATEADD(dd, -182, @RunDate), 101) AS Datetime)
SET	@ED1		= @MaxDate
SET	@SD2		= CAST(CONVERT(Char(10), @MinDate, 101) AS Datetime)
SET	@ED2		= @SD1 - 1

SELECT	@CompanyNo	= CompanyNumber,
		@WithAgents	= WithAgents
FROM	GPCustom.dbo.Companies 
WHERE	CompanyId = @Company

IF @DriverId IS Null
BEGIN
	IF @WithAgents = 1
		SET @Query	= 'SELECT CO.Code AS VendorId, CO.Div_Code AS Division, CO.Cmpy_No AS CompanyId FROM trk.driver CO, com.company CY WHERE CO.Cmpy_No = CY.No AND CY.AgentOf_Cmpy_No = ' + CAST(@CompanyNo AS Varchar)
	ELSE
		SET @Query	= 'SELECT Code AS VendorId, Div_Code AS Division, Cmpy_No AS CompanyId FROM trk.driver WHERE Cmpy_No = ' + CAST(@CompanyNo AS Varchar)
END
ELSE
BEGIN
	IF @WithAgents = 1
		SET @Query	= 'SELECT CO.Code AS VendorId, CO.Div_Code AS Division, CO.Cmpy_No AS CompanyId FROM trk.driver CO, com.company CY WHERE CO.Cmpy_No = CY.No AND CY.AgentOf_Cmpy_No = ' + CAST(@CompanyNo AS Varchar) + ' AND CO.Code = ''' + RTRIM(@DriverId) + ''''
	ELSE
		SET @Query	= 'SELECT Code AS VendorId, Div_Code AS Division, Cmpy_No AS CompanyId FROM trk.driver WHERE Code = ''' + RTRIM(@DriverId) + ''' AND Cmpy_No = ' + CAST(@CompanyNo AS Varchar)
END

EXECUTE GPCustom.dbo.USP_QuerySWS @Query, '##tmpDrivers'

PRINT 'SWS Drivers ' + CONVERT(Varchar, GETDATE(), 109)

SELECT	DISTINCT VM.VendorId
		,VM.DriverName AS VendorName
		,VM.Company
		,ISNULL(VO.HireDate,VM.HireDate) AS HireDate
		,VM.DriverType
		,VM.MyTruckStartDate
		,VM.TerminationDate
		,VM.SubType
		,CASE WHEN DR.Division = '' OR DR.Division IS NULL THEN VM.Division ELSE DR.Division END AS Division
		,DI.DivisionName
		,VM.OldDriverId
		,VM.RCCLAccount
INTO	#TempVendorMaster
FROM	GPCustom.dbo.View_DriverMaster VM
		INNER JOIN GPCustom.dbo.View_CompanyAgents CO ON VM.Company = CO.CompanyId
		LEFT JOIN ##tmpDrivers DR ON VM.VendorId = DR.VendorId AND CO.CompanyNumber = DR.CompanyId
		LEFT JOIN GPCustom.dbo.View_Divisions DI ON VM.Company = DI.Fk_CompanyID AND CASE WHEN DR.Division = '' OR DR.Division IS NULL THEN VM.Division ELSE DR.Division END = DI.Division
		LEFT JOIN GPCustom.dbo.VendorMaster VO ON VM.Company = VO.Company AND VM.OldDriverId = VO.VendorId
WHERE	VM.Company = @Company
		AND (@DriverType = 0 OR VM.SubType = @DriverType)
		AND ((@Terminated = 0 AND VM.TerminationDate IS Null) OR (@Terminated = 1 AND VM.TerminationDate IS NOT Null))
		AND (@DriverId IS Null OR (@DriverId IS NOT Null AND VM.VendorId = @DriverId))
		AND (@Division IS Null OR (@Division IS NOT Null AND CASE WHEN DR.Division = '' OR DR.Division IS NULL THEN DI.Division ELSE DR.Division END = @Division))
		AND DI.Division IS NOT Null

DROP TABLE ##tmpDrivers

DELETE	#TempVendorMaster
WHERE	VendorId IN (SELECT OldDriverId FROM #TempVendorMaster WHERE OldDriverId IS NOT Null)

PRINT 'Owenr Operator Drivers ' + CONVERT(Varchar, GETDATE(), 109)

SELECT	OOS.Company
		,OOS.WED
		,OOS.Vendorid
		,SUM(CASE WHEN OOS.ColumnType = 'STDESCROW' THEN OOS.DedAmount ELSE 0.00 END) AS StandardEscrow
		,SUM(CASE WHEN OOS.ColumnType = 'OOINSURANCE' THEN OOS.DedAmount ELSE 0.00 END) AS OOInsurance
		,SUM(CASE WHEN OOS.ColumnType = 'PEOPLENET' THEN OOS.DedAmount ELSE 0.00 END) AS PeopleNet
		,SUM(CASE WHEN OOS.ColumnType = 'GARNISHMENTS' THEN OOS.DedAmount ELSE 0.00 END) AS Garnishments
		,SUM(CASE WHEN OOS.ColumnType = 'M&R' THEN OOS.DedAmount ELSE 0.00 END) AS MaintAndRepairs
		,SUM(CASE WHEN OOS.ColumnType = 'LEASEPAYMENT' THEN OOS.DedAmount ELSE 0.00 END) AS LeasePayment
		,SUM(CASE WHEN OOS.ColumnType = 'SAVING' THEN OOS.DedAmount ELSE 0.00 END) AS Savings
		,SUM(CASE WHEN OOS.ColumnType = 'ADVREPAY' THEN OOS.DedAmount ELSE 0.00 END) AS EscrowRepayment
		,SUM(CASE WHEN OOS.ColumnType = 'TAG&TAXES' THEN OOS.DedAmount ELSE 0.00 END) AS TagsandTaxes
		,SUM(CASE WHEN OOS.ColumnType = 'OTHERINS' THEN ISNULL(OOS.DedAmount, 0.00) ELSE 0.00 END) AS OtherInsurance
		,SUM(CASE WHEN OOS.ColumnType = 'OTHER' OR OOS.ColumnType IS Null THEN ISNULL(OOS.DedAmount, 0.00) ELSE 0.00 END) AS OtherDeductions
INTO	##tmpOOSData
FROM	GPCustom.dbo.View_OOS_Transactions OOS
		INNER JOIN #TempVendorMaster VND ON OOS.Company = VND.Company AND (OOS.VendorId = VND.VendorId OR OOS.VendorId = VND.OldDriverId)
WHERE	OOS.Company = @Company
		AND OOS.WED BETWEEN @MinDate AND @MaxDate
		AND OOS.Trans_DeletedOn IS Null
GROUP BY
		OOS.Company
		,OOS.WED
		,OOS.Vendorid

PRINT 'Owenr Operator Payroll Data ' + CONVERT(Varchar, GETDATE(), 109)

SELECT	FUE.Company,
		FUE.VendorId,
		FUE.WeekEndDate,
		SUM(FUE.TotalFuel) AS TotalFuel,
		SUM(FUE.Gallons) AS Gallons,
		SUM(FUE.Cash) AS Cash,
		SUM(FUE.CashFee) AS CashFee
INTO	##tmpFuelData
FROM	ILSINT01.Integrations.dbo.View_Integration_FPT_Summary FUE
		INNER JOIN #TempVendorMaster VND ON FUE.Company = VND.Company AND (FUE.VendorId = VND.VendorId OR FUE.VendorId = VND.OldDriverId)
WHERE	FUE.Company = @Company
GROUP BY
		FUE.Company,
		FUE.VendorId,
		FUE.WeekEndDate

PRINT 'Owenr Operator Fuel Data ' + CONVERT(Varchar, GETDATE(), 109)

SELECT	Company
		,VendorId
		,DocDate
		,MAX(ChekTotl) AS ChekTotl
		,SUM(ManualATP) AS ManualATP
		,SUM(TiresDeduction) AS TiresDeduction
		,SUM(EscrowInterest) AS EscrowInterest
		,SUM(OtherDeductions2) AS OtherDeductions2
		,SUM(SafetyBonus) AS SafetyBonus
INTO	#tmpManualTransactions
FROM	(
		SELECT	PH.Company
				,PH.VendorId
				,CASE WHEN GPCustom.dbo.WeekDay(PD.DocDate) = 5 THEN PH.DocDate ELSE GPCustom.dbo.DayFwdBack(PH.DocDate, 'P', 'Saturday') END AS DocDate
				,PH.ChekTotl
				,SUM(CASE WHEN LEFT(PD.ApfVchnm, 3) = '000' AND PATINDEX('%TIRE%', PD.TrxDscrn) = 0 THEN PD.Outstanding_Amount * -1 ELSE 0.00 END) AS ManualATP -- AND PATINDEX('BONUS%', PD.DOCNUMBR) = 0
				,SUM(CASE WHEN LEFT(PD.ApfVchnm, 3) = '000' AND PATINDEX('%TIRE%', PD.TrxDscrn) > 0 THEN PD.Outstanding_Amount * -1 ELSE 0.00 END) AS TiresDeduction
				,SUM(CASE WHEN LEFT(PD.ApfVchnm, 3) = 'EIN' THEN PD.Outstanding_Amount * -1 ELSE 0.00 END) AS EscrowInterest
				,SUM(CASE WHEN LEFT(PD.ApfVchnm, 3) NOT IN ('000','DPY','EIN','FPT','OOS') THEN PD.Outstanding_Amount * -1 ELSE 0.00 END) AS OtherDeductions2
				,SUM(CASE WHEN LEFT(PD.ApfVchnm, 3) = '000' AND PATINDEX('BONUS%', PD.DOCNUMBR) > 0 THEN PD.Outstanding_Amount * 1 ELSE 0.00 END) AS SafetyBonus
		FROM	GPCustom.dbo.PM10300 PH
				INNER JOIN #TempVendorMaster VND ON PH.Company = VND.Company AND PH.VendorId = VND.VendorId
				INNER JOIN GPCustom.dbo.PM10201 PD ON PH.Company = PD.Company AND PH.PmntNmbr = PD.PmntNmbr
		WHERE	PH.Company = @Company
				AND PH.DocDate BETWEEN @MinDate AND @MaxDate
				AND PH.IsTemporal = 0
				AND PATINDEX('BONUS%', PD.DOCNUMBR) = 0
		GROUP BY
				PH.Company
				,PH.VendorId
				,CASE WHEN GPCustom.dbo.WeekDay(PD.DocDate) = 5 THEN PH.DocDate ELSE GPCustom.dbo.DayFwdBack(PH.DocDate, 'P', 'Saturday') END
				,PH.ChekTotl
		UNION
		SELECT	PH.Company
				,PH.VendorId
				,CASE WHEN GPCustom.dbo.WeekDay(PD.DocDate) = 5 THEN PH.DocDate ELSE GPCustom.dbo.DayFwdBack(PH.DocDate, 'P', 'Saturday') END AS DocDate
				,0 AS ChekTotl
				,0 AS ManualATP
				,0 AS TiresDeduction
				,0 AS EscrowInterest
				,0 AS OtherDeductions2
				,SUM(CASE WHEN LEFT(PD.ApfVchnm, 3) = '000' AND PATINDEX('BONUS%', PD.DOCNUMBR) > 0 THEN PD.Outstanding_Amount * 1 ELSE 0.00 END) AS SafetyBonus
		FROM	GPCustom.dbo.PM10300 PH
				INNER JOIN #TempVendorMaster VND ON PH.Company = VND.Company AND PH.VendorId = VND.VendorId
				INNER JOIN GPCustom.dbo.PM10201 PD ON PH.Company = PD.Company AND PH.PmntNmbr = PD.PmntNmbr
		WHERE	PH.Company = @Company
				AND PH.DocDate BETWEEN @MinDate AND @MaxDate
				AND PH.IsTemporal = 0
				AND PATINDEX('BONUS%', PD.DOCNUMBR) > 0
		GROUP BY
				PH.Company
				,PH.VendorId
				,CASE WHEN GPCustom.dbo.WeekDay(PD.DocDate) = 5 THEN PH.DocDate ELSE GPCustom.dbo.DayFwdBack(PH.DocDate, 'P', 'Saturday') END
		) RECS
GROUP BY Company
		,VendorId
		,DocDate

PRINT 'GP Manual Transactions ' + CONVERT(Varchar, GETDATE(), 109)

SELECT	DPY.Company
		,DPY.WeekEndDate
		,DPY.DriverId
		,DPY.Drayage
		,DPY.Miles
		,DPY.DriverFuelRebate
INTO	#TempDPY
FROM	GPCustom.dbo.View_DPYTransactions DPY
		INNER JOIN #TempVendorMaster VND ON VND.Company = DPY.Company AND (VND.VendorId = DPY.DriverId OR VND.OldDriverId = DPY.DriverId)
WHERE	DPY.Company = @Company
		AND DPY.WeekEndDate BETWEEN @MinDate AND @MaxDate

PRINT 'DPY Transactions Data ' + CONVERT(Varchar, GETDATE(), 109)

SELECT	DISTINCT Company
		,VendorId
		,VendorName
		,DriverType
		,HireDate
		,MyTruckStartDate
		,WeekEndDate
		,Drayage
		,Miles
		,DriverFuelRebate
		,FuelAmount
		,Gallons
		,Division
		,DivisionName
		,StandardEscrow
		,OOInsurance
		,PeopleNet
		,Garnishments
		,MaintAndRepairs
		,LeasePayment
		,Savings
		,EscrowRepayment
		,TagsandTaxes
		,ManualATP
		,TiresDeduction
		,OtherInsurance
		,OtherDeductions
		,CashAdvance
		,OtherDeductions2
		,EscrowInterest
		,CASE WHEN CheckAmount <> 0 THEN CheckAmount ELSE (Drayage + DriverFuelRebate) - FuelAmount - StandardEscrow - OOInsurance - PeopleNet - Garnishments - MaintAndRepairs - LeasePayment - EscrowRepayment - TiresDeduction - OtherInsurance - CashAdvance - Savings - TagsandTaxes - ManualATP - OtherDeductions - OtherDeductions2 END AS CheckAmount
		,ISNULL(MyTruckBalance, 0.00) AS MyTruckBalance
		,SafetyBonus
		,ROW_NUMBER() OVER (PARTITION BY VendorId ORDER BY WeekEndDate DESC) AS RowNumber
INTO	#TempData
FROM	(
		SELECT	DISTINCT DPY.Company
				,VND.VendorId
				,VND.VendorName
				,VND.DriverType
				,VND.HireDate
				,VND.Division
				,VND.DivisionName
				,VND.MyTruckStartDate
				,CASE WHEN VND.SubType = 2 THEN GPCustom.dbo.MyTruckBalance(ISNULL(VND.RCCLAccount, VND.VendorId), DPY.WeekEndDate + 4) ELSE 0.00 END AS MyTruckBalance
				,DPY.WeekEndDate
				,DPY.Drayage
				,DPY.Miles
				,DPY.DriverFuelRebate AS DriverFuelRebate
				,ISNULL(FUE.TotalFuel, 0.00) AS FuelAmount
				,ISNULL(FUE.Gallons, 0.00) AS Gallons
				,ISNULL(FUE.Cash + FUE.CashFee, 0.00) AS CashAdvance
				,ISNULL(OOS.StandardEscrow, 0) AS StandardEscrow
				,ISNULL(OOS.OOInsurance, 0) AS OOInsurance
				,ISNULL(OOS.PeopleNet, 0) AS PeopleNet
				,ISNULL(OOS.Garnishments, 0) AS Garnishments
				,ISNULL(OOS.MaintAndRepairs, 0) AS MaintAndRepairs
				,ISNULL(OOS.LeasePayment, 0) AS LeasePayment
				,ISNULL(OOS.Savings, 0) AS Savings
				,ISNULL(OOS.EscrowRepayment, 0) AS EscrowRepayment
				,ISNULL(OOS.TagsandTaxes, 0) AS TagsandTaxes
				,ISNULL(OOS.OtherInsurance, 0) AS OtherInsurance
				,ISNULL(OOS.OtherDeductions,0) AS OtherDeductions
				,ISNULL(PAY.ManualATP, 0) AS ManualATP
				,ISNULL(PAY.TiresDeduction, 0) AS TiresDeduction
				,ISNULL(PAY.OtherDeductions2, 0) AS OtherDeductions2
				,ISNULL(PAY.EscrowInterest, 0) AS EscrowInterest
				,ISNULL(PAY.ChekTotl, 0) AS CheckAmount
				,ISNULL(PAY.SafetyBonus, 0) AS SafetyBonus
		FROM	#TempDPY DPY
				INNER JOIN #TempVendorMaster VND ON VND.Company = DPY.Company AND (VND.VendorId = DPY.DriverId OR VND.OldDriverId = DPY.DriverId)
				LEFT JOIN ##tmpFuelData FUE ON DPY.Company = FUE.Company AND DPY.WeekEndDate = FUE.WeekEndDate AND VND.VendorId = FUE.VendorId
				LEFT JOIN ##tmpOOSData OOS ON VND.Company = OOS.Company AND DPY.WeekEndDate = OOS.WED AND VND.VendorId = OOS.VendorId
				LEFT JOIN #tmpManualTransactions PAY ON PAY.Company = DPY.Company AND VND.VendorId = PAY.VendorId AND DPY.WeekEndDate = PAY.DocDate
		) RECS

DELETE	#TempData
WHERE	RowNumber > 52

DROP TABLE ##tmpOOSData
DROP TABLE ##tmpFuelData

PRINT 'All Transactions ' + CONVERT(Varchar, GETDATE(), 109)

IF @OnlyDetail = 0
BEGIN
	-- START Individual Calculations
	SELECT	Company
			,Division
			,DivisionName
			,VendorId
			,VendorName
			,DriverType
			,HireDate
			,MyTruckStartDate
			,LastPayDate
			,Drayage
			,Miles
			,DriverFuelRebate
			,FuelAmount
			,Gallons
			,Drayage + DriverFuelRebate AS TotalPay
			,CASE WHEN Gallons = 0 THEN 0 ELSE FuelAmount/Gallons * 1.00 END AS GrossPPG
			,CASE WHEN Gallons = 0 THEN 0 ELSE (FuelAmount - DriverFuelRebate)/Gallons * 1.00 END AS NetPPG
			,Drayage + DriverFuelRebate - FuelAmount AS NetPayAfterFuel
			,CASE WHEN Drayage = 0 THEN 0 ELSE (Drayage + DriverFuelRebate - FuelAmount) / Drayage * 100.00 END AS NetPayAfterFuelPercentage
			,StandardEscrow
			,OOInsurance
			,PeopleNet
			,Garnishments
			,(Drayage + DriverFuelRebate - FuelAmount) - StandardEscrow - OOInsurance - PeopleNet - Garnishments AS NetPayAfterMDs
			,MaintAndRepairs
			,LeasePayment
			,EscrowRepayment
			,Savings
			,TagsandTaxes
			,ManualATP
			,TiresDeduction
			,OtherInsurance
			,OtherDeductions
			,CashAdvance
			,CheckAmount
			,MyTruckBalance
			,SafetyBonus
			,RowNumber
			,RowType
			,ContractualBalance
			,MandRBalance
	FROM	(
			SELECT	Company
					,Division
					,DivisionName
					,VendorId
					,VendorName
					,DriverType
					,HireDate
					,MyTruckStartDate
					,WeekEndDate + 5 AS LastPayDate
					,Drayage
					,Miles
					,DriverFuelRebate
					,FuelAmount
					,Gallons
					,StandardEscrow
					,OOInsurance
					,PeopleNet
					,Garnishments
					,MaintAndRepairs
					,LeasePayment
					,EscrowRepayment
					,Savings
					,TagsandTaxes
					,ManualATP
					,TiresDeduction
					,OtherInsurance
					,OtherDeductions + EscrowInterest AS OtherDeductions
					,CashAdvance
					,CheckAmount
					,MyTruckBalance
					,SafetyBonus
					,RowNumber
					,1 AS RowType
					,GPCustom.dbo.FindDriverEscrowBalance(@Company, VendorId, 1, @RunDate, Null) AS ContractualBalance
					,GPCustom.dbo.FindDriverEscrowBalance(@Company, VendorId, 8, @RunDate, '2793') AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber = 1
			UNION
			SELECT	Company
					,Division
					,DivisionName
					,VendorId
					,VendorName
					,DriverType
					,HireDate
					,MyTruckStartDate
					,Null
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,AVG(MyTruckBalance) AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,4 AS RowNumber
					,2 AS RowType
					,Null AS ContractualBalance
					,Null AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber < 5
			GROUP BY
					Company
					,Division
					,DivisionName
					,VendorId
					,VendorName
					,DriverType
					,HireDate
					,MyTruckStartDate
			UNION
			SELECT	Company
					,Division
					,DivisionName
					,VendorId
					,VendorName
					,DriverType
					,HireDate
					,MyTruckStartDate
					,Null
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,AVG(MyTruckBalance) AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,26 AS RowNumber
					,3 AS RowType
					,Null AS ContractualBalance
					,Null AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber BETWEEN 1 AND 26
			GROUP BY
					Company
					,Division
					,DivisionName
					,VendorId
					,VendorName
					,DriverType
					,HireDate
					,MyTruckStartDate
			UNION
			SELECT	Company
					,Division
					,DivisionName
					,VendorId
					,VendorName
					,DriverType
					,HireDate
					,MyTruckStartDate
					,Null
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,AVG(MyTruckBalance) AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,52 AS RowNumber
					,4 AS RowType
					,Null AS ContractualBalance
					,Null AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber BETWEEN 27 AND 52
			GROUP BY
					Company
					,Division
					,DivisionName
					,VendorId
					,VendorName
					,DriverType
					,HireDate
					,MyTruckStartDate
			) INDIVIDUAL_RECS
	UNION
	-- START All Drivers Calculations
	SELECT	Company
			,'ZZ' AS Division
			,'' AS DivisionName
			,VendorId
			,VendorName
			,DriverType
			,HireDate
			,MyTruckStartDate
			,LastPayDate
			,Drayage
			,Miles
			,DriverFuelRebate
			,FuelAmount
			,Gallons
			,Drayage + DriverFuelRebate AS TotalPay
			,CASE WHEN Gallons = 0 THEN 0 ELSE FuelAmount/Gallons * 1.00 END AS GrossPPG
			,CASE WHEN Gallons = 0 THEN 0 ELSE (FuelAmount - DriverFuelRebate)/Gallons * 1.00 END AS NetPPG
			,Drayage + DriverFuelRebate - FuelAmount AS NetPayAfterFuel
			,CASE WHEN Drayage = 0 THEN 0 ELSE (Drayage + DriverFuelRebate - FuelAmount) / Drayage * 100.00 END AS NetPayAfterFuelPercentage
			,StandardEscrow
			,OOInsurance
			,PeopleNet
			,Garnishments
			,(Drayage + DriverFuelRebate - FuelAmount) - StandardEscrow - OOInsurance - PeopleNet - Garnishments AS NetPayAfterMDs
			,MaintAndRepairs
			,LeasePayment
			,EscrowRepayment
			,Savings
			,TagsandTaxes
			,ManualATP
			,TiresDeduction
			,OtherInsurance
			,OtherDeductions
			,CashAdvance
			,CheckAmount
			,MyTruckBalance
			,SafetyBonus
			,RowNumber
			,RowType
			,ContractualBalance
			,MandRBalance
	FROM	(
			SELECT	Company
					,'' AS Division
					,'ZZZZ1' AS VendorId
					,Company AS VendorName
					,'ALL' AS DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,SUM(MyTruckBalance) AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,RowNumber
					,1 AS RowType
					,SUM(GPCustom.dbo.FindDriverEscrowBalance(@Company, VendorId, 1, @RunDate, Null)) AS ContractualBalance
					,SUM(GPCustom.dbo.FindDriverEscrowBalance(@Company, VendorId, 8, @RunDate, '2793')) AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber = 1
					AND @DriverId IS Null
			GROUP BY 
					Company
					,RowNumber
			UNION
			SELECT	Company
					,'' AS Division
					,'ZZZZ1' AS VendorId
					,Company AS VendorName
					,'ALL' AS DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,0 AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,4 AS RowNumber
					,2 AS RowType
					,Null AS ContractualBalance
					,Null AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber < 5
					AND @DriverId IS Null
			GROUP BY
					Company
			UNION
			SELECT	Company
					,'' AS Division
					,'ZZZZ1' AS VendorId
					,Company AS VendorName
					,'ALL' AS DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,0 AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,26 AS RowNumber
					,3 AS RowType
					,Null AS ContractualBalance
					,Null AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber BETWEEN 1 AND 26
					AND @DriverId IS Null
			GROUP BY
					Company
			UNION
			SELECT	Company
					,'' AS Division
					,'ZZZZ1' AS VendorId
					,Company AS VendorName
					,'ALL' AS DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,0 AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,52 AS RowNumber
					,4 AS RowType
					,Null AS ContractualBalance
					,Null AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber BETWEEN 27 AND 52
					AND @DriverId IS Null
			GROUP BY
					Company
			) ALL_RECS
	-- START Owner Operators Calculations
	UNION
	SELECT	Company
			,'ZZ' AS Division
			,'' AS DivisionName
			,VendorId
			,VendorName
			,DriverType
			,HireDate
			,MyTruckStartDate
			,LastPayDate
			,Drayage
			,Miles
			,DriverFuelRebate
			,FuelAmount
			,Gallons
			,Drayage + DriverFuelRebate AS TotalPay
			,CASE WHEN Gallons = 0 THEN 0 ELSE FuelAmount/Gallons * 1.00 END AS GrossPPG
			,CASE WHEN Gallons = 0 THEN 0 ELSE (FuelAmount - DriverFuelRebate)/Gallons * 1.00 END AS NetPPG
			,Drayage + DriverFuelRebate - FuelAmount AS NetPayAfterFuel
			,CASE WHEN Drayage = 0 THEN 0 ELSE (Drayage + DriverFuelRebate - FuelAmount) / Drayage * 100.00 END AS NetPayAfterFuelPercentage
			,StandardEscrow
			,OOInsurance
			,PeopleNet
			,Garnishments
			,(Drayage + DriverFuelRebate - FuelAmount) - StandardEscrow - OOInsurance - PeopleNet - Garnishments AS NetPayAfterMDs
			,MaintAndRepairs
			,LeasePayment
			,EscrowRepayment
			,Savings
			,TagsandTaxes
			,ManualATP
			,TiresDeduction
			,OtherInsurance
			,OtherDeductions
			,CashAdvance
			,CheckAmount
			,MyTruckBalance
			,SafetyBonus
			,RowNumber
			,RowType
			,Null AS ContractualBalance
			,Null AS MandRBalance
	FROM	(
			SELECT	Company
					,'' AS Division
					,'ZZZZ2' AS VendorId
					,Company AS VendorName
					,DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,SUM(MyTruckBalance) AS MyTruckBalance
					,SUM(SafetyBonus) AS SafetyBonus
					,RowNumber
					,1 AS RowType
			FROM	#TempData
			WHERE	RowNumber = 1
					AND DriverType = 'OO'
					AND @DriverId IS Null
			GROUP BY 
					Company
					,RowNumber
					,DriverType
			UNION
			SELECT	Company
					,'' AS Division
					,'ZZZZ2' AS VendorId
					,Company AS VendorName
					,DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,0 AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,4 AS RowNumber
					,2 AS RowType
			FROM	#TempData
			WHERE	RowNumber < 5
					AND DriverType = 'OO'
					AND @DriverId IS Null
			GROUP BY
					Company
					,DriverType
			UNION
			SELECT	Company
					,'' AS Division
					,'ZZZZ2' AS VendorId
					,Company AS VendorName
					,DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,0 AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,26 AS RowNumber
					,3 AS RowType
			FROM	#TempData
			WHERE	RowNumber BETWEEN 1 AND 26
					AND DriverType = 'OO'
					AND @DriverId IS Null
			GROUP BY
					Company
					,DriverType
			UNION
			SELECT	Company
					,'' AS Division
					,'ZZZZ2' AS VendorId
					,Company AS VendorName
					,DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,0 AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,52 AS RowNumber
					,4 AS RowType
			FROM	#TempData
			WHERE	RowNumber BETWEEN 27 AND 52
					AND DriverType = 'OO'
					AND @DriverId IS Null
			GROUP BY
					Company
					,DriverType
			) OO_RECS
	-- START My Truck Calculations
	UNION
	SELECT	Company
			,'ZZ' AS Division
			,'' AS DivisionName
			,VendorId
			,VendorName
			,DriverType
			,HireDate
			,MyTruckStartDate
			,LastPayDate
			,Drayage
			,Miles
			,DriverFuelRebate
			,FuelAmount
			,Gallons
			,Drayage + DriverFuelRebate AS TotalPay
			,CASE WHEN Gallons = 0 THEN 0 ELSE FuelAmount/Gallons * 1.00 END AS GrossPPG
			,CASE WHEN Gallons = 0 THEN 0 ELSE (FuelAmount - DriverFuelRebate)/Gallons * 1.00 END AS NetPPG
			,Drayage + DriverFuelRebate - FuelAmount AS NetPayAfterFuel
			,CASE WHEN Drayage = 0 THEN 0 ELSE (Drayage + DriverFuelRebate - FuelAmount) / Drayage * 100.00 END AS NetPayAfterFuelPercentage
			,StandardEscrow
			,OOInsurance
			,PeopleNet
			,Garnishments
			,(Drayage + DriverFuelRebate - FuelAmount) - StandardEscrow - OOInsurance - PeopleNet - Garnishments AS NetPayAfterMDs
			,MaintAndRepairs
			,LeasePayment
			,EscrowRepayment
			,Savings
			,TagsandTaxes
			,ManualATP
			,TiresDeduction
			,OtherInsurance
			,OtherDeductions
			,CashAdvance
			,CheckAmount
			,MyTruckBalance
			,SafetyBonus
			,RowNumber
			,RowType
			,Null AS ContractualBalance
			,Null AS MandRBalance
	FROM	(
			SELECT	Company
					,'' AS Division
					,'ZZZZ3' AS VendorId
					,Company AS VendorName
					,DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,SUM(MyTruckBalance) AS MyTruckBalance
					,SUM(SafetyBonus) AS SafetyBonus
					,RowNumber
					,1 AS RowType
			FROM	#TempData
			WHERE	RowNumber = 1
					AND DriverType = 'MYT'
					AND @DriverId IS Null
			GROUP BY 
					Company
					,RowNumber
					,DriverType
			UNION
			SELECT	Company
					,'' AS Division
					,'ZZZZ3' AS VendorId
					,Company AS VendorName
					,DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,AVG(MyTruckBalance) AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,4 AS RowNumber
					,2 AS RowType
			FROM	#TempData
			WHERE	RowNumber < 5
					AND DriverType = 'MYT'
					AND @DriverId IS Null
			GROUP BY
					Company
					,DriverType
			UNION
			SELECT	Company
					,'' AS Division
					,'ZZZZ3' AS VendorId
					,Company AS VendorName
					,DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,AVG(MyTruckBalance) AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,26 AS RowNumber
					,3 AS RowType
			FROM	#TempData
			WHERE	RowNumber BETWEEN 1 AND 26
					AND DriverType = 'MYT'
					AND @DriverId IS Null
			GROUP BY
					Company
					,DriverType
			UNION
			SELECT	Company
					,'' AS Division
					,'ZZZZ3' AS VendorId
					,Company AS VendorName
					,DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,AVG(MyTruckBalance) AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,52 AS RowNumber
					,4 AS RowType
			FROM	#TempData
			WHERE	RowNumber BETWEEN 27 AND 52
					AND DriverType = 'MYT'
					AND @DriverId IS Null
			GROUP BY
					Company
					,DriverType
			) MYT_RECS
	-- START Divisions Calculations
	UNION
	SELECT	Company
			,Division
			,DivisionName
			,VendorId
			,VendorName
			,DriverType
			,HireDate
			,MyTruckStartDate
			,LastPayDate
			,Drayage
			,Miles
			,DriverFuelRebate
			,FuelAmount
			,Gallons
			,Drayage + DriverFuelRebate AS TotalPay
			,CASE WHEN Gallons = 0 THEN 0 ELSE FuelAmount/Gallons * 1.00 END AS GrossPPG
			,CASE WHEN Gallons = 0 THEN 0 ELSE (FuelAmount - DriverFuelRebate)/Gallons * 1.00 END AS NetPPG
			,Drayage + DriverFuelRebate - FuelAmount AS NetPayAfterFuel
			,CASE WHEN Drayage = 0 THEN 0 ELSE (Drayage + DriverFuelRebate - FuelAmount) / Drayage * 100.00 END AS NetPayAfterFuelPercentage
			,StandardEscrow
			,OOInsurance
			,PeopleNet
			,Garnishments
			,(Drayage + DriverFuelRebate - FuelAmount) - StandardEscrow - OOInsurance - PeopleNet - Garnishments AS NetPayAfterMDs
			,MaintAndRepairs
			,LeasePayment
			,EscrowRepayment
			,Savings
			,TagsandTaxes
			,ManualATP
			,TiresDeduction
			,OtherInsurance
			,OtherDeductions
			,CashAdvance
			,CheckAmount
			,MyTruckBalance
			,SafetyBonus
			,RowNumber
			,RowType
			,ContractualBalance
			,MandRBalance
	FROM	(
			SELECT	Company
					,Division
					,DivisionName
					,'ZZZZZ' AS VendorId
					,Division AS VendorName
					,'ALL' AS DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,SUM(MyTruckBalance) AS MyTruckBalance
					,SUM(SafetyBonus) AS SafetyBonus
					,RowNumber
					,1 AS RowType
					,SUM(GPCustom.dbo.FindDriverEscrowBalance(@Company, VendorId, 1, @RunDate, Null)) AS ContractualBalance
					,SUM(GPCustom.dbo.FindDriverEscrowBalance(@Company, VendorId, 8, @RunDate, '2793')) AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber = 1
					AND @DriverId IS Null
			GROUP BY 
					Company
					,RowNumber
					,Division
					,DivisionName
			UNION
			SELECT	Company
					,Division
					,DivisionName
					,'ZZZZZ' AS VendorId
					,Division AS VendorName
					,'ALL' AS DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,AVG(MyTruckBalance) AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,4 AS RowNumber
					,2 AS RowType
					,Null AS ContractualBalance
					,Null AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber < 5
					AND @DriverId IS Null
			GROUP BY
					Company
					,Division
					,DivisionName
			UNION
			SELECT	Company
					,Division
					,DivisionName
					,'ZZZZZ' AS VendorId
					,Division AS VendorName
					,'ALL' AS DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,AVG(MyTruckBalance) AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,26 AS RowNumber
					,3 AS RowType
					,Null AS ContractualBalance
					,Null AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber BETWEEN 1 AND 26
					AND @DriverId IS Null
			GROUP BY
					Company
					,Division
					,DivisionName
			UNION
			SELECT	Company
					,Division
					,DivisionName
					,'ZZZZZ' AS VendorId
					,Division AS VendorName
					,'ALL' AS DriverType
					,Null AS HireDate
					,Null AS MyTruckStartDate
					,Null AS LastPayDate
					,AVG(Drayage) AS Drayage
					,AVG(Miles) AS Miles
					,AVG(DriverFuelRebate) AS DriverFuelRebate
					,AVG(FuelAmount) AS FuelAmount
					,AVG(Gallons) AS Gallons
					,AVG(StandardEscrow) AS StandardEscrow
					,AVG(OOInsurance) AS OOInsurance
					,AVG(PeopleNet) AS PeopleNet
					,AVG(Garnishments) AS Garnishments
					,AVG(MaintAndRepairs) AS MaintAndRepairs
					,AVG(LeasePayment) AS LeasePayment
					,AVG(EscrowRepayment) AS EscrowRepayment
					,AVG(Savings) AS Savings
					,AVG(TagsandTaxes) AS TagsandTaxes
					,AVG(ManualATP) AS ManualATP
					,AVG(TiresDeduction) AS TiresDeduction
					,AVG(OtherInsurance) AS OtherInsurance
					,AVG(OtherDeductions + EscrowInterest) AS OtherDeductions
					,AVG(CashAdvance) AS CashAdvance
					,AVG(CheckAmount) AS CheckAmount
					,AVG(MyTruckBalance) AS MyTruckBalance
					,AVG(SafetyBonus) AS SafetyBonus
					,52 AS RowNumber
					,4 AS RowType
					,Null AS ContractualBalance
					,Null AS MandRBalance
			FROM	#TempData
			WHERE	RowNumber BETWEEN 27 AND 52
					AND @DriverId IS Null
			GROUP BY
					Company
					,Division
					,DivisionName
			) MYT_RECS
	ORDER BY
			Division
			,VendorId
			,RowType
END
ELSE
BEGIN
	SELECT	Company
			,Division
			,DivisionName
			,VendorId
			,VendorName
			,DriverType
			,HireDate
			,MyTruckStartDate
			,WeekEndDate + 5 AS WeekEndDate
			,Drayage
			,Miles
			,DriverFuelRebate
			,FuelAmount
			,Gallons
			,Drayage + DriverFuelRebate AS TotalPay
			,CASE WHEN Gallons = 0 THEN 0 ELSE FuelAmount/Gallons * 1.00 END AS GrossPPG
			,CASE WHEN Gallons = 0 THEN 0 ELSE (FuelAmount - DriverFuelRebate)/Gallons * 1.00 END AS NetPPG
			,Drayage + DriverFuelRebate - FuelAmount AS NetPayAfterFuel
			,CASE WHEN Drayage = 0 THEN 0 ELSE (Drayage + DriverFuelRebate - FuelAmount) / Drayage * 100.00 END AS NetPayAfterFuelPercentage
			,StandardEscrow
			,OOInsurance
			,PeopleNet
			,Garnishments
			,(Drayage + DriverFuelRebate - FuelAmount) - StandardEscrow - OOInsurance - PeopleNet - Garnishments AS NetPayAfterMDs
			,MaintAndRepairs
			,LeasePayment
			,EscrowRepayment
			,Savings
			,TagsandTaxes
			,ManualATP
			,TiresDeduction
			,OtherInsurance
			,OtherDeductions + EscrowInterest AS OtherDeductions
			,CashAdvance
			,CheckAmount
			,MyTruckBalance
			,ISNULL(SafetyBonus, 0) AS SafetyBonus
			,RowNumber
			,ContractualEscrowBalance = (SELECT SUM(Amount) FROM GPCustom.dbo.View_EscrowTransactions ES WHERE ES.CompanyId = @Company AND Fk_EscrowModuleId = 1 AND VendorId = TP.VendorId AND PostingDate <= DATEADD(dd, 5, TP.WeekEndDate) AND DeletedBy IS Null)
			,[M&R_Balance] = (SELECT SUM(Amount) FROM GPCustom.dbo.View_EscrowTransactions ES WHERE ES.CompanyId = @Company AND Fk_EscrowModuleId = 8 AND VendorId = TP.VendorId AND PostingDate <= DATEADD(dd, 5, TP.WeekEndDate) AND DeletedBy IS Null AND AccountAlias = 'M&R Escrow')
			,[Truck_Note] = (SELECT SUM(CurTrxAm) FROM GPCustom.dbo.View_MyTruckRecords WHERE VendorId = TP.VendorId AND Company = @Company AND DocDate <= DATEADD(dd, 5, TP.WeekEndDate))
	FROM	#TempData TP
END

SELECT	DISTINCT TDA.VendorId, 
		TDA.VendorName,
		CAST(TVM.TerminationDate AS Date) AS TerminationDate
FROM	#TempData TDA
		INNER JOIN #TempVendorMaster TVM ON TDA.VendorId = TVM.VendorId
ORDER BY TDA.VendorName

DROP TABLE #TempVendorMaster
DROP TABLE #tmpManualTransactions
DROP TABLE #TempDPY
DROP TABLE #TempData