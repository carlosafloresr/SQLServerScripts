/*
EXECUTE USP_OOS_MergedFiles
*/
ALTER PROCEDURE USP_OOS_MergedFiles
AS
DECLARE	@Rundate		Date = GETDATE()

DECLARE	@WeekEndingDate	Date,
		@PayDate		Date,
		@CompanyNum		Smallint,
		@Company		Varchar(5),
		@BatchId		Varchar(25),
		@Query			Varchar(1000)

DECLARE	@tblOOSBatches	Table (
		Company			Varchar(5),
		CompanyNumber	Smallint,
		BatchId			Varchar(25), 
		Generated		Smallint, 
		MergedFiles		Bit)

SET @PayDate = CASE WHEN DATEPART(DW, @Rundate) = 5 THEN @Rundate
					WHEN DATEPART(DW, @Rundate) < 5 THEN GPCustom.dbo.DayFwdBack(@Rundate, 'N', 'Thursday')
					ELSE GPCustom.dbo.DayFwdBack(@Rundate, 'P', 'Thursday') END

SET @WeekEndingDate = GPCustom.dbo.DayFwdBack(@PayDate, 'P', 'Saturday')

INSERT INTO @tblOOSBatches
SELECT	DOC.Company, COM.CompanyNumber, DOC.BatchId, DOC.Generated, DOC.MergedFiles
FROM	[ILS_Datawarehouse].[dbo].[DocumentBatches] DOC
		INNER JOIN [GPCustom].[dbo].[Companies] COM ON DOC.Company = COM.CompanyId
WHERE	DOC.WeekEndingDate = @PayDate
		AND DOC.Generated = 2
		AND DOC.MergedFiles = 0
ORDER BY DOC.Company, DOC.BatchId

DECLARE curOOSCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DAT.Company, DAT.CompanyNumber, DAT.BatchId
FROM	@tblOOSBatches DAT
WHERE	(SELECT COUNT(*) FROM @tblOOSBatches TMP WHERE TMP.Company = DAT.Company) = 1

OPEN curOOSCompanies 
FETCH FROM curOOSCompanies INTO @Company, @CompanyNum, @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT Company_Id FROM OOS.post_settlement_event WHERE Event_Type = ''DRIVER_NOTIFICATION'' AND Event_Status = ''COMPLETE'' AND Period = ''' + CAST(@WeekEndingDate AS Char(10)) + ''' AND Company_Id = ' + CAST(@CompanyNum AS Varchar) + ' LIMIT 100'
	EXECUTE GPCustom.dbo.USP_QuerySWS @Query, ##tmpNewOOS, 'POSTGRESQL_IMC_ENTERPRISE'

	IF (SELECT COUNT(*) FROM ##tmpNewOOS) > 0
	BEGIN
		SET @BatchId = REPLACE(@BatchId, 'CK', 'DD')

		INSERT INTO @tblOOSBatches
		SELECT	@Company, @CompanyNum, @BatchId, 2, 0
	END

	DROP TABLE ##tmpNewOOS

	FETCH FROM curOOSCompanies INTO @Company, @CompanyNum, @BatchId
END

CLOSE curOOSCompanies
DEALLOCATE curOOSCompanies

SELECT	DISTINCT Company, @PayDate AS PayDate, Company + ',' + CONVERT(Char(10), @PayDate, 101) + ',' AS RunCommand
FROM	(
		SELECT	DAT.*,
				Counter = (SELECT COUNT(TMP.Company) FROM @tblOOSBatches TMP WHERE TMP.Company = DAT.Company)
		FROM	@tblOOSBatches DAT
		) DATA
WHERE	Counter = 2