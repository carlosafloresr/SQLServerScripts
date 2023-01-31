/*
EXECUTE USP_OpenInvoices 'DNJ', 1, 300, '10948'
*/
ALTER PROCEDURE USP_OpenInvoices
		@Company		Varchar(5),
		@OnlySummary	Bit = 1,
		@DueDays		Int = Null, 
		@Customer		Varchar(20) = Null,
		@InvoiceNum		Varchar(30) = Null
AS
DECLARE	@Query			Varchar(MAX)

IF @DueDays IS Null
	SET @DueDays = 90
	
SET	@Query = 'EXECUTE ' + @Company + '.dbo.USP_OpenInvoices ' + CAST(@OnlySummary AS Char(1)) + ',' + CAST(@DueDays AS Varchar(5))

IF @Customer IS NOT Null
	SET @Query = @Query + ',''' + @Customer + ''''
ELSE
	SET @Query = @Query + ',Null'
	
IF @InvoiceNum IS NOT Null
	SET @Query = @Query + ',''' + @InvoiceNum + ''''
	
PRINT @Query
EXECUTE(@Query)