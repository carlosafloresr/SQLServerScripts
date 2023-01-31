/*
SELECT * FROM View_Integration_DPY WHERE BatchId = '29_DPY_20120331'
*/
CREATE VIEW [dbo].[View_Integration_DPY_ByDriverId]
AS
SELECT	HD.Integration_APHdrId, 
		HD.BatchId, 
		HD.Company, 
		HD.WeekEndDate,
		HD.ReceivedOn,
		DE.DriverId,
		SUM(HD.TotalDrayage) AS TotalDrayage, 
		SUM(HD.TotalMiles) AS TotalMiles, 
		SUM(HD.TotalFuelRebate) AS TotalFuelRebate, 
		SUM(HD.TotalAccrud) AS TotalAccrud, 
		SUM(DE.Drayage) AS Drayage, 
		SUM(DE.Miles) AS Miles, 
		SUM(DE.DriverFuelRebate) AS DriverFuelRebate, 
		SUM(DE.Accrud) AS Accrud,
		HD.TotalTransactions,
		DE.Verification, 
		DE.Processed,
		HD.Creation,
		DE.Division,
		CASE WHEN HD.Company = 'NDS' THEN LEFT(HD.BatchId, 2) ELSE Null END AS Agent,
		MIN(DE.Integration_APDetId) AS Integration_APDetId
FROM	Integration_APHeader HD
		INNER JOIN Integration_APDetails DE ON HD.BatchId = DE.BatchId
GROUP BY
		HD.Integration_APHdrId, 
		HD.BatchId, 
		HD.Company, 
		HD.WeekEndDate,
		HD.ReceivedOn,
		DE.DriverId,
		HD.TotalTransactions,
		DE.Verification, 
		DE.Processed,
		HD.Creation,
		DE.Division



GO


