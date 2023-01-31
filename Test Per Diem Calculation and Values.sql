-- SELECT * FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = 'IMC' AND CustNmbr = '119D' AND LPCode = 'SOCO56'

-- EXECUTE SPU_CalculateRate 1, '11/16/2011', '11/17/2011', 'CHINA', '40S', Null, 'STGR10', 0, '10423', 'I'

EXECUTE SPU_CalculateRate 1, '12/22/2011', '12/27/2011', 'COSCO', '40H', Null, 'STGR10', 0, '10423', 'I'
EXECUTE SPU_CalculateRate 1, '12/29/2011', '01/06/2012', 'COSCO', '40H', Null, 'STGR10', 0, '10423', 'E'

-- SELECT * FROM View_CustomerTiers WHERE CustomerNo = 'PD562' AND EquipmentSize = '40' AND EquipmentShortDesc = 'S' AND CustNmbr = '4173'

--SELECT * FROM View_PrincipalTiers WHERE PrincipalID = 'COSCO' AND EquipmentSize = '40' AND EquipmentShortDesc = 'H'

--SELECT * FROM RateTiers WHERE RATEID = 139