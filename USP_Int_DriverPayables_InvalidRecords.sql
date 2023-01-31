EXECUTE USP_Int_DriverPayables_InvalidRecords 'AISTE'
ALTER PROCEDURE USP_Int_DriverPayables_InvalidRecords
	@CompanyId	Char(6), 
	@BatchId	Varchar(20) = Null
AS
DECLARE	@Query		Varchar(5000)

IF @BatchId IS Null
BEGIN
	SET @Query = 'SELECT * FROM Integration_APHeader WHERE Company = ''' + RTRIM(@CompanyId) + ''' AND BatchId IN (SELECT BatchId FROM Integration_APDetails 
		WHERE Status = 1 AND VendorId IN (SELECT VendorId FROM ' + RTRIM(@CompanyId) + '.dbo.PM00300))'
END
ELSE
BEGIN
	SET @Query = 'SELECT * FROM Integration_APHeader WHERE Company = ''' + RTRIM(@CompanyId) + ''' AND BatchId = ''' + RTRIM(@BatchId) + ''' AND BatchId IN (SELECT BatchId FROM Integration_APDetails 
		WHERE BatchId = ''' + RTRIM(@BatchId) + ''' AND Status = 1 AND VendorId IN (SELECT VendorId FROM ' + RTRIM(@CompanyId) + '.dbo.PM00300))'
END
EXECUTE(@Query)
GO