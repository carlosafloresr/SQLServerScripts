ALTER PROCEDURE USP_MissingDeductions (@Date Datetime)
AS
SELECT	DISTINCT UPR00100.EmployId,
	RTRIM(LastName) + ', ' + RTRIM(FrstName) + ' ' + MidlName AS EmployeeName,
	SocScNum,
	BE010130.DSCRIPTN,
	UPR00500.DEDCAMNT_1 AS DeducAmount,
	UPR00500.DedNprct_1 AS DeducPercetage,
	UPR00500.DEDUCTON,
	Income.PayRate,
	SUM(ISNULL(UPR30300.UPRTRXAM, 0)) AS UPRTRXAM,
	CASE WHEN UPR00500.DEDCAMNT_1 = 0 THEN (UPR00500.DedNprct_1 / 100) * Income.PayRate ELSE UPR00500.DEDCAMNT_1 END AS ToDeduct,
	CASE WHEN UPR00500.DEDCAMNT_1 = 0 THEN (UPR00500.DedNprct_1 / 100) * Income.PayRate ELSE UPR00500.DEDCAMNT_1 END - SUM(ISNULL(UPR30300.UPRTRXAM, 0)) AS PayDifference
FROM	UPR00100
	inner JOIN UPR00500 ON UPR00100.EmployId = UPR00500.EmployId AND UPR00500.INACTIVE = 0
	INNER JOIN BE010130 ON UPR00500.EmployId = BE010130.EmpId_I AND UPR00500.deducton = BE010130.benefit
	LEFT JOIN UPR30300 ON UPR00100.EMPLOYID = UPR30300.EMPLOYID AND UPR00500.deducton = UPR30300.PAYROLCD AND UPR30300.CHEKDATE = @Date AND PyrlrTyp = 2
	INNER JOIN (SELECT EMPLOYID, CHEKDATE, SUM(PayRate) AS PayRate FROM UPR30300 WHERE PyrlrTyp = 1 GROUP BY EMPLOYID, CHEKDATE) Income ON UPR00100.EMPLOYID = Income.EMPLOYID AND Income.CHEKDATE = @Date
GROUP BY
	UPR00100.EmployId,
	LastName,
	FrstName,
	MidlName,
	SocScNum,
	BE010130.DSCRIPTN,
	UPR00500.DEDCAMNT_1,
	UPR00500.DedNprct_1,
	UPR00500.DEDUCTON,
	Income.PayRate,
	CASE WHEN UPR00500.DEDCAMNT_1 = 0 THEN (UPR00500.DedNprct_1 / 100) * Income.PayRate ELSE UPR00500.DEDCAMNT_1 END
HAVING CASE WHEN UPR00500.DEDCAMNT_1 = 0 THEN (UPR00500.DedNprct_1 / 100) * Income.PayRate ELSE UPR00500.DEDCAMNT_1 END - SUM(ISNULL(UPR30300.UPRTRXAM, 0)) > 1
ORDER BY LastName, FrstName, UPR00500.DEDUCTON