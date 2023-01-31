/*
EXECUTE USP_Calculate401K '4/7/2011', '4/28/2011'
*/
ALTER PROCEDURE USP_Calculate401K
		@IniDate	Datetime,
		@EndDate	Datetime,
		@IniDedCode	Varchar(10) = Null,
		@EndDedCode	Varchar(10) = Null,
		@IniBenCode	Varchar(10) = Null,
		@EndBenCode Varchar(10) = Null,
		@LoanCode	Varchar(10) = Null
AS
DECLARE	@LoanLength	Int,
		@StartDate	Datetime
		
SET	@StartDate = CAST('1/1/' + CAST(YEAR(@IniDate) AS Char(4)) AS Datetime)

IF @IniDedCode IS Null
	SET @IniDedCode = '401'

IF @EndDedCode IS Null
	SET @EndDedCode = '401%'

IF @IniBenCode IS Null
	SET @IniBenCode = '401'

IF @EndBenCode IS Null
	SET @EndBenCode = '401%'
	
IF @LoanCode IS Null
	SET @LoanCode = '401L'
	
SET	@LoanLength = LEN(RTRIM(@LoanCode))

SELECT	8719 AS PlanNumber,
		Null AS SubCompanyNumber,
		Null AS GroupCode,
		EMP.SocScNum AS SSN,
		CASE WHEN EMP.Gender = 1 THEN 'Mr'
			WHEN EMP.Gender = 2 AND EMP.MaritalStatus = 1 THEN 'Mrs'
			ELSE 'Ms' END AS Title,
		EMP.FrstName AS FirstName,
		LEFT(EMP.MidlName, 1) AS MI,
		EMP.LastName AS LastName,
		Null AS Sufix,
		Null AS PayrollEndDate,
		SUM(CASE WHEN PAY.PyrlrTyp = 2 AND PAY.PayrolCd BETWEEN @IniDedCode AND @EndDedCode AND PAY.ChekDate BETWEEN @IniDate AND @EndDate THEN PAY.UprTrxAm ELSE 0 END) AS EE_PreTax,
		Null AS EE_PreTax_CatchUp,
		Null AS EE_Roth,
		Null AS EE_Roth_CatchUp,
		SUM(CASE WHEN PAY.PyrlrTyp = 3 AND PAY.PayrolCd BETWEEN @IniBenCode AND @EndBenCode AND PAY.ChekDate BETWEEN @IniDate AND @EndDate THEN PAY.UprTrxAm ELSE 0 END) AS ER_Match,
		Null AS ER_Non_Match,
		Null AS ER_Safe_Harbor,
		Null AS Qnec,
		Null AS EE_After_Tax_Contribution,
		SUM(CASE WHEN PAY.PyrlrTyp = 2 AND LEFT(PAY.PayrolCd, @LoanLength) = @LoanCode AND PAY.ChekDate BETWEEN @IniDate AND @EndDate THEN PAY.UprTrxAm ELSE 0 END) AS Loan_Repayments,
		0.00 AS Loan_Payoff_Amount,
		SUM(CASE WHEN PAY.PyrlrTyp = 1  AND PAY.ChekDate BETWEEN @IniDate AND @EndDate THEN PAY.UprTrxAm ELSE 0 END) AS Compensation_Pay_Period,
		Compensation_YTD = (SELECT SUM(CASE WHEN PYS.PyrlrTyp = 1 THEN PYS.UprTrxAm ELSE 0 END) FROM UPR30300 PYS WHERE PYS.EmployId = PAY.EmployId AND PYS.Year1 = PAY.Year1 AND PYS.ChekDate <= @EndDate),
		0.00 AS Excluded_Compensation_YTD,
		Hours_Worked_YTD = (SELECT SUM(CASE WHEN PYS.PyrlrTyp = 1 THEN CASE WHEN PYS.Untstopy <> 0 THEN PYS.Untstopy ELSE (DATEDIFF(d, PYS.TrxBegDt, PYS.TrxEndDt) - 1) * 8 END ELSE 0 END) FROM UPR30300 PYS WHERE PYS.EmployId = PAY.EmployId AND PYS.Year1 = PAY.Year1 AND PYS.ChekDate <= @EndDate),
		ADR.Address1,
		ADR.Address2,
		ADR.City,
		ADR.State,
		ADR.ZipCode,
		Null AS City_Province,
		Null AS Postal_Code,
		Null AS Country,
		EMP.BrthDate AS DOB,
		EMP.StrtDate AS HireDate,
		CASE WHEN EMP.Dempinac = '1/1/1900' THEN Null ELSE EMP.Dempinac END AS TerminationDate,
		Null AS RehireDate,
		EMP.Deprtmnt AS Department
FROM	UPR30300 PAY
		INNER JOIN UPR00100 EMP ON PAY.EmployId = EMP.EmployId
		INNER JOIN UPR00102 ADR ON PAY.EmployId = ADR.EmployId AND EMP.AdrsCode = ADR.AdrsCode
WHERE	PAY.ChekDate BETWEEN @StartDate AND @EndDate
		--AND PAY.UprTrxAm <> 0
		--AND (EMP.Dempinac = '1/1/1900' OR (YEAR(EMP.Dempinac) = PAY.Year1))
GROUP BY 
		PAY.EmployId,
		EMP.LastName,
		EMP.FrstName,
		EMP.MidlName,
		PAY.Year1,
		EMP.SocScNum,
		EMP.Deprtmnt,
		EMP.EmploymentType,
		ADR.Address1,
		ADR.Address2,
		ADR.City,
		ADR.State,
		ADR.ZipCode,
		EMP.MaritalStatus,
		EMP.BrthDate,
		EMP.StrtDate,
		EMP.Dempinac,
		EMP.Gender,
		EMP.Primary_Pay_Record
ORDER BY
		EMP.LastName,
		EMP.FrstName,
		EMP.MidlName
		
/*
SELECT Benefit, Dscriptn FROM UPR40800 WHERE Benefit LIKE '%401%' AND Inactive = 0 ORDER BY Benefit

SELECT Deducton, Dscriptn FROM UPR40900 WHERE Deducton LIKE '%401%' AND Inactive = 0 AND PATINDEX('%Loan%', Dscriptn) = 0 ORDER BY Deducton

SELECT Deducton, Dscriptn FROM UPR40900 WHERE Deducton LIKE '%401%' AND Inactive = 0 AND PATINDEX('%Loan%', Dscriptn) > 0 ORDER BY Deducton
SELECT * FROM UPR40600

SELECT	EmployId,
		Benefit,
		BnfPrcnt_1
FROM	UPR00600
WHERE	EmployId = 538
		-- 		Benefit LIKE '%401%'
		AND BnfPrcnt_1 <> 0
		
SELECT	EmployId,
		Deducton,
		DednPrct_1
FROM	UPR00500
WHERE	Deducton = '401%'
		AND DednPrct_1 <> 0
		
SELECT	*
FROM	UPR30300
WHERE	ChekDate BETWEEN '1/1/2011' AND '3/31/2011'
		--AND PATINDEX('%401%', PayrolCd) > 0
		AND EmployId = 'D0090'
		AND PyrlrTyp = 1
		
SELECT	*
FROM	UPR00100
--WHERE	--Dempinac = '1/1/1900'
		--AND EmployId = '653'
ORDER BY LastName


		CASE WHEN EMP.MaritalStatus = 1 THEN 'M' ELSE 'S' END AS MaritalStatus,
		DATEDIFF(dd, EMP.StrtDate, @EndDate) / 365.00 AS YearsService,
		Null AS PEDate,
		CASE WHEN EMP.EmploymentType = 3 THEN 'YES' ELSE 'NO' END AS PT_EE,
		
		
		
		MBK_Cont = (SELECT SUM(CASE WHEN PYS.PyrlrTyp = 2 AND PYS.PayrolCd = '401%' THEN PYS.UprTrxAm ELSE 0 END) FROM UPR30300 PYS WHERE PYS.EmployId = PAY.EmployId AND PYS.Year1 = PAY.Year1 AND PYS.ChekDate <= @EndDate),
		Null AS MKE_Cont,
		Null AS MKE_Cont_YTD,
		
		Null AS EBA_Count,
		Null AS ESK_Cont,
		Null AS RTH_Cont,
		Null AS RTC_Cont,
		Null AS ESA_Cont,
		Null AS MBA_Cont,
		
		0.00 AS Loan_Payoff,
		,
		Null AS Plan_Comps_YTD,
		
		0.00 AS Exclud_Comps,

AND PYS.PayrolCd = EMP.Primary_Pay_Record
*/