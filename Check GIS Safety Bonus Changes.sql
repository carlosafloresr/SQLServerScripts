SELECT	SB.VendorId,
		SB.HireDate,
		SB.Period,
		SB.BonusPayDate,
		MAX(SB.Percentage) AS Percentage,
		SUM(SB.Drayage) AS Drayage,
		SUM(SB.DrayageBonus) AS DrayageBonus
INTO	#tmpCurrent
FROM	SafetyBonus SB
		INNER JOIN (
					SELECT	VendorId,
							MIN(Period) AS Period
					FROM	SafetyBonus
					WHERE	Company = 'GIS'
							AND Paid = 0
							AND SortColumn = 0
					GROUP BY VendorId
					) DT ON SB.VendorId = DT.VendorId AND SB.Period = DT.Period
WHERE	SB.Company = 'GIS'
		AND SB.Paid = 0
		AND SB.SortColumn = 1
		AND SB.PayDate < '02/10/2014'
GROUP BY
		SB.VendorId,
		SB.HireDate,
		SB.Period,
		SB.BonusPayDate
ORDER BY 
		SB.VendorId

SELECT	SB.VendorId,
		SB.HireDate,
		SB.Period,
		SB.BonusPayDate,
		MAX(SB.Percentage) AS Percentage,
		SUM(SB.Drayage) AS Drayage,
		SUM(SB.DrayageBonus) AS DrayageBonus
INTO	#tmpPrevious
FROM	GPCustom_20140212.dbo.SafetyBonus SB
		INNER JOIN (
					SELECT	VendorId,
							MIN(Period) AS Period
					FROM	GPCustom_20140212.dbo.SafetyBonus
					WHERE	Company = 'GIS'
							AND Paid = 0
							AND SortColumn = 0
					GROUP BY VendorId
					) DT ON SB.VendorId = DT.VendorId AND SB.Period = DT.Period
WHERE	SB.Company = 'GIS'
		AND SB.Paid = 0
		AND SB.SortColumn = 1
		AND SB.PayDate < '02/10/2014'
GROUP BY
		SB.VendorId,
		SB.HireDate,
		SB.Period,
		SB.BonusPayDate
ORDER BY 
		SB.VendorId

SELECT	RTRIM(CU.VendorId) AS VendorId,
		CU.HireDate,
		CU.Period,
		CU.BonusPayDate,
		CU.Drayage,
		CU.Percentage AS New_Percent,
		CU.DrayageBonus AS New_BonusAmount,
		PV.Percentage AS Old_Percent,
		PV.DrayageBonus AS Old_BonusAmount,
		PV.DrayageBonus - CU.DrayageBonus AS Difference
FROM	#tmpCurrent CU
		INNER JOIN #tmpPrevious PV ON CU.VendorId = PV.VendorId AND CU.Period = PV.Period
WHERE	CU.DrayageBonus <> PV.DrayageBonus

DROP TABLE #tmpCurrent
DROP TABLE #tmpPrevious