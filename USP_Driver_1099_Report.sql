USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_Driver_1099_Report]    Script Date: 1/17/2023 2:52:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_Driver_1099_Report 'NDS','N22743',2017
EXECUTE USP_Driver_1099_Report 'AIS','1004',2021,0,'MISC'
EXECUTE USP_Driver_1099_Report 'GLSO','7824','2022',0,'NEC'
*/
ALTER PROCEDURE [dbo].[USP_Driver_1099_Report] -- DRA = Driver Remittance Advice
		@Company		Varchar(5),
		@DriverId		Varchar(15) = Null,
		@Year			Int = Null,
		@JustPeriods	Bit = Null,
		@Type1099		Varchar(5) = Null,
		@VendorClass	Varchar(10) = Null,
		@HideSSN		Bit = 0
AS
DECLARE	@Query			Varchar(Max),
		@StrVendor		Varchar(20)

IF @JustPeriods IS Null
	SET @JustPeriods = 0

IF @Type1099 IS Null
	SET @Type1099 = 'MISC'

IF @VendorClass IS Null
	SET @VendorClass = 'ALL'

IF @DriverId IS Null
	SET @StrVendor = 'Null'
ELSE
	SET @StrVendor = '''' + RTRIM(@DriverId) + ''''

IF @JustPeriods = 0
	SET	@Query = RTRIM(@Company) + '.dbo.USP_Driver_1099 ''' + RTRIM(@Company) + ''', ' + @StrVendor + ',' + CAST(@Year AS Varchar) + ',0,''' + @Type1099 + ''',''' + @VendorClass + ''''
ELSE
	SET	@Query = RTRIM(@Company) + '.dbo.USP_Driver_1099 ''' + RTRIM(@Company) + ''', ''' + RTRIM(@DriverId) + ''',Null ,1,''' + @Type1099 + ''',''' + @VendorClass + ''''

PRINT @Query
EXECUTE(@Query)