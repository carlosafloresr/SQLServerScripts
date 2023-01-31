/*
EXECUTE USP_SOP_PerDiemPosted '12/15/2022'
*/
CREATE PROCEDURE USP_SOP_PerDiemPosted
		@RunDate	Date
AS
SET NOCOUNT ON

DECLARE @Company	Varchar(5),
		@Counter	Int,
		@Query		Varchar(MAX)

DECLARE	@tblDate	Table (Counter	Int)
DECLARE	@tblBatches	Table (Company	Varchar(5), Counter Int)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT LTRIM(RTRIM(CompanyId))
FROM	GPCustom.dbo.Companies 
WHERE	IsTest = 0
		AND Trucking = 1
		AND CompanyId NOT IN ('GSA')

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblDate

	SET @Query = N'SELECT ''' + @Company + ''',COUNT(*) FROM ' + @Company + '.dbo.SOP30100 WHERE LEFT(BACHNUMB, 2) = ''PD'' AND CONVERT(Char(10), GLPOSTDT, 101) = ''' + CONVERT(Char(10), @RunDate, 101) + ''''

	INSERT INTO @tblBatches
	EXECUTE(@Query)

	--SET @Counter = (SELECT Counter FROM @tblDate)

	--INSERT INTO @tblBatches (Company, Counter) VALUES (@Company, @Counter)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies 

SELECT	*
FROM	@tblBatches