DECLARE	@Query		Varchar(MAX),
		@DateIni	Date = '12/22/2013',
		@DateEnd	Date = '12/28/2013'

SET	@Query = N'SELECT ORD.Div_Code AS Division,
	ORD.Pro,
	ORD.FscPercent,
	ORD.Status AS OrderStatus,
	MOV.Olp_Code,
	MOV.ODate,
	MOV.OTime,
	MOV.Dlp_Code,
	MOV.DDate,
	MOV.DTime,
	MOV.Dr_Code AS Driver,
	DRV.Name AS DriverName,
	MOV.DrType AS DriverType,
	MOV.Status AS MoveStatus,
	MOV.Tl_Code AS Equipment,
	MOV.PayMiles AS Miles,
	MOV.FcrAmt AS FuelCred,
	MOV.PayAmt AS MovePay,
	MOV.PayAmt + MOV.FcrAmt AS Total,
	MOV.AcrudAmt AS TruckPay,
	Null AS AccCode,
	Null AS Description,
	Null AS AccDriver,
	(SELECT COUNT(INV.Code) FROM TRK.Invoice INV WHERE INV.Or_No = ORD.No) AS Invoiced,
	1 AS RecordType
FROM	TRK.Order ORD
	INNER JOIN TRK.Move MOV ON ORD.Cmpy_No = MOV.Cmpy_No AND ORD.No = MOV.or_no
	INNER JOIN TRK.Driver DRV ON MOV.Cmpy_No = DRV.Cmpy_No AND MOV.Dr_Code = DRV.Code
WHERE ORD.Cmpy_No = ''4''
	AND ORD.PDate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + '''
	AND MOV.Ok2Pay <> ''Y''
UNION
SELECT ORD.Div_Code AS Division,
	ORD.Pro,
	ORD.FscPercent,
	ORD.Status AS OrderStatus,
	Null AS Olp_Code,
	Null AS ODate,
	Null AS OTime,
	Null AS Dlp_Code,
	Null AS DDate,
	Null AS DTime,
	CHG.Dr_Code AS Driver,
	DRV.Name AS DriverName,
	DRV.Type AS DriverType,
	Null AS MoveStatus,
	Null AS Equipment,
	0 AS Miles,
	0.00 AS FuelCred,
	CHG.DrAmount AS MovePay,
	CHG.DrAmount AS Total,
	CHG.TrkAmount AS TruckPay,
	CHG.T300_Code AS AccCode,
	CHG.Description,
	CHG.Dr_Code AS AccDriver,
	(SELECT COUNT(INV.Code) FROM TRK.Invoice INV WHERE INV.Or_No = ORD.No) AS Invoiced,
	2 AS RecordType
FROM	TRK.Order ORD
	LEFT JOIN TRK.OrChrg CHG ON ORD.Cmpy_No = CHG.Cmpy_No AND ORD.No = CHG.Or_No
	LEFT JOIN TRK.Driver DRV ON ORD.Cmpy_No = DRV.Cmpy_No AND CHG.Dr_Code = DRV.Code
WHERE ORD.Cmpy_No = ''4''
	AND ORD.PDate BETWEEN ''' + CAST(@DateIni AS Varchar) + ''' AND ''' + CAST(@DateEnd AS Varchar) + '''
	AND CHG.Ok2Pay <> ''Y'''

EXECUTE USP_QuerySWS @Query