/*
EXECUTE sp_RSA_invoices_NonOTR
*/
ALTER PROCEDURE sp_RSA_invoices_NonOTR
AS
SELECT	RepairNumber
		,Company
		,Division
		,OTRNumber
		,Container
		,Chassis
		,DriverId
		,InvoiceNumber
		,InvoiceTotal
		,WithInvoiceDocument
		,Creation AS ProcessDate
FROM	View_RSA_Invoices2
WHERE	FromSWS = 1
		AND Posted = 0
ORDER BY Creation DESC
