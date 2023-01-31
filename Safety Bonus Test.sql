SELECT	*
FROM	SafetyBonus
WHERE	Company = 'GIS'
		AND VendorId = 'G51340'
		AND Period IN ('2021-2','2021-1')
ORDER BY BonusPayDate DESC, PayDate DESC, SortColumn

DECLARE @Company	Varchar(5) = 'GIS',
		@VendorId	Varchar(15) = 'G51415'

DECLARE @tblPeriods Table (Period Varchar(10))

INSERT INTO @tblPeriods
SELECT	TOP 2 *
FROM	(
		SELECT	DISTINCT Period
		FROM	SafetyBonus
		WHERE	Company = @Company
				AND VendorId = @VendorId
				AND SortColumn = 1
		GROUP BY Period
		) DATA
ORDER BY 1 DESC

									SELECT	SAF.VendorId, SAF.Period, SAF.PayDate, SAF.SafetyBonusId
									FROM	SafetyBonus SAF
											INNER JOIN (
														SELECT	Company, VendorId, Period, PayDate, MIN(SafetyBonusId) AS SafetyBonusId, COUNT(PayDate) AS Counter
														FROM	SafetyBonus
														WHERE	Company = @Company
																AND VendorId = @VendorId
																--AND Paid = 0
																AND SortColumn = 1
																AND Period IN (SELECT Period FROM @tblPeriods)
														GROUP BY Company, VendorId, Period, PayDate
														HAVING COUNT(period) > 1
														) COU ON SAF.Company = COU.Company AND SAF.VendorId = COU.VendorId AND SAF.Period = COU.Period AND SAF.PayDate = COU.PayDate AND SAF.SafetyBonusId > COU.SafetyBonusId
									--GROUP BY SAF.VendorId, SAF.Period, SAF.PayDate