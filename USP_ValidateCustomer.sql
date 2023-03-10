ALTER PROCEDURE [dbo].[USP_ValidateCustomer]
		@CompanyId		Varchar(5),
		@Integration	Varchar(30),
		@Field			Varchar(25),
		@BatchId		Varchar(30),
		@ReturnValue	Varchar(2000) OUTPUT
AS
DECLARE	@Query			Varchar(2000),
		@CustNmbr		Char(12)
		
SET		@Query			= 'DECLARE curCustomer CURSOR FOR '
SET		@Query			= @Query + 'SELECT DISTINCT SourceTbl.' + RTRIM(@Field) + ' AS CustNmbr FROM dbo.' + RTRIM(@Integration) + ' SourceTbl '
SET		@Query			= @Query + 'LEFT JOIN ' + RTRIM(@CompanyId) + '.dbo.RM00101 GPCustomers ON SourceTbl.' + RTRIM(@Field) + ' = GPCustomers.CustNmbr '
SET		@Query			= @Query + 'WHERE SourceTbl.BatchId = ''' + RTRIM(@BatchId) + ''' AND GPCustomers.CustNmbr IS Null'
SET		@ReturnValue	= ''

EXECUTE(@Query)

OPEN curCustomer

FETCH NEXT FROM curCustomer INTO @CustNmbr

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @ReturnValue = @ReturnValue + '<td>Customer: ' + RTRIM(@CustNmbr) + '</td>' + CHAR(13) + CHAR(10)

	FETCH NEXT FROM curCustomer INTO @CustNmbr
END

IF @ReturnValue <> ''
BEGIN
	SET @ReturnValue = '<table border=''1'' cellpadding=''1'' cellspacing=''1'' style=''color:blue;font-family:Arial;font-size:10px;border-collapse:collapse;''><tr>' + CHAR(13) + CHAR(10) + @ReturnValue
	SET @ReturnValue = @ReturnValue + '</tr></table>'
END

CLOSE curCustomer
DEALLOCATE curCustomer
GO

/*

DECLARE @Result	Varchar(2000)
EXECUTE USP_ValidateCustomer 'IMC', 'FSI_ReceivedDetails', 'CustomerNumber', '1FSI080401_1023', @Result OUTPUT
PRINT @Result

*/