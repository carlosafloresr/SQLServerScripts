CREATE VIEW View_Settlements_DRA
AS
SELECT	Company, DriverId, CAST(WeekEndingDate AS Date) AS WeekEndingDate, Origin, SUM(TotalPaid) AS TotalPaid
FROM	[Integrations].[dbo].[View_Settlements]
WHERE	Origin = 'EMERGENCY DRIVER REL'
GROUP BY Company, DriverId, WeekEndingDate, Origin