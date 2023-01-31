/*
EXECUTE USP_SafetyBonusPayReport 'GIS', '10/01/2012', 'CFLORES'
*/
ALTER PROCEDURE USP_SafetyBonusPayReport
		@Company	Varchar(5),
		@RunDate	Date,
		@UserId		Varchar(25)
AS
DECLARE	@Query		Varchar(MAX),
		@CompNum	Varchar(2)

SELECT	@CompNum	= CAST(CompanyNumber AS Varchar)
FROM	Companies
WHERE	CompanyId	= @Company

IF DATENAME(weekday, @RunDate) <> 'Thursday'
	SET	@RunDate = dbo.TTOD(dbo.DayFwdBack(@RunDate,'N','Thursday'))

SELECT	VM.VendorId
		,UPPER(VM.Company) AS Company
		,ISNULL(VO.HireDate, VM.HireDate) AS HireDate
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

SELECT	DIV.Division
		,DIV.DivisionName
		,SBP.PayPeriods
		,SBP.ByDivision
		,SBP.Rate AS CompanyRate
		,SBP.TenureLevels AS CompanyTenureLevels
		,SBP.TenureIncrease AS CompanyTenureIncrease
		,SDV.ByMileagePercent
		,SDV.TenureLevels AS DivisionTenureLevels
		,SDV.TenureSelection
		,SDV.Rate AS DivisionRate
		,SDV.RateTenureIncrease
INTO	#tmpSBParemeters
FROM	View_Divisions DIV
		INNER JOIN SafetyBonusParametersByDivision SDV ON DIV.Division = SDV.Division AND DIV.Fk_CompanyId = SDV.Company
		INNER JOIN SafetyBonusParameters SBP ON SDV.Company = SBP.Company
WHERE	DIV.Fk_CompanyId = @Company
ORDER BY DIV.Division

SET @Query = 'SELECT PAY.Cmpy_No,
	DRV.Div_Code,
	PAY.Dr_Code,
	DRV.Name,
	DRV.HireDt,
	DRV.TermDt,
	PAY.WkPDate,
	SUM(PAY.PayMiles) AS PayMiles,
	SUM(PAY.PayAmt)::numeric(9,2) AS PayAmt
FROM	Trk.drpay PAY
	INNER JOIN Trk.Driver DRV ON PAY.Dr_Code = DRV.Code
WHERE	PAY.Cmpy_No = ' + @CompNum + '
	AND PAY.WkPDate > TIMESTAMP ''' + CONVERT(Char(10), @RunDate, 101) + ''' - INTERVAL ''365 days''
	AND PAY.DRType = ''O''
	AND PAY.PayAmt <> 0
	AND PAY.PayType NOT IN (''A'','''')
	AND DRV.TermDt IS Null
GROUP BY
	PAY.Cmpy_No,
	DRV.Div_Code,
	PAY.Dr_Code,
	DRV.Name,
	DRV.HireDt,
	DRV.TermDt,
	PAY.WkPDate'

EXECUTE USP_QuerySWS @Query, '##tmpDriverPay'

DELETE DriverPayReport WHERE UserId = @UserId

INSERT INTO DriverPayReport
SELECT	cmpy_no
		,Div_Code
		,dr_code
		,name
		,hiredt
		,TermDt
		,wkpdate
		,dbo.DayFwdBack(wkpdate, 'N', 'Thursday') AS PayDate
		,DATEDIFF(yy, hiredt, GETDATE()) AS Years
		,paymiles
		,payamt
		,@UserId
FROM	##tmpDriverPay
WHERE	paymiles + payamt <> 0

SELECT	DPR.cmpy_no
		,COM.CompanyId
		,COM.CompanyName
		,DPR.Div_Code
		,SBP.DivisionName
		,DPR.dr_code
		,dbo.PROPER(DPR.name) AS Name
		,DPR.hiredt
		,DPR.PayDate
		,dbo.FindCompanyBonusPeriod(@Company, DPR.hiredt, DPR.PayDate) AS Period
		,dbo.FindCompanyBonusPeriodDates(@Company, DPR.hiredt, DPR.PayDate) AS BonusPayDate
		,Years
		,CAST(CAST(CASE WHEN YEAR(DPR.hiredt) = YEAR(@RunDate) THEN YEAR(@RunDate) + 1 ELSE YEAR(@RunDate) END AS Char(4)) + '-' + CAST(MONTH(DPR.hiredt) AS Varchar(2)) + '-' + CAST(CASE WHEN YEAR(DPR.hiredt) = YEAR(@RunDate) AND MONTH(DPR.hiredt) = 2 AND DAY(DPR.hiredt) = 29 THEN DAY(DPR.hiredt) - 1 ELSE DAY(DPR.hiredt) END AS Varchar(2)) AS Date) AS Anniversary
		,DPR.wkpdate
		,DPR.paymiles
		,DPR.payamt
		,SBP.PayPeriods
		,SBP.ByDivision
		,SBP.ByMileagePercent
		,CASE WHEN SBP.ByMileagePercent = 'P' AND DPR.Years > 1 AND DPR.Years < SBP.DivisionTenureLevels THEN SBP.DivisionRate + (SBP.RateTenureIncrease * (SBP.DivisionTenureLevels - DPR.Years))
		      WHEN SBP.ByMileagePercent = 'P' AND DPR.Years >= SBP.DivisionTenureLevels THEN SBP.DivisionRate + (SBP.RateTenureIncrease * (SBP.DivisionTenureLevels - 1))
		 ELSE SBP.DivisionRate END AS BonusRate
		,ROUND(CASE WHEN SBP.ByMileagePercent = 'M' THEN DPR.paymiles ELSE DPR.payamt END *
		 CASE WHEN SBP.ByMileagePercent = 'P' AND DPR.Years > 1 AND DPR.Years < SBP.DivisionTenureLevels THEN SBP.DivisionRate + (SBP.RateTenureIncrease * (SBP.DivisionTenureLevels - DPR.Years))
		      WHEN SBP.ByMileagePercent = 'P' AND DPR.Years >= SBP.DivisionTenureLevels THEN SBP.DivisionRate + (SBP.RateTenureIncrease * (SBP.DivisionTenureLevels - 1))
		 ELSE SBP.DivisionRate END, 2) AS BonusAmount
FROM	DriverPayReport DPR
		INNER JOIN Companies COM ON DPR.cmpy_no = COM.CompanyNumber
		LEFT JOIN #tmpSBParemeters SBP ON DPR.Div_Code = SBP.Division
WHERE	DPR.UserId = @UserId
ORDER BY 
		DPR.cmpy_no
		,DPR.Div_Code
		,DPR.dr_code
		,11 DESC
		,DPR.PayDate DESC

DROP TABLE ##tmpDriverPay
DROP TABLE #tmpSBParemeters
DROP TABLE #TempVendorMaster