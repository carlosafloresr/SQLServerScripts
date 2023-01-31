EXECUTE SPU_CalculateRateTEST @CompanyNumber=1, @StartDate='12/04/2013', @StopDate=null, @PrincipalID='HJCU', @Equipment='40S', @Location='All', @LPCode='EAGL75', @CustomerNo='4800', @MoveType='I',  @IsJ1=0, @Division=null, @CountryRegion='E', @AltShip='5618'
-- Alt Ship of 12544 and 5618.
--SELECT PDBillTo FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = 'IMC' AND CustNmbr = '4800' AND LPCode = 'EAGL75' AND PDBillTo LIKE '%' + '5618' + '%'
--SELECT COUNT(PDBillTo) FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = 'IMC' AND CustNmbr = '4800' AND LPCode = 'EAGL75'
SELECT REPLACE(PDBillTo, 'PD', '') FROM ILSGP01.GPCustom.dbo.PrincipalPerDiem WHERE CompanyId = 'IMC' AND CustNmbr = '4800' AND LPCode = 'EAGL75' AND PDBillTo LIKE '%5618%'