/*
SELECT	*
FROM	RM00101
WHERE	CustNmbr IN (SELECT CustNmbr FROM GPCustom.dbo.CustomerMaster WHERE CompanyId = DB_NAME() AND InvoiceEmailOption > 1)
*/

UPDATE	RM00101
SET		Send_Email_Statements = 1
WHERE	CustNmbr IN (SELECT CustNmbr FROM GPCustom.dbo.CustomerMaster WHERE CompanyId = DB_NAME() AND InvoiceEmailOption > 1)