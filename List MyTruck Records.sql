SELECT	ROW_NUMBER() OVER (ORDER BY CheckDate DESC) AS 'RowNumber'
		,CheckDate
		,Balance
FROM	(SELECT	DISTINCT CheckDate
				,ChekTotl AS Balance
		FROM	ILS_Datawarehouse.dbo.DrvReps_RemittanceAdvise 
		WHERE	CompanyId = 'AIS'
				AND VendorId = 'A0013'
				AND ChekTotl IS NOT Null) REC1
				
SELECT	ROW_NUMBER() OVER (PARTITION BY VendorId ORDER BY CheckDate DESC) AS 'RowNumber'
		,CheckDate
		,DeductionAmount
FROM	ILS_Datawarehouse.dbo.DrvReps_RemittanceAdvise 
WHERE	CompanyId = 'AIS'
		AND VendorId = 'A0013'
		AND DeductionType = 'Drayage'
		AND ChekTotl IS NOT Null
		AND AmntPaid > 0
ORDER BY CheckDate DESC

PRINT dbo.DriverPayrollConceptBalance('AIS', 'A0242', 'Truck Note', 1)