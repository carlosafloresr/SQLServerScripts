/*
SELECT	*
FROM	View_OOS_Transactions
WHERE	DeductionCode = 'CESC'
		AND VendorId = 'A0013'

SELECT	*
FROM	EscrowTransactions
WHERE	VendorId = 'A0013'
		AND AccountNumber = '0-00-2790'
		AND Fk_EscrowModuleId = 1

delete PHR_ReceivedTransactions where batchid = 'PHRIILS_062808'

SELECT * FROM View_OOS_Deductions

SELECT * FROM AIS.dbo.PM00200
*/

SELECT	ET.CompanyId,
		ET.VendorId,
		PM.VendName,
		ISNULL(OD.DeductionCode, 'No Defined') AS DeductionCode,
		ISNULL(OD.DeductionNumber, 0) AS DeductionNumber,
		ISNULL(OD.Deducted, 0.0) AS Deducted,
		SUM(ET.Amount) AS Balance
FROM	EscrowTransactions ET
		LEFT JOIN View_OOS_Deductions OD ON ET.VendorId = OD.VendorId AND ET.CompanyId = OD.Company AND OD.DeductionCode IN ('CESC','ESCA','ADV2','ESA4','ESC1','ESC2') AND OD.DeductionInactive = 0
		LEFT JOIN VendorMaster VM ON ET.VendorId = VM.VendorId AND ET.CompanyId = VM.Company
		INNER JOIN AIS.dbo.PM00200 PM ON ET.VendorId = PM.VendorId AND PM.VndClsid = 'DRV'
WHERE	ET.Fk_EscrowModuleId = 1
		AND ET.COmpanyId = 'AIS'
		AND ET.PostingDate IS NOT Null
		--AND VM.TerminationDate IS Null
GROUP BY
		ET.CompanyId,
		ET.VendorId,
		PM.VendName,
		ISNULL(OD.DeductionCode, 'No Defined'),
		ISNULL(OD.DeductionNumber, 0),
		ISNULL(OD.Deducted, 0.0)
ORDER BY
		ET.VendorId, 4

-- select * from View_OOS_Transactions where vendorid = 'A0191' AND DeductionCode = 'CESC'