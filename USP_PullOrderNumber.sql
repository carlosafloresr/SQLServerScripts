/*
EXECUTE USP_PullOrderNumber 4, '45-160770'
*/
ALTER PROCEDURE USP_PullOrderNumber 
		@CompanyNum	Int,
		@ProNumber	Varchar(15)
AS
BEGIN
	DECLARE @Query		nvarchar(MAX),
			@Result		int

	SELECT @Query = N'SELECT @Result = or_no FROM OPENQUERY(PostgreSQLPROD_RO,''SELECT or_no FROM TRK.Invoice WHERE Cmpy_No = ' + CAST(@CompanyNum AS Varchar) + ' AND Code = ''''' + @ProNumber + ''''''')'

	EXECUTE sp_executesql @Query, N'@ProNumber varchar(20), @Result int OUTPUT', @ProNumber, @Result OUTPUT

	SELECT ISNULL(@Result,0) AS WorkOrderNumber
END