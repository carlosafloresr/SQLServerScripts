/*
EXECUTE USP_ExportIntercompanyInvoices
*/
CREATE PROCEDURE USP_ExportIntercompanyInvoices
AS
DECLARE	@tblCustomers Table (CustomerId Varchar(12))

INSERT INTO @tblCustomers
SELECT	DISTINCT RTRIM(Account) 
FROM	PRISQL004P.Integrations.dbo.FSI_Intercompany_ARAP 
WHERE	Company = 'FI' 
		AND RecordType = 'C'

SELECT	*
FROM	Invoices
WHERE	Invoice_Date > '04/01/2019'
		AND Acct_No IN (SELECT CustomerId FROM @tblCustomers)