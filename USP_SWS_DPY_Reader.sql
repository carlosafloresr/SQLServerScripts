-- SELECT * FROM ILSGP01.GPCustom.dbo.Companies

ALTER PROCEDURE [dbo].[USP_SWS_DPY_Reader]
AS
DECLARE	@WeekEndingDate	Datetime,
		@CompanyCode	Char(1),
		@RunTime		Char(19),
		@Query			Varchar(Max)

SET	@RunTime		= CAST(GETDATE() AS Char(19))
SET	@Query			= 'SELECT (CASE WHEN Company_Number = 4 THEN ''AIS'' ELSE ''IMC'' END)::char(3) AS Company, Division_Code, Driver_Type, Driver_Code, Driver_Name, DPTrxType_Code, Pay_Miles, Truck_AMount, FuelCredit_Amount, Driver_Total, WeekEndingDate, Driver_HireDate, Driver_TermDate '
SET	@Query			= @Query + 'FROM GPS.DPY WHERE GPS_TimeStamp IS Null'
SET	@Query			= 'INSERT INTO ILSGP01.GPCustom.dbo.SWS_DPY (company, division_code, driver_type, driver_code, driver_name, dptrxtype_code, pay_miles, truck_amount, fuelcredit_amount, driver_total, weekendingdate, HireDate, TerminationDate, RunTime, Processed) SELECT SWS.*, ''' + @RunTime + ''' AS RunTime, -1 AS Processed FROM OPENQUERY(PostgreSQLProd, ''' + REPLACE(@Query, '''', '''''') + ''') SWS '
SET	@Query			= @Query + 'LEFT JOIN ILSGP01.GPCustom.dbo.SWS_DPY ON SWS.Company = SWS_DPY.Company AND SWS.WeekEndingDate = SWS_DPY.WeekEndingDate AND SWS.Driver_Type = SWS_DPY.Driver_Type AND SWS.Driver_Code = SWS_DPY.Driver_Code WHERE SWS_DPY.Company IS Null'

EXECUTE(@Query)

UPDATE ILSGP01.GPCustom.dbo.SWS_DPY SET Processed = 0 WHERE Processed = -1
GO

-- EXECUTE USP_SWS_DPY_Reader
