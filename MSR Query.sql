SELECT	MSR.MSR_ReceivedTransactions
		,MSR.Company
		,MSR.BatchId
		,MSR.DocNumber
		,MSR.Description
		,MSR.DocDate
		,MSR.Customer
		,MSR.DocType
		,MSR.Amount
		,MSR.Account
		,MSR.Credit
		,MSR.Debit
		,MSR.VoucherNumber
		,MSR.LineItem
		,MSR.Verification
		,MSR.Processed
		,MSR.Container
		,MSR.Chassis
		,CASE WHEN LEFT(MSR.DocNumber, 1) = 'I' THEN CAST(REPLACE(MSR.DocNumber, 'I', '') AS Int) ELSE 0 END AS Inv_No
		,CASE WHEN LEFT(MSR.DocNumber, 1) = 'B' THEN CAST(REPLACE(MSR.DocNumber, 'B', '') AS Int) ELSE 0 END AS Inv_Batch
INTO	#curDatos
FROM	MSR_ReceviedTransactions MSR
WHERE	MSR.BatchId = 'AR_FI_010509'
		AND MSR.Company = 'FI'

SELECT	MSR.MSR_ReceivedTransactions
		,MSR.Company
		,MSR.BatchId
		,MSR.DocNumber
		,FID.Inv_No
		,MSR.Description
		,MSR.DocDate
		,MSR.Customer
		,MSR.DocType
		,MSR.Amount
		,MSR.Account
		,MSR.Credit
		,MSR.Debit
		,MSR.VoucherNumber
		,MSR.LineItem
		,MSR.Verification
		,MSR.Processed
		,CASE WHEN FID.Container IS Null OR FID.Container = '' THEN MSR.Container ELSE FID.Container END AS Container
		,CASE WHEN FID.Chassis IS Null OR FID.Chassis = '' THEN MSR.Chassis ELSE FID.Chassis END AS Chassis
		,FID.WorkOrder
FROM	#curDatos MSR
		LEFT JOIN ILSINT01.FI_Data.dbo.Invoices FID ON MSR.Inv_No = FID.Inv_No
WHERE	MSR.Inv_No > 0
UNION
SELECT	MSR.MSR_ReceivedTransactions
		,MSR.Company
		,MSR.BatchId
		,MSR.DocNumber
		,FID.Inv_No
		,MSR.Description
		,MSR.DocDate
		,MSR.Customer
		,MSR.DocType
		,MSR.Amount
		,MSR.Account
		,MSR.Credit
		,MSR.Debit
		,MSR.VoucherNumber
		,MSR.LineItem
		,MSR.Verification
		,MSR.Processed
		,CASE WHEN FID.Container IS Null OR FID.Container = '' THEN MSR.Container ELSE FID.Container END AS Container
		,CASE WHEN FID.Chassis IS Null OR FID.Chassis = '' THEN MSR.Chassis ELSE FID.Chassis END AS Chassis
		,FID.WorkOrder
FROM	#curDatos MSR
		LEFT JOIN ILSINT01.FI_Data.dbo.Invoices FID ON MSR.Inv_Batch = FID.Inv_Batch
WHERE	MSR.Inv_Batch > 0

DROP TABLE #curDatos

-- SELECT * FROM MSR_ReceviedTransactions WHERE LEFT(DocNumber, 1) <> 'I' AND Company = 'FI'
-- select top 10 * from ILSINT01.FI_Data.dbo.Invoices
