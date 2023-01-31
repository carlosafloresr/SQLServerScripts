SELECT *, CAST(Year1 AS Char(5)) + LEFT(PerName, 5) + CONVERT(Char(10), DateStart, 101) + ' - ' + CONVERT(Char(10), DateEnd, 101) AS Period FROM View_FiscalPeriods WHERE (PeriodId = 1 AND YEAR1 = YEAR(GETDATE()) - 1) OR (DateStart < GETDATE() AND YEAR1 BETWEEN YEAR(GETDATE()) - 1 AND YEAR(GETDATE())) ORDER BY Year1, PeriodId