/*
SELECT	REPLACE(DocNumbr, 'I', '') AS DocNumbr
FROM	FI.dbo.RM20101 
WHERE	LEFT(DocNumbr, 1) = 'I' 
		AND CustNmbr IN ('ALLBNS')
		AND CurTrxAm > 0
		AND REPLACE(DocNumbr, 'I', '') NOT IN (SELECT Inv_No FROM ILSINT01.Integrations.dbo.SummaryBatches WHERE Company = 'FI' AND RTRIM(Acct_No) IN ('ALLBNS'))
		
		-- SELECT * FROM ILSINT01.Integrations.dbo.SummaryBatches WHERE Company = 'FI' AND RTRIM(Acct_No) IN ('ALLBNS')
*/
		
SELECT	REPLACE(DocNumbr, 'I', '') AS DocNumbr 
FROM	FI.dbo.RM20101 
WHERE	LEFT(DocNumbr, 1) = 'I' 
		AND CustNmbr IN ('ALLBNS') 
		AND CurTrxAm > 0 
		--AND REPLACE(DocNumbr, 'I', '') IN (SELECT Inv_No FROM ILSINT01.Integrations.dbo.SummaryBatches WHERE Company = 'FI' AND RTRIM(Acct_No) IN ('ALLBNS')) 
 
 
SELECT INV_NO, ACCT_NO, INV_BATCH, INV_DATE, INV_TOTAL FROM INVOICES WHERE INV_NO IN (435561,433549,437539,437619)
SELECT INV_NO FROM INVOICES WHERE INV_BATCH = 41085 ORDER BY INV_NO

SELECT	Inv_No
		,Inv_Date
		,CASE WHEN Chassis = '' THEN 'CONT' ELSE 'CHAS' END AS RecType 
FROM	ILSINT01.Integrations.dbo.SummaryBatches 
WHERE	Company = 'FI' 
		AND Acct_No = 'ALLBNS'
		AND Inv_Batch = '41085'
ORDER BY 3 DESC, 2, 1