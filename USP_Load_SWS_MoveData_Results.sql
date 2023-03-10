/*
execute USP_Load_SWS_MoveData_Results 'cflores'
*/
ALTER PROCEDURE [dbo].[USP_Load_SWS_MoveData_Results] (@UserId Varchar(25), @ProNumber Varchar(12) = Null OUTPUT)
AS
DECLARE	@Counter	Int

SELECT @Counter = COUNT(ProNumber) FROM (SELECT DISTINCT(ProNumber) AS ProNumber FROM SWS_MoveData_Results WHERE UserId = @UserId) RECS
PRINT @Counter
IF @Counter = 1
	SELECT @ProNumber = MAX(ProNumber) FROM SWS_MoveData_Results WHERE UserId = @UserId
ELSE
	SET @ProNumber = ''

SELECT	CompanyId
		,EquipmentNumber AS [Equipment Number]
		,CONVERT(Char(10), OrderDate, 101) AS [Order Date]
		,CONVERT(Char(10), DestinationDate, 101) AS [Destination Date]
		,ProNumber
		,Chassis
		,CustomerNumber + ' - ' + CustomerName AS Customer
		,Contact
		,AccChg
		,ChType
		,Status
		,DriverId
		,DriverName
		,DriverType
		,PayMiles
		,PayAmount
		,acrudamt
		,ship_code
		,Ship_Name
		,ship_address
		,ship_city
		,ship_state
		,ship_zipcode
		,CAST(CONVERT(Char(10), ship_date, 101) + ' ' + ship_time AS Datetime) AS [Ship Date]
		,Cons_name
		,Cons_Address
		,Cons_City
		,Cons_State
		,Cons_ZipCode
		,OrderNumber
		,ItemNumber
		,FSCAmount
		,FSCPercentage
		,ReferenceNumber
		,CompanyNumber
FROM	GPCustom.dbo.SWS_MoveData_Results
WHERE	UserId = @UserId
ORDER BY 
		ProNumber
		,OrderDate
		,ItemNumber
		
PRINT @ProNumber