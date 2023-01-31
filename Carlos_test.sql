DECLARE @CompanyId		Char(5),
		@DriverType		Char(1)
DECLARE	@WeekEndingDate	Datetime,
		@CompanyCode	Char(1),
		@RunTime		Char(19),
		@Query			Varchar(Max)

SET	@RunTime		= CAST(GETDATE() AS Char(19))
SET	@Query			= 'SELECT (CASE WHEN Company_Number = 4 THEN ''AIS'' ELSE ''IMC'' END)::char(3) AS Company, Division_Code, Driver_Type, Driver_Code, Driver_Name, DPTrxType_Code, Pay_Miles, Truck_AMount, FuelCredit_Amount, Driver_Total, WeekEndingDate, Driver_HireDate, Driver_TermDate '
SET	@Query			= @Query + 'FROM GPS.DPY '
SET	@Query			= 'INSERT INTO SWS_DPY SELECT SWS.*, ''' + @RunTime + ''' AS RunTime, 0 AS Processed FROM OPENQUERY(PostgreSQL, ''' + REPLACE(@Query, '''', '''''') + ''') SWS '
SET	@Query			= @Query + 'LEFT JOIN SWS_DPY ON SWS.Company = SWS_DPY.Company AND SWS.WeekEndingDate = SWS_DPY.WeekEndingDate WHERE SWS_DPY.Company IS Null'
PRINT @Query

EXECUTE(@Query)
IF @@ROWCOUNT > 0
BEGIN
	SET	@WeekEndingDate	= (SELECT TOP 1 WeekEndingDate FROM SWS_DPY WHERE RunTime = CAST(@RunTime AS Datetime))
	IF @WeekEndingDate IS NOT Null
	BEGIN
		DECLARE @RunTime Char(19)
		SET	@RunTime = CAST(GETDATE() AS Char(19))
		UPDATE OPENQUERY(PostgreSQLPROD, 'SELECT * FROM GPS.DPY WHERE Company_Number = 4') SET GPS_TimeStamp = @RunTime;
	END
END

-- EXECUTE USP_SWS_DPY_Reader 'IMC', 'C'
-- SELECT * FROM OPENQUERY(PostgreSQL, 'SELECT * FROM trk.dptrxtype ORDER BY Description')
-- SELECT * FROM OPENQUERY(PostgreSQLPROD, 'SELECT * FROM GPS.DPY WHERE Driver_Code = ''9584''')
-- SELECT * FROM OPENQUERY(PostgreSQL, 'SELECT (CASE WHEN Company_Number = 4 THEN ''AIS'' ELSE ''IMC'' END)::char(3) AS Test FROM GPS.DPY')
-- SELECT * FROM OPENQUERY(PostgreSQL, 'SELECT MAX(WeekEndingDate) FROM GPS.DPY')
-- TRUNCATE TABLE SWS_DPY

/*
INSERT INTO SWS_DPY 
SELECT	SWS.*, GETDATE() AS RunTime, 0 AS Processed 
FROM	OPENQUERY(PostgreSQL, 'SELECT (CASE WHEN Company_Number = 4 THEN ''AIS'' ELSE ''IMC'' END)::char(3) AS Company, Division_Code, Driver_Type, Driver_Code, Driver_Name, DPTrxType_Code, Pay_Miles, Truck_AMount, FuelCredit_Amount, Driver_Total, WeekEndingDate FROM GPS.DPY ') SWS
		LEFT JOIN SWS_DPY ON SWS.Company = SWS_DPY.Company AND SWS.WeekEndingDate = SWS_DPY.WeekEndingDate WHERE SWS_DPY.Company IS Null

SELECT * FROM PostgreSQL.

Declare @MyString varchar(max),
            @NOWTIME DateTime
SET @NOWTIME = GETDATE()
SET   @MyString =
            'SELECT * FROM GPS.DPY WHERE Company_Number = 4'
SET   @MyString = N'update OPENQUERY(PostgreSQL, ''' + REPLACE(@MyString, '''', '''''') + ''') SET GPS_TimeStamp = GETDATE()'
EXECUTE(@MyString)
*/

