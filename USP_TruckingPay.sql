/*
EXECUTE USP_TruckingPay 'cflores', 7, '04/14/2012', '05/05/2012', '''35'',''36''', 'C', 'L'
EXECUTE USP_TruckingPay 'CFLORES', 7,'4/11/2012','5/11/2012',Null,Null,Null 
EXECUTE USP_TruckingPay 'CFLORES', 7, '04/14/2012', '04/15/2012', '''35''','C','L'
*/
ALTER PROCEDURE USP_TruckingPay
		@UserId			Varchar(25),
		@CompanyNo		Int,
		@DateIni		Date,
		@DateEnd		Date,
		@Divisions		Varchar(2000) = Null,
		@DriverType		Char(1) = Null,
		@PayType		Varchar(5) = Null
AS
DECLARE	@Query Varchar(Max)

SET @Query = N'SELECT PAY.Div_Code AS Division, PAY.WkpDate AS WeekendingDate, PAY.PayType, PAY.Dr_Code AS DriverCode, PAY.DrType AS DriverType, PAY.PayMiles, PAY.FcrAmt AS FuelCreditAmount, PAY.AcrudAmt AS MovePay, 
INV.Code AS Invoice, INV.Eq_Code AS Equipment, INV.BT_Code AS Customer, PAY.Description
FROM TRK.DRPAY PAY 
	 LEFT JOIN TRK.INVOICE INV ON PAY.Cmpy_No = INV.Cmpy_No AND PAY.Inv_Code = INV.Code
WHERE PAY.PayType <> '''' AND PAY.WkpDate BETWEEN ''' + CONVERT(Char(10), @DateIni, 101) + ''' AND ''' + CONVERT(Char(10), @DateEnd, 101) + ''' AND PAY.Cmpy_No = ' + CAST(@CompanyNo AS Varchar(2))

IF @Divisions IS NOT Null
	SET @Query = @Query + ' AND PAY.Div_Code IN (' + @Divisions + ')'

IF @DriverType IS NOT Null
	SET @Query = @Query + ' AND PAY.DrType = ''' + @DriverType + ''''

IF @PayType IS NOT Null
	SET @Query = @Query + ' AND PAY.PayType = ''' + RTRIM(@PayType) + ''''

SET @Query = @Query + ' ORDER BY 1, 2, 3, 4'

PRINT @Query

EXECUTE USP_QuerySWS @Query, '##tmpRecords'

DELETE TruckingPay WHERE UserId = @UserId

INSERT INTO TruckingPay
SELECT	*
		,@UserId as UserId 
FROM	##tmpRecords

DROP TABLE ##tmpRecords

/*
SELECT	* 
FROM	View_TruckingPay 
WHERE	UserId = 'cflores'
		AND PayMiles + FuelCreditAmount + MovePay <> 0
*/