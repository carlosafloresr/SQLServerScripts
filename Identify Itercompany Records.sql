/*
SELECT	*
FROM	FSI_ReceivedDetails 
WHERE	Intercompany = 1
ORDER BY FSI_ReceivedDetailId
*/

SELECT	BatchId
		,InvoiceNumber
		,InvoiceDate
		,ApplyTo
		,BillToRef
		,CustomerNumber
		,VendorPayTotal
		,FuelSurcharge
		,FuelRebateTotal
		,InvoiceTotal
		,TruckAccrualTotal
		,Division
		,InvoiceType
FROM	FSI_ReceivedDetails 
WHERE	Intercompany = 0
		AND InvoiceDate > GETDATE() - 30
		AND InvoiceNumber IN (SELECT BillToRef FROM FSI_ReceivedDetails WHERE Intercompany = 1)