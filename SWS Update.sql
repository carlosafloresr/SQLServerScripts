/*
INSERT INTO ILSGP01.GPCustom.dbo.SWS_DPY (company, division_code, driver_type, driver_code, driver_name, dptrxtype_code, pay_miles, truck_amount, fuelcredit_amount, driver_total, weekendingdate, HireDate, TerminationDate, RunTime, Processed) 

SELECT SWS.*, 'Jul 28 2009 10:15AM' AS RunTime, -1 AS Processed FROM OPENQUERY(PostgreSQLProd, 'SELECT (CASE WHEN Company_Number = 4 THEN ''AIS'' ELSE CASE WHEN Company_Number = 1 THEN ''IMC'' ELSE ''NDS'' END END)::char(3) AS Company, Division_Code, Driver_Type, Driver_Code, Driver_Name, DPTrxType_Code, Pay_Miles, Truck_AMount, FuelCredit_Amount, Driver_Total, WeekEndingDate, Driver_HireDate, Driver_TermDate FROM GPS.DPY WHERE GPS_TimeStamp IS Null') SWS LEFT JOIN ILSGP01.GPCustom.dbo.SWS_DPY a ON SWS.Company = a.Company AND SWS.WeekEndingDate = a.WeekEndingDate AND SWS.Driver_Type = a.Driver_Type AND SWS.Driver_Code = a.Driver_Code WHERE a.Company IS Null


IF EXISTS(SELECT * FROM OPENQUERY(PostgreSQLProd, 'SELECT MAX(CASE WHEN Company_Number = 4 THEN ''AIS'' ELSE CASE WHEN Company_Number = 1 THEN ''IMC'' ELSE ''NDS'' END END)::char(3) AS Company) FROM GPS.DPY WHERE GPS_TimeStamp IS Null'))
	PRINT 'YES'
ELSE
	PRINT 'NO'
*/
DECLARE @WeekEndDate	Varchar(25),
		@Query			Varchar(Max)

SET		@Query			= 'SELECT RECS.* FROM OPENROWSET(''MSDASQL'', ''Driver=PostgreSQL ANSI;uid=ilsprod;Server=swsdb.imcg.com;port=5432;database=dta;pwd=gr8sushi4U'', ''SELECT * FROM GPS.DPY WHERE GPS_TimeStamp IS Null'') RECS WHERE WeekEndingDate >= ''7/01/2009'''

EXECUTE(@Query)

SELECT RECS.* FROM OPENROWSET('MSDASQL', 'Driver=PostgreSQL ANSI;uid=ilsprod;Server=swsdb.imcg.com;port=5432;database=dta;pwd=gr8sushi4U', 'SELECT * FROM GPS.DPY WHERE GPS_TimeStamp IS Null') RECS


DELETE OPENROWSET('MSDASQL', 'Driver=PostgreSQL ANSI;uid=ilsprod;Server=swsdb.imcg.com;port=5432;database=dta;pwd=gr8sushi4U', 'SELECT * FROM GPS.DPY WHERE GPS_TimeStamp IS Null AND WeekEndingDate < ''7/14/2009''')

UPDATE OPENROWSET('MSDASQL', 'Driver=PostgreSQL ANSI;uid=ilsprod;Server=swsdb.imcg.com;port=5432;database=dta;pwd=gr8sushi4U', 'SELECT * FROM GPS.DPY WHERE GPS_TimeStamp IS Null AND WeekEndingDate > ''6/01/2009'' AND WeekEndingDate < ''7/14/2009''') SET GPS_TimeStamp = '7/28/2009'
UPDATE OPENQUERY(PostgreSQLProd, 'SELECT * FROM GPS.DPY WHERE GPS_TimeStamp IS Null AND WeekEndingDate > ''6/01/2009'' AND WeekEndingDate < ''7/14/2009''') SET GPS_TimeStamp = '7/28/2009'