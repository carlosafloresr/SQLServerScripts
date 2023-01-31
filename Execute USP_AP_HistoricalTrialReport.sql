/*
EXECUTE USP_AP_HistoricalTrialReport 'AIS', '10/01/2022' 
*/
SELECT * FROM DYNAMICS.dbo.View_FiscalPeriod where Year1 = 2022
SELECT DISTINCT CAST(Year1 AS Varchar) + ' ' + DATENAME(month, DATEADD( month , PeriodId, -3)) + ' [' + CONVERT(Char(10), AgingDate, 101) + ']' AS PeriodText, CONVERT(Char(10), AgingDate, 101) AS AgingDate FROM GPCustom.dbo.AP_HistoricalTrialData HIS INNER JOIN DYNAMICS.dbo.View_FiscalPeriod FIP ON HIS.AgingDate BETWEEN FIP.StartDate AND FIP.EndDate WHERE HIS.Company = 'AIS'