
/*
SELECT * FROM SWS_DPY

SELECT * FROM View_SWS_DPY_CompanyDrivers ORDER BY Division, DriverCode

SELECT * FROM IMC.dbo.UPR00100 WHERE EmployId = 380
UPDATE IMCT.dbo.UPR00100 SET Inactive = 1 WHERE EmployId = 8612
SELECT * FROM IMC.dbo.UPR00500 WHERE EmployId = 380
*/
ALTER VIEW View_SWS_DPY_CompanyDrivers
AS
SELECT	*,
		CASE WHEN EmpInactive = 1 AND TotalAmount < 0 THEN 0 WHEN EmpInactive = 0 AND TotalAmount < 0 THEN 1 ELSE 2 END AS SortKey
FROM	(
SELECT	SWS.Company,
		SWS.Division_Code AS Division,
		PAY.Deprtmnt AS Department,
		PAY.UserDef1 AS EmployId,
		SWS.Driver_Code AS DriverCode,
		SWS.Driver_Name AS DriverName,
		PHR.GP_PayCode AS PayCode,
		SWS.WeekEndingDate AS EndDate,
		SWS.Processed,
		PAY.Inactive AS EmpInactive,
		'CDP' + RTRIM(PAY.Deprtmnt) + '_' + CAST(YEAR(SWS.WeekEndingDate) AS Char(4)) + dbo.PADL(MONTH(SWS.WeekEndingDate), 2, '0') + dbo.PADL(DAY(SWS.WeekEndingDate), 2, '0') AS BatchId,
		SUM(SWS.Driver_Total) AS Amount,
		TOT.TotalAmount
FROM	SWS_DPY SWS
		INNER JOIN (SELECT	Driver_Code,
							WeekEndingDate,
							SUM(Driver_Total) AS TotalAmount
					FROM	SWS_DPY
					WHERE	Driver_Type = 'C'
					GROUP BY
							Driver_Code,
							WeekEndingDate) TOT ON SWS.Driver_Code = TOT.Driver_Code AND SWS.WeekEndingDate = TOT.WeekEndingDate
		LEFT JOIN PHR_PayCodes PHR ON SWS.DPTrxType_Code = PHR.SWS_PayCode
		LEFT JOIN IMCT.dbo.UPR00100 PAY ON SWS.Driver_Code = PAY.UserDef1
WHERE	SWS.Driver_Type = 'C'
GROUP BY
		SWS.Company,
		SWS.Division_Code,
		PAY.Deprtmnt,
		PAY.UserDef1,
		SWS.Driver_Code,
		SWS.Driver_Name,
		PHR.GP_PayCode,
		SWS.WeekEndingDate,
		SWS.Processed,
		PAY.Inactive,
		'CDP' + RTRIM(PAY.Deprtmnt) + '_' + CAST(YEAR(SWS.WeekEndingDate) AS Char(4)) + dbo.PADL(MONTH(SWS.WeekEndingDate), 2, '0') + dbo.PADL(DAY(SWS.WeekEndingDate), 2, '0'),
		TOT.TotalAmount
HAVING	SUM(SWS.Driver_Total) <> 0) SWS