/*
EXECUTE USP_ExpenseRecovery_GridRecords 'GIS','PAIGEG'
EXECUTE USP_ExpenseRecovery_GridRecords 'GIS','CFLORES'
*/
ALTER PROCEDURE USP_ExpenseRecovery_GridRecords
		@parCompany		Varchar(5),
		@parUserId		Varchar(25),
		@parStatus		Char(1) = 'O',
		@parProduct		Smallint = 0,
		@parDays		Smallint = 60,
		@parSort		Varchar(100) = Null
AS
SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX),
		@UsrRestricted	Bit

DECLARE @tblDivisions	Table (
		Company			Varchar(5),
		CompanyName		Varchar(100),
		DivisionId		Int,
		Division		Char(2),
		DivisionName	Varchar(100),
		Inactive		Bit,
		Location		Char(2),
		Assigned		Bit,
		WithRestricts	Bit)

INSERT INTO @tblDivisions
EXECUTE Intranet.dbo.USP_FindDivisions @parCompany, @parUserId

SET @UsrRestricted = CASE WHEN (SELECT COUNT(*) FROM @tblDivisions) <> (SELECT COUNT(*) FROM @tblDivisions WHERE (Assigned = 1 AND WithRestricts = 1) OR WithRestricts = 0) THEN 1 ELSE 0 END

SET @Query = N'SELECT * FROM View_ExpenseRecovery 
WHERE EffDate IS NOT Null AND Company = ''' + @parCompany + '''
AND EffDate >= DATEADD(dd, -' + CAST(@parDays AS Varchar) + ', ''' + CONVERT(Char(10), GETDATE(), 101) + ''') 
AND Status = ''' + CASE @parStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' ELSE 'Pending' END + ''' '

IF @parProduct > 0
	SET @Query = @Query + 'AND ProductLine = ' + CAST(@parProduct AS Varchar) + ' '

IF @UsrRestricted = 1
	SET @Query = @Query + 'AND Division IN (SELECT Division FROM UserDivisions WHERE CompanyId = ''' + @parCompany + ''' AND FK_UserId = ''' + @parUserId + ''') '

IF @parSort IS Null
	SET @Query = @Query + 'ORDER BY Division, EffDate DESC, PATINDEX(''%'' + LEFT(RepairType, 1) + ''%'', ''TFMO'')'
ELSE
	SET @Query = @Query + 'ORDER BY Division, ' + @parSort

PRINT @Query
EXECUTE(@Query)