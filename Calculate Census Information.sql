/*
-- SET	@IniDate	= '3/3/2011'
-- SET	@EndDate	= '3/31/2011'
EXECUTE USP_CalculateCensus '4/7/2011', '4/28/2011'
*/
CREATE PROCEDURE USP_CalculateCensus
		@IniDate	Datetime,
		@EndDate	Datetime
AS
SELECT	PAY.EmployId,
		EMP.FrstName AS FirstName,
		LEFT(EMP.MidlName, 1) AS MI,
		EMP.LastName AS LastName,
		PAY.WrkrComp,
		PAY.SutaStat,
		POS.Dscriptn AS Position,
		SUM(CASE WHEN PATINDEX('%Overtime%', COD.Dscriptn) = 0 THEN PAY.UprTrxAm ELSE 0.00 END) AS GrossEarning,
		SUM(CASE WHEN PATINDEX('%Overtime%', COD.Dscriptn) > 0 THEN PAY.UprTrxAm ELSE 0.00 END) AS OT_Halftime,
		SUM(PAY.UprTrxAm * CASE WHEN PATINDEX('%Overtime%', COD.Dscriptn) > 0 THEN -1 ELSE 1 END) AS NetEarnings,
		EMP.StrtDate AS HireDate,
		CASE WHEN EMP.Inactive = 1 THEN 'INACTIVE' ELSE 'ACTIVE' END AS Status,
		PAY.Deprtmnt
FROM	UPR30300 PAY
		INNER JOIN UPR00100 EMP ON PAY.EmployId = EMP.EmployId
		INNER JOIN UPR00102 ADR ON PAY.EmployId = ADR.EmployId AND EMP.AdrsCode = ADR.AdrsCode
		INNER JOIN UPR40600 COD ON PAY.PayrolCd = COD.PayRcord
		LEFT JOIN UPR40301 POS ON EMP.JobTitle = POS.JobTitle
WHERE	PAY.ChekDate BETWEEN @IniDate AND @EndDate
		AND PAY.PyrlrTyp = 1
GROUP BY
		PAY.EmployId,
		EMP.FrstName,
		EMP.MidlName,
		EMP.LastName,
		PAY.Deprtmnt,
		PAY.WrkrComp,
		PAY.SutaStat,
		POS.Dscriptn,
		EMP.StrtDate,
		EMP.Inactive
ORDER BY
		PAY.WrkrComp,
		PAY.Deprtmnt,
		EMP.LastName,
		EMP.FrstName,
		EMP.MidlName