/*
EXECUTE USP_GP_XCB_Prepaid_ImporterTask
*/
ALTER PROCEDURE USP_GP_XCB_Prepaid_ImporterTask
AS
SET NOCOUNT ON

DECLARE	@DateIni	Date,
		@DateEnd	Date,
		@Company	Varchar(5),
		@Account	Varchar(15),
		@Query		Varchar(2000)

DECLARE @tblDates	Table (DateIni Date, DateEnd Date)

DECLARE curRecordsData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company, GLAccount
FROM	GPCustom.dbo.GP_XCB_Prepaid_Accounts

OPEN curRecordsData 
FETCH FROM curRecordsData INTO @Company, @Account

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblDates

	SET @Query = N'SELECT MIN(DATESTART), MAX(DATEEND) FROM ' + @Company + '.dbo.View_FiscalPeriods WHERE CLOSED = 0'

	INSERT INTO @tblDates
	EXECUTE(@Query)

	SELECT @DateIni = DateIni, @DateEnd = DateEnd FROM @tblDates

	EXECUTE GPCustom.dbo.USP_GL_XCB_DetailTrailBalance_Importer @Company, @Account, @DateIni, @DateEnd -- Imports Data
	EXECUTE GPCustom.dbo.USP_GL_XCB_DetailTrailBalance_Matching @Company, @Account, 0 -- Match records and update the SWS information

	FETCH FROM curRecordsData INTO @Company, @Account
END

CLOSE curRecordsData
DEALLOCATE curRecordsData
