/*
EXECUTE USP_UnsentPaperlessInvoices 'AIS', '7296'

SELECT CompanyId, CustNmbr FROM ILSGP01.GPCustom.dbo.CustomerMaster WHERE InvoiceEmailOption > 1
*/
ALTER PROCEDURE USP_UnsentPaperlessInvoices
		@Company	Varchar(5),
		@Customer	Varchar(15)
AS
SELECT	DISTINCT FSI.InvoiceNumber
FROM	View_Integration_FSI FSI
WHERE	FSI.Status IN (2,3,5)
		AND FSI.Company = @Company
		AND FSI.CustomerNumber = @Customer
		AND FSI.RecordStatus IN (0,5)
ORDER BY FSI.InvoiceNumber