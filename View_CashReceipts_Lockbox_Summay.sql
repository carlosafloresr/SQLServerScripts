CREATE VIEW View_CashReceipts_Lockbox_Summay
AS
SELECT	Company
		,BatchNumber
		,RTRIM(SerialNumber) AS CheckNumber
		,CheckAccount
		,RTRIM(InvoiceNumber) AS InvoiceNumber
		,SUM(INV_Number) AS Amount
FROM	CashReceipts_Lockbox
WHERE	INV_Number <> 0
GROUP BY Company
		,BatchNumber
		,SerialNumber
		,CheckAccount
		,InvoiceNumber