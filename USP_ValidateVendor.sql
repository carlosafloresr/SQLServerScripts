ALTER PROCEDURE [dbo].[USP_ValidateVendor]
		@CompanyId		Varchar(5),
		@Integration	Varchar(30),
		@Field			Varchar(25),
		@BatchId		Varchar(30),
		@ReturnValue	Varchar(2000) OUTPUT
AS
DECLARE	@Query			Varchar(2000),
		@VendorId		Char(12)
		
SET		@Query			= 'DECLARE curVendors CURSOR FOR '
SET		@Query			= @Query + 'SELECT DISTINCT SourceTbl.' + RTRIM(@Field) + ' AS VendorId FROM dbo.' + RTRIM(@Integration) + ' SourceTbl '
SET		@Query			= @Query + 'LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.PM00200 GPVendors ON SourceTbl.' + RTRIM(@Field) + ' = GPVendors.VendorId '
SET		@Query			= @Query + 'WHERE SourceTbl.BatchId = ''' + RTRIM(@BatchId) + ''' AND GPVendors.VendorId IS Null'
SET		@ReturnValue	= ''

EXECUTE(@Query)

OPEN curVendors

FETCH NEXT FROM curVendors INTO @VendorId

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @ReturnValue = @ReturnValue + '<td>Customer: ' + RTRIM(@VendorId) + '</td>' + CHAR(13) + CHAR(10)

	FETCH NEXT FROM curVendors INTO @VendorId
END

IF @ReturnValue <> ''
BEGIN
	SET @ReturnValue = '<table border=''1'' cellpadding=''1'' cellspacing=''1'' style=''color:blue;font-family:Arial;font-size:10px;border-collapse:collapse;''><tr>' + CHAR(13) + CHAR(10) + @ReturnValue
	SET @ReturnValue = @ReturnValue + '</tr></table>'
END

CLOSE curVendors
DEALLOCATE curVendors
GO

/*

DECLARE @Result	Varchar(2000)
EXECUTE USP_ValidateVendor 'IMC', 'View_Integration_FSI_Vendors', 'RecordCode', '1FSI080401_1023', @Result OUTPUT
PRINT @Result

*/