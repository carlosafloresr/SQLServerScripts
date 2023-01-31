ALTER PROCEDURE USP_TIP_Report (@Filter Varchar(1000) = Null)
AS
DECLARE	@Query	Varchar(Max)

SET	@Query = 'SELECT * FROM View_TIP_Transactions'

IF @Filter IS NOT Null
BEGIN
	SET	@Query = @Query + ' WHERE ' + @Filter
END

EXECUTE(@Query)