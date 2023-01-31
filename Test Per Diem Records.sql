SELECT	*
FROM	View_CustomerTiers
WHERE	PrincipalID = 'CMA'
		AND CustNmbr = '2945'
		AND MoveTypeCode = 'I'
		AND ((EquipmentSize = '40' AND EquipmentShortDesc = 'H')
		OR (EquipmentSize = '20' AND EquipmentShortDesc = 'S'))
ORDER BY EquipmentSize, EquipmentShortDesc

SELECT	* 
FROM	PerDiemTestRecords 
WHERE	MoveDays > 0 
		AND EquipmentId <> ''
		AND PrincipalCode = 'CMA'
		AND EquipmentId in ('CLHU866892','ECMU162994')

EXECUTE SPU_CalculateRate 1, '04/11/2012', '04/13/2012', 'CMA', '40H', Null, 'COTI21', 0, '2945', 'I'
EXECUTE SPU_CalculateRate 1, '01/04/2012', '01/06/2012', 'CMA', '20S', Null, 'AUZO23', 0, '2945', 'I'