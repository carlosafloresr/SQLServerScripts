/*
EXECUTE USP_ApplyTo_PayablesIntegration 'ATEST', 'A1483', 'PEOPLENET UNIT2', 'DPYA1483_00221692', 83.94, '03/30/2018'
*/
ALTER PROCEDURE USP_ApplyTo_PayablesIntegration
		@Company		Varchar(5),
		@VendorId		Varchar(20),
		@ApplyFrom		Varchar(30),
		@ApplyTo		Varchar(30),
		@Amount			Numeric(10,2),
		@PostingDate	Date
AS
DECLARE	@Query			Varchar(1000)

SET @Query = N'EXECUTE ' + RTRIM(@Company) + '.dbo.USP_ApplyTo_Payables ''' + RTRIM(@VendorId) + ''',''' + RTRIM(@ApplyFrom) + ''','''
SET @Query = @Query + RTRIM(@ApplyTo) + ''',' + CAST(@Amount AS Varchar) + ',''' + CAST(@PostingDate AS Varchar) + ''''

PRINT @Query
EXECUTE(@Query)
GO