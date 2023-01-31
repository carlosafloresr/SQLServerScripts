USE GPCustom 
GO

-- SELECT * FROM DYNAMICS.dbo.View_Fiscalperiod FP WHERE FP.HISTORYR = 0 AND YEAR1 = 2022 ORDER BY PERIODID

SET NOCOUNT ON

DECLARE	@Company	Varchar(5),
		@RunDate	Date,
		@JustList	Bit = 0,
		@DatePeriod	Date = '12/31/2022'

DECLARE @tblPeriods Table (Company Varchar(5),PeriodId Int, EndDate Date)

INSERT INTO @tblPeriods
SELECT	DISTINCT CO.CompanyId, GL.PERIODID, CAST(FP.ENDDATE AS Date) AS EndDate
FROM	AIS.dbo.GL20000 GL
		INNER JOIN DYNAMICS.dbo.View_Fiscalperiod FP ON FP.HISTORYR = 0 AND GL.PERIODID = FP.PERIODID
		INNER JOIN Companies CO ON CO.CompanyId IN ('AIS','DNJ','GIS','GLSO','HMIS','IILS','IMC','IMCC','IMCMR','OIS','PDS')
WHERE	(@DatePeriod IS Null
		OR (@DatePeriod IS NOT Null AND CAST(FP.EndDate AS Date) = @DatePeriod))
ORDER BY 1, 3 DESC

IF @JustList = 0 
BEGIN
	DECLARE curCompaniesPeriods CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	PE.Company, PE.EndDate
	FROM	@tblPeriods PE
			LEFT JOIN AP_HistoricalTrialData HT ON PE.Company = HT.Company AND PE.EndDate = HT.AgingDate
	WHERE	HT.AgingDate IS Null
	ORDER BY PE.EndDate DESC, PE.Company

	OPEN curCompaniesPeriods 
	FETCH FROM curCompaniesPeriods INTO @Company, @RunDate

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		PRINT @Company + ' - ' + CAST(@RunDate AS Varchar)
	
		EXECUTE USP_AP_HistoricalTrialReport @Company, @RunDate

		FETCH FROM curCompaniesPeriods INTO @Company, @RunDate
	END

	CLOSE curCompaniesPeriods
	DEALLOCATE curCompaniesPeriods
END
ELSE
BEGIN
	SELECT	PE.Company, PE.EndDate
	FROM	@tblPeriods PE
			LEFT JOIN AP_HistoricalTrialData HT ON PE.Company = HT.Company AND PE.EndDate = HT.AgingDate
	WHERE	HT.AgingDate IS Null
	ORDER BY PE.EndDate DESC, PE.Company 
END

/*
EXECUTE USP_AP_HistoricalTrialReport 'OIS', '09/03/2022'

select distinct company, AgingDate from AP_HistoricalTrialData ORDER BY AgingDate, Company

SELECT * FROM DYNAMICS.dbo.View_Fiscalperiod FP WHERE FP.HISTORYR = 0 ORDER BY PERIODID
*/