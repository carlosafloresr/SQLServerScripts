ALTER PROCEDURE USP_MSRBatch
		@BatchId	Varchar(20),
		@Customer	Varchar(10),
		@DocNumber	Varchar(25),
		@DocDate	Datetime
AS
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
		,LEFT(MSR.DocNumber, 1) AS RecType
INTO	#curDatos
FROM	MSR_ReceviedTransactions MSR
WHERE	BatchId = @BatchId
		AND Customer = @Customer
		AND DocNumber = @DocNumber
		AND DocDate = @DocDate

SELECT	Inv_No
		,Container
		,Chassis
		,WorkOrder
INTO	#curInvoices
FROM	(SELECT	Inv_No
				,Container
				,Chassis
				,WorkOrder
		FROM	FI_Data.dbo.Invoices
		WHERE	Inv_No IN (SELECT Inv_No FROM #curDatos WHERE Inv_No > 0)
				AND SUBSTRING(@BatchId, 4, 1) = 'F'
		UNION
		SELECT	Inv_No
				,Container
				,Chassis
				,WorkOrder
		FROM	RCMR_Data.dbo.Invoices 
		WHERE	Inv_No IN (SELECT Inv_No FROM #curDatos WHERE Inv_No > 0)
				AND SUBSTRING(@BatchId, 4, 1) = 'R') A

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
		,ISNULL(MSR.Container, FID.Container) AS Container
		,ISNULL(MSR.Chassis, FID.Chassis) AS Chassis
		,FID.WorkOrder
FROM	#curDatos MSR
		LEFT JOIN #curInvoices FID ON MSR.Inv_No = FID.Inv_No
WHERE	RecType = 'I'
UNION
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
		,Null
FROM	#curDatos MSR
WHERE	RecType = 'B'

DROP TABLE #curInvoices
DROP TABLE #curDatos