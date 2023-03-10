CREATE PROCEDURE USP_PreCheck_MissingDeductions (@Date Datetime)
AS
DECLARE @ReportDate	DateTime
SET	@ReportDate = CONVERT(Char(10), @Date, 101)

SELECT	DISTINCT 'ILS  ' AS Company,
	UPR00100.EmployId,
	RTRIM(LastName) + ', ' + RTRIM(FrstName) + ' ' + MidlName AS EmployeeName,
	SocScNum,
	UPR00100.deprtmnt,
	BE010130.DSCRIPTN,
	UPR00500.DEDCAMNT_1 AS DeducAmount,
	UPR00500.DedNprct_1 AS DeducPercetage,
	UPR00500.DedBegDt,
	UPR00500.DEDUCTON,
	Income.PayRate,
	SUM(ISNULL(UPR10208.UPRTRXAM, 0)) AS UPRTRXAM,
	CASE WHEN UPR00500.DEDCAMNT_1 = 0 THEN (UPR00500.DedNprct_1 / 100) * Income.PayRate ELSE UPR00500.DEDCAMNT_1 END AS ToDeduct,
	CASE WHEN UPR00500.DEDCAMNT_1 = 0 THEN (UPR00500.DedNprct_1 / 100) * Income.PayRate ELSE UPR00500.DEDCAMNT_1 END - SUM(ISNULL(UPR10208.UPRTRXAM, 0)) AS PayDifference
FROM	UPR00100
	INNER JOIN UPR00500 ON UPR00100.EmployId = UPR00500.EmployId AND UPR00500.INACTIVE = 0 AND ((dedbegdt < @ReportDate AND DedLtMax = 0) OR (dedbegdt < @ReportDate AND DedLtMax < LtdDedTn))
	INNER JOIN BE010130 ON UPR00500.EmployId = BE010130.EmpId_I AND UPR00500.deducton = BE010130.benefit
	LEFT JOIN UPR10208 ON UPR00100.EMPLOYID = UPR10208.EMPLOYID AND UPR00500.deducton = UPR10208.PAYROLCD AND UPR10208.CHEKDATE = @ReportDate AND PyrlrTyp = 2
	INNER JOIN (SELECT EMPLOYID, CHEKDATE, SUM(PayRate) AS PayRate FROM UPR10208 WHERE PyrlrTyp = 1 GROUP BY EMPLOYID, CHEKDATE) Income ON UPR00100.EMPLOYID = Income.EMPLOYID AND Income.CHEKDATE = @ReportDate
GROUP BY
	UPR00100.EmployId,
	RTRIM(LastName) + ', ' + RTRIM(FrstName) + ' ' + MidlName,
	SocScNum,
	UPR00100.deprtmnt,
	BE010130.DSCRIPTN,
	UPR00500.DEDCAMNT_1,
	UPR00500.DedNprct_1,
	UPR00500.DedBegDt,
	UPR00500.DEDUCTON,
	Income.PayRate,
	CASE WHEN UPR00500.DEDCAMNT_1 = 0 THEN (UPR00500.DedNprct_1 / 100) * Income.PayRate ELSE UPR00500.DEDCAMNT_1 END
HAVING CASE WHEN UPR00500.DEDCAMNT_1 = 0 THEN (UPR00500.DedNprct_1 / 100) * Income.PayRate ELSE UPR00500.DEDCAMNT_1 END - SUM(ISNULL(UPR10208.UPRTRXAM, 0)) > 1
ORDER BY Company, UPR00100.deprtmnt, RTRIM(LastName) + ', ' + RTRIM(FrstName) + ' ' + MidlName, UPR00500.DEDUCTON

GO

SELECT EMPLOYID, CHEKDATE, SUM(GRWGPRN) AS PayRate FROM UPR10208 GROUP BY EMPLOYID, CHEKDATE

SELECT * FROM UPR10204