/*
SELECT	* 
FROM	EscrowInterest 
WHERE	CompanyId = 'AIS' 
		AND Period = '201003' 
ORDER BY VendorId
*/
-- USP_EscrowInterest_Integration 'IMC', 'EI002790DRV1003'
-- EXECUTE USP_DriversWithBalance 'AIS', 'DRV', '0-02-2790'

UPDATE	EscrowInterest 
SET		Approved = 1,
		Processed = 0
WHERE	CompanyId = 'AIS' 
		AND AccountIndex = 248 
		AND DriverClass = 'DRV' 
		AND Period = '201003'

SELECT	VendName
		,PM.VendorId
		,CASE WHEN Ten99Type = 4 THEN 'YES' ELSE 'NO' END AS IS1099
		,CAST(Balance AS Char(10)) AS Balance 
FROM	GIS.dbo.PM00200 PM 
		INNER JOIN GPCustom.dbo.View_EscrowBalances_ForInterest EI ON PM.VendorId = EI.VendorId AND EI.AccountNumber = '0-02-2790' AND EI.CompanyId = 'GIS' 
WHERE	VendStts = 1 
		AND VndClsId = 'DRV' 
ORDER BY PM.VendorId

SELECT * FROM View_EscrowBalances_ForInterest WHERE CompanyId = 'GIS' ORDER BY VendorId

SELECT 	CompanyId,
		VendorId,
		AccountNumber,
		SUM(Amount) AS Balance
FROM 	View_EscrowTransactions
WHERE	Fk_EscrowModuleId IN (1,2,5)
		AND PostingDate IS NOT Null
		AND DeletedOn IS Null
		AND CompanyId = 'GIS'
		AND VendorId = 'G8622'
GROUP BY 
		CompanyId,
		VendorId,
		AccountNumber
ORDER BY VendorId

HAVING 	SUM(CASE WHEN Source = 'AR' THEN Amount * -1
		ELSE Amount END) > 0