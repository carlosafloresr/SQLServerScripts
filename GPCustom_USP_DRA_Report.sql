
/*
EXECUTE USP_DRA_Report 'AIS', '052208DSDRVCK', 'A0111'
EXECUTE USP_DRA_Report 'IMC', '062508DSDRVCK', NULL
*/

ALTER PROCEDURE [dbo].[USP_DRA_Report] -- DRA = Driver Remittance Advice
		@Company	Char(6),
		@BatchId	Char(17),
		@DriverId	Varchar(10) = Null
AS
DECLARE	@Query		Varchar(500)
SET		@Query = 'EXECUTE ' + RTRIM(@Company) + '.dbo.USP_DRA_Report ''' + RTRIM(@Company) + ''',''' + RTRIM(@BatchId) + ''',' + CASE WHEN @DriverId IS NULL THEN 'Null' ELSE '''' + RTRIM(@DriverId) + '''' END
PRINT @Query
EXECUTE(@Query)

-- SELECT * FROM GPCustom.dbo.OOS_DeductionTypes WHERE Company = 'AIS'
-- EXECUTE GPCustom.dbo.USP_DRA_Report 'AIS', '2008-05-24', 'A0164'
-- EXECUTE imc.dbo.USP_DRA_Report 'IMC','062608DSDRVDD',Null
-- SELECT * FROM PM10201 WHERE	VendorId = 'A0164'
-- SELECT * FROM PM10300 WHERE BachNumb = '062608DSDRVDD'
-- 062508DSDRVCK