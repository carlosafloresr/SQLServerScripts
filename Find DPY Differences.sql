/*
SELECT * FROM dbo.Integration_APDetails WHERE BatchId = '1_DPY_20081025' AND Drayage + DriverFuelRebate = 2054.73 ORDER BY VendorId
SELECT * FROM IMC.dbo.PM10000 WHERE BachNumb = 'DPY_20081025' ORDER BY VendorId

SELECT SUM(Drayage + DriverFuelRebate) AS Total FROM dbo.Integration_APDetails WHERE BatchId = '1_DPY_20081025'

SELECT SUM(DocAmnt) FROM IMC.dbo.PM10000 WHERE BachNumb = 'DPY_20081025'
*/

SELECT	GP.VendorId,
		GP.DocAmnt * CASE WHEN GP.DocType = 5 THEN -1 ELSE 1 END AS DocAmnt,
		DP.Drayage + DP.DriverFuelRebate AS Total,
		GP.DocType,
		CASE WHEN DP.Drayage + DP.DriverFuelRebate < 0 THEN 5 ELSE 1 END AS Type,
		DP.Drayage,
		DP.DriverFuelRebate
FROM	Integration_APDetails DP
		RIGHT JOIN IMC.dbo.PM10000 GP ON GP.VendorId = DP.VendorId AND GP.DocType = CASE WHEN DP.Drayage + DP.DriverFuelRebate < 0 THEN 5 ELSE 1 END AND DP.BatchId = '1_DPY_20081025'
WHERE	GP.BachNumb = 'DPY_20081025'
		AND GP.DocAmnt IS NULL