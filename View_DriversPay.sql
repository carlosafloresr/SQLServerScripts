/*
select	* 
from	DrvReps_RemittanceAdvise 
where	companyId = 'AIS' 
		AND WeekEndDate = '7/16/2009'
		AND ChekTotl IS Null
		--AND VendorId = 'A0214' 
order by vendorid, deductioncode

						SELECT	DISTINCT CompanyId, VendorId, WeekEndDate
								,ChekTotl AS Balance
						FROM	ILS_Datawarehouse.dbo.DrvReps_RemittanceAdvise 
						WHERE	ChekTotl IS NOT Null
*/
ALTER VIEW View_DriversPay
AS
SELECT	RA.CompanyId
		,RA.VendorId
		,RA.WeekEndDate
		,CAST(CASE WHEN VM.SubType = 2 THEN 1 ELSE 0 END AS Bit) AS MyTruckDriver
		,SUM(RA.DeductionAmount) AS Amount
FROM	DrvReps_RemittanceAdvise RA
		INNER JOIN GPCustom.dbo.VendorMaster VM ON RA.CompanyId = VM.Company AND RA.VendorId = VM.VendorId
WHERE	RA.ChekTotl IS Null
		AND LEFT(RA.DeductionCode, 1) < '4'
GROUP BY
		RA.CompanyId
		,RA.VendorId
		,RA.WeekEndDate
		,CAST(CASE WHEN VM.SubType = 2 THEN 1 ELSE 0 END AS Bit)
UNION
SELECT	DISTINCT RA.CompanyId
		,RA.VendorId
		,RA.WeekEndDate
		,CAST(CASE WHEN VM.SubType = 2 THEN 1 ELSE 0 END AS Bit) AS MyTruckDriver
		,RA.ChekTotl AS Balance
FROM	DrvReps_RemittanceAdvise RA
		INNER JOIN GPCustom.dbo.VendorMaster VM ON RA.CompanyId = VM.Company AND RA.VendorId = VM.VendorId
WHERE	RA.ChekTotl IS NOT Null

-- select * from View_DriversPay