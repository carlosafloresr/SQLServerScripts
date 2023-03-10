/*
EXECUTE USP_QueryFIDepot 'SELECT * FROM Invoices WHERE Inv_No = 833140'
EXECUTE USP_QueryFIDepot 'SELECT Inv_No, Rep_Date FROM Invoices WHERE Rep_Date = {05/01/2012}'
*/
ALTER PROCEDURE [dbo].[USP_QueryFIDepot] (@Request Varchar(MAX), @CursorName Varchar(30) = Null)
AS
DECLARE	@Query	Varchar(MAX),
		@Query2	Varchar(MAX)

IF @CursorName IS Null
BEGIN
	SET	@Query = N'SELECT * FROM OPENQUERY(ILSSQL01, N''EXECUTE Intranet.dbo.USP_FIDepot_Query ''''' + REPLACE(@Request, '''', '''''') + ''''''')'
	--PRINT @Query
	EXECUTE(@Query)
END
ELSE
BEGIN
	SET	@Query2 = N'SELECT * INTO ' + @CursorName + ' FROM OPENQUERY(ILSSQL01, N''EXECUTE Intranet.dbo.USP_FIDepot_Query ''''' + REPLACE(@Request, '''', '''''') + ''''''')'
	--PRINT @Query2
	EXECUTE(@Query2)
END