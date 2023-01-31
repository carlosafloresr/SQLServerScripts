SELECT	SF1.Company,
		SF1.VendorId,
		SF1.VendorName,
		CAST(SF1.BonusPayDate AS Date) AS BonusPayDate,
		SF2.DrayageBonus AS Before_BonusAmount,
		SF1.DrayageBonus AS After_BonusAmount,
		SF1.DrayageBonus - SF2.DrayageBonus AS Difference
FROM	SafetyBonus SF1
		INNER JOIN SafetyBonus_07212022 SF2 ON SF1.Company = SF2.Company AND SF1.VendorId = SF2.VendorId AND SF1.PayDate = SF2.PayDate AND SF1.SortColumn = SF2.SortColumn
WHERE	SF1.Company = 'GIS'
		AND SF1.PayDate > '05/20/2022'
		AND SF1.SortColumn = 0
ORDER BY SF1.VendorId, SF1.BonusPayDate

-- SELECT TOP 100 * FROM SafetyBonus