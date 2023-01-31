SELECT	*
FROM	View_PrincipalTiers
WHERE	PrincipalID = 'CMA'
		AND (MoveTypeCode = 'I' OR MoveTypeCode = 'ALL')
		AND (((EquipmentSize = '40' OR EquipmentSize = 'ALL') AND EquipmentShortDesc = 'H')
		OR ((EquipmentSize = '40'  OR EquipmentSize = 'ALL') AND EquipmentShortDesc = 'S'))
ORDER BY EquipmentSize, EquipmentShortDesc
--print DATEADD(dd, 5 - 1, '04/11/2012')
SELECT	* 
FROM	PerDiemTestRecords 
WHERE	MoveDays > 0 
		AND EquipmentId <> ''
		AND PrincipalCode = 'CMA'
		AND EquipmentId in ('CLHU866892')

EXECUTE SPU_CalculateRate 1, '04/11/2012', '04/13/2012', 'CMA', '40H', Null, 'COTI21', 0, '2945', 'I'
--EXECUTE SPU_CalculateRate 1, '01/04/2012', '01/06/2012', 'CMA', '20S', Null, 'AUZO23', 0, '2945', 'I'
--EXECUTE SPU_CalculateRate 1, '01/04/2012', '01/05/2012', 'CMA', '40H', Null, 'FRES11', 0, '2945', 'I'