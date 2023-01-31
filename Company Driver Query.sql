DECLARE	@WeekEndingDate	Datetime,
		@CompanyId		Char(5),
		@DriverType		Char(1),
		@CompanyCode	Char(1),
		@Query			Varchar(max),
		@Query2			Varchar(max)

SET	@WeekEndingDate = '6/10/2008'
SET	@CompanyId		= 'IMC'
SET	@DriverType		= 'C'
SET	@CompanyCode	= CASE WHEN @CompanyId = 'AIS' THEN '4' ELSE '1' END
SET	@Query			= 'SELECT ''' + RTRIM(@CompanyId) + ''' AS Company, Division_Code, Driver_Type, Driver_Code, DPTrxType_Code, Pay_Miles, Truck_AMount, FuelCredit_Amount, Driver_Total, WeekEndingDate '
SET	@Query			= @Query + 'FROM GPS.DPY WHERE Driver_Type = ''' + @DriverType + ''' AND Company_Number = ' + @CompanyCode
SET	@Query			= @Query + ' AND WeekEndingDate > ''' + CONVERT(Char(10), @WeekEndingDate, 101) + ''' ORDER BY Division_Code, Driver_Code, DPTrxType_Code'
SET	@Query			= 'SELECT *, GETDATE() AS RunTime, 0 AS Processed FROM OPENQUERY(PostgreSQL, ''' + REPLACE(@Query, '''', '''''') + ''')'

EXECUTE(@Query)
