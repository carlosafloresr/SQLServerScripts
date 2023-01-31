USE [DYNAMICS]
GO

/****** Object:  View [dbo].[View_FiscalPeriod]    Script Date: 12/7/2022 9:50:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[View_FiscalPeriod]
AS
SELECT	FPD.Year1
		,FPD.PeriodId
		,FPD.PerName
		,GPCustom.dbo.PADL(FPD.PeriodId, 2, '0') + '-' + CAST(FPD.Year1 AS Varchar) AS GP_Period
		,MAX(FPD.PeriodDt) AS StartDate
		,MAX(CAST(CONVERT(Char(10), FPD.PerdEndt, 101) + ' 11:59:59 PM' AS Datetime)) AS EndDate
		,FPH.HISTORYR
FROM	AIS.dbo.SY40100 FPD
		INNER JOIN AIS.dbo.SY40101 FPH ON FPD.YEAR1 = FPH.YEAR1
WHERE	FPD.Year1 > 2010
		AND FPD.Series > 0
		AND FPD.PeriodId > 0
		--AND Closed = 0
GROUP BY FPD.Year1
		,FPD.PerName
		,FPD.PeriodId
		,FPH.HISTORYR
GO


-- select * from AIS.dbo.SY40100 where year1 = 2022 and Series > 0 and PeriodId > 0