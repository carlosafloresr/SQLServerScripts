SELECT	Weekends,
		Holidays,
		RateID,
		FreeDays
FROM	dbo.View_CustomerTiers 
WHERE	ExpirationDate >= '04/25/2012'
		AND CustomerNo = 'PD6040'
		AND (MoveTypeCode = 'I' OR MoveTypeCode = 'All')
		AND EquipmentShortDesc = 'S'
		AND EquipmentSize = '40'

SELECT	Rate,
		TierStartDay,
		TierEndDay
FROM	dbo.View_CustomerTiers
WHERE	CustomerNo = 'PD6040'
		AND TierStartDay <= 5
		AND (MoveTypeCode = 'I' OR MoveTypeCode = 'All')
		AND EquipmentShortDesc = 'S'
		AND EquipmentSize = '40'
ORDER BY TierStartDay