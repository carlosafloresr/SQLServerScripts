/*
Company Number:: 4
OutGate Date:: 134975156
Equipment Code:: INKU670400
Equipment Owner Code:: MED
Equipment Size Type:: 40H
BillTo Code:: 16375
Alt BillTo Code::
Move Type:: I
Div Code:: 27
LP Code:: KTWA81
EXEC SPU_CalculateRate @CompanyNumber=7, @StartDate='Dec  6 2016 12:00AM', @StopDate=Null, @PrincipalID='MAERSK', @Equipment='40S', @Location='CARLSTAR GROUP', @LPCode='CAGR27', @IsJ1=0, @CustomerNo='8789', @MoveType='I', @Division=Null, @CountryRegion=Null, @AltShip=Null
*/
EXECUTE SPU_CalculateRate_02162017
@CompanyNumber=1,
@StartDate='02/13/2017',
@StopDate=null,
@PrincipalID='MED',
@Equipment='40H',
@Location=Null,
@LPCode='GERS14',
@CustomerNo='13974',
@MoveType='I',
@IsJ1=0, 
@Division=NULL,
@CountryRegion=NULL,
@AltShip='13974C'

EXECUTE SPU_CalculateRate_02162017 
@CompanyNumber=7,
@StartDate='2/8/2017',
@StopDate=null,
@PrincipalID='COSCO',
@Equipment='40H',
@Location='All',
@LPCode='MIMG16',
@CustomerNo='16167',
@MoveType='I',
@IsJ1=0,
@Division=null,
@CountryRegion=null,
@AltShip=null



/*
EXECUTE SPU_CalculateRate @CompanyNumber=7, @StartDate='Feb 10 2014 12:00AM', @StopDate=Null, @PrincipalID='COSCO', @Equipment='40H', @Location='THE CLOROX COMPANY', @LPCode='THCL24', @IsJ1=0, @CustomerNo='1524', @MoveType='I', @Division=Null, @CountryRegion=Null, @AltShip='14427'

SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = 'DNJ' AND CustNmbr = '4863M' AND LPCode = 'BECK90'

SELECT	BillType,
		DoesBillPerDiem,
		FreightBillTo,
		BillToAllLocations
FROM	ILSGP01.GPCustom.dbo.CustomerMaster 
WHERE	CompanyId	= 'DNJ'
		AND CustNmbr = '163'

UPDATE	ILSGP01.GPCustom.dbo.CustomerMaster 
SET		DoesBillPerDiem = 1,
		BillType = 3,
		BillToAllLocations = 1
WHERE	CustNmbr		= '163'
		AND CompanyId	= 'GIS'

SELECT	DISTINCT Company, Weekends, Holidays, Rate, RateID, FreeDays, BusinessDays, EquipmentShortDesc, EquipmentSize, MoveTypeCode, EffectiveDate, ExpirationDate, LPCodes, Principalid
FROM	dbo.View_CustomerTiers 
WHERE	Company = 7
		AND CustomerNo = 'PD20377'
		AND Principalid = 'HAPAG'
		AND (MoveTypeCode = 'I' OR MoveTypeCode = 'All')
		--AND EffectiveDate BETWEEN '3/28/2014' AND '3/31/2014'
				
SELECT	*
FROM	View_CustomerTiers
WHERE	PrincipalID = 'CMA'
		AND EquipmentSize = '20'
		AND EquipmentShortDesc= 'S'
		AND (CustNmbr = 'E1042'
		OR CustomerNo = 'PDE1042')
*/