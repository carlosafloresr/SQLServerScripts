/*
EXECUTE USP_GPPayablesBatches_Drivers 'DNJ', '~DSDR072921CK~,~DSDR072921DD~'
*/
ALTER PROCEDURE USP_GPPayablesBatches_Drivers
		@Company		Varchar(5),
		@Batches		Varchar(100)
AS
DECLARE	@Query			Varchar(MAX)

SET @Query = 'SELECT	VM.VendorId, VM.DriverName AS VendName, VM.Division, VM.Agent, VM.PaidByPayCard
FROM	dbo.PM10300 PM
		INNER JOIN dbo.VendorMaster VM ON PM.Company = VM.Company AND PM.VendorId = VM.VendorId
WHERE	PM.Company = ''' + @Company + '''
		AND PM.BACHNUMB IN (' + REPLACE(@Batches, '~', '''') + ')
ORDER BY VM.DriverName'

EXECUTE(@Query)