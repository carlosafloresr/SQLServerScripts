
DECLARE	@Query Varchar(Max)

SET @Query = N'SELECT 	Div_Code AS Division
	,WkpDate AS WeekendingDate
	,PayType
	,Dr_Code AS DriverCode
	,DrType AS DriverType
	,PayMiles
	,FcrAmt AS FuelCreditAmount
	,AcrudAmt AS MovePay
FROM 	TRK.DRPAY 
WHERE 	WkpDate BETWEEN ''04/14/2012'' AND ''05/05/2012''
	AND Cmpy_No = 7
	AND Div_Code IN (''34'',''35'',''36'')
ORDER BY 1, 2, 3, 4'


EXECUTE USP_QuerySWS @Query, '##test'

select distinct paytype from ##test

drop table ##test