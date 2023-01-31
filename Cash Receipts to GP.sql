-- TRUNCATE TABLE CSH_ReceivedTransaction
-- USP_CashReceiptBatch 'ACH071309MAE', 1
/*
SELECT	* 
FROM	CSH_ReceivedTransaction
*/

UPDATE	CSH_ReceivedTransaction
SET		CSH_ReceivedTransaction.WorkOrder	= ISNULL(Invoices.WorkOrder, CSH_ReceivedTransaction.WorkOrder),
		CSH_ReceivedTransaction.Equipment	= ISNULL(Invoices.Chassis, CSH_ReceivedTransaction.Equipment)
FROM	ILSINT01.FI_Data.dbo.Invoices Invoices
WHERE	Invoices.Inv_No	= REPLACE(CSH_ReceivedTransaction.InvoiceNumber, 'I', '') AND
		CSH_ReceivedTransaction.Amount = Invoices.Inv_Total
		
--LEFT JOIN ILSINT01.FI_Data.dbo.Invoices INV ON CR.WorkOrder = INV.WorkOrder OR (CR.Equipment = INV.Chassis AND INV.Inv_Date BETWEEN CR.InvoiceDate - 3 AND CR.InvoiceDate + 3 AND CR.Amount = INV.Inv_Total)
