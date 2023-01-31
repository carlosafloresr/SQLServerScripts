/*
USP_TempVendorMaster 'AIS', 'AIS_12254555', 'CFLORES'
TRUNCATE TABLE TempVendorMaster
*/
ALTER PROCEDURE USP_TempVendorMaster
	@CompanyId	Varchar(5),
	@BatchId	Varchar(25),
	@UserId		Varchar(25)
AS

DELETE TempVendorMaster WHERE BatchId = @BatchId AND UserId = @UserId

DECLARE	@Query	Varchar(Max)
SET		@Query	= '
INSERT INTO TempVendorMaster
		(VendorId
		,Company
		,HireDate
		,TerminationDate
		,SubType
		,ApplyRate
		,Rate
		,ApplyAmount
		,Amount
		,ScheduledReleaseDate
		,BatchId
		,UserId)
SELECT	VendorId
		,Company
		,HireDate
		,TerminationDate
		,SubType
		,ApplyRate
		,Rate
		,ApplyAmount
		,Amount
		,ScheduledReleaseDate
		,''' + @BatchId + ''', ''' + @UserId + '''
FROM	VendorMaster 
WHERE	Company = ''' + @CompanyId + ''' AND VendorId IN (SELECT VendorId FROM ' + @CompanyId + '.dbo.PM00200 WHERE VndClsId = ''DRV'')'

EXECUTE(@Query)