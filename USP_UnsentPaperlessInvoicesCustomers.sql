/*
EXECUTE USP_UnsentPaperlessInvoicesCustomers 'AIS'

SELECT CompanyId, CustNmbr FROM ILSGP01.GPCustom.dbo.CustomerMaster WHERE InvoiceEmailOption > 1
*/
ALTER PROCEDURE USP_UnsentPaperlessInvoicesCustomers (@Company Varchar(5))
AS
SELECT	DISTINCT FSI.CustomerNumber
FROM	View_Integration_FSI FSI
		INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CUS ON FSI.CustomerNumber = CUS.CustNmbr AND FSI.Company = CUS.CompanyId
WHERE	FSI.Status IN (2,3,5)
		AND FSI.Company = @Company
		AND FSI.RecordStatus IN (0,5)
		AND CUS.InvoiceEmailOption > 1
ORDER BY FSI.CustomerNumber