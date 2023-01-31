ALTER PROCEDURE USP_Expense_Reporting
	@Date1		Datetime,
	@Date2		Datetime,
	@Acct1		Varchar(500) = Null,
	@Acct2		Varchar(500) = Null,
	@Acct3		Varchar(500) = Null
AS
DECLARE	@Query		Varchar(4000)
SET	@Query = 'SELECT * FROM View_Expense_Reporting WHERE EffDate BETWEEN ''' + CONVERT(Char(10), @Date1, 101) + '''' + ' AND '
SET	@Query = @Query + '''' + CONVERT(Char(10), @Date2, 101) + ' 11:59:59 PM'''


IF @Acct1 IS NOT NULL
BEGIN
	SET @Query = @Query + 'AND (' + @Acct1 + ')'
END

IF @Acct2 IS NOT NULL
BEGIN
	SET @Query = @Query + 'AND (' + @Acct2 + ')'
END

IF @Acct3 IS NOT NULL
BEGIN
	SET @Query = @Query + 'AND (' + @Acct3 + ')'
END

SET	@Query = @Query + ' ORDER BY Category, Vendor, DocNumber, EffDate'

PRINT @Query
EXECUTE (@Query)

--EXECUTE USP_Expense_Reporting '01/01/2007', '10/01/2007', 'Acct1 >= 5 AND Acct1 <= 6', 'Acct2 = ''08''', 'Acct3 BETWEEN 6000 AND 6900'