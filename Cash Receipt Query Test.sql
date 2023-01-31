-- TRUNCATE TABLE CashReceipt
-- SELECT TOP 10 * FROM ILSINT01.FI_Data.dbo.Invoices
-- SELECT * FROM CashReceipt
-- update	CashReceipt set invoicenumber = null where left(invoicenumber, 2) = '03'
-- SELECT TOP 1 FromFile FROM CashReceipt WHERE FromFile = 'CashReceipt_Test2.xls' AND Processed > 0
-- SELECT DISTINCT BatchId FROM CashReceipt

SELECT	1 AS RowId
		,CAH.*
		,INV.Inv_No
		,INV.Inv_Date
		,INV.Chassis
		,INV.Container
		,INV.WorkOrder
		,INV.Inv_Total
FROM	CashReceipt CAH
		LEFT JOIN ILSINT01.FI_Data.dbo.Invoices INV ON CAH.InvoiceNumber = INV.Inv_No
WHERE	CAH.InvoiceNumber IS NOT Null
UNION
SELECT	2 AS RowId
		,CAH.InvoiceNumber
		,CAH.Amount
		,CAH.InvoiceDate
		,CAH.Equipment
		,CAH.WorkOrder
		,CAH.NationalAccount
		,INV.Inv_No
		,INV.Inv_Date
		,INV.Chassis
		--,INV.Container
		,INV.WorkOrder
		,INV.Inv_Total
FROM	CashReceipt CAH
		LEFT JOIN ILSINT01.FI_Data.dbo.Invoices INV ON (CAH.WorkOrder = INV.WorkOrder OR CAH.Equipment = INV.Chassis OR CAH.Equipment = INV.Container OR CAH.InvoiceDate = INV.INV_Date) AND CAH.Amount = INV.Inv_Total
WHERE	CAH.InvoiceNumber IS Null

SELECT	2 AS RowId
		,CAH.InvoiceNumber
		,CAH.Amount
		,CAH.InvoiceDate
		,CAH.Equipment
		,CAH.WorkOrder
		,CAH.NationalAccount
		,INV.Inv_No
		,INV.Inv_Date
		,INV.Chassis
		--,INV.Container
		,INV.WorkOrder
		,INV.Inv_Total
FROM	CashReceipt CAH
		LEFT JOIN ILSINT01.FI_Data.dbo.Invoices INV ON (CAH.Equipment = INV.Chassis)
WHERE	CAH.InvoiceNumber IS Null
		AND CAH.Equipment = 'TSXZ960250'