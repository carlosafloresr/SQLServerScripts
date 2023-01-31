SELECT	CRT.CashReceiptTruckingId
		,CRT.Company
		,CRT.BatchId
		,CRT.InvoiceNumber
		,CRT.Payment
		,CRT.NationalAccount
		,CRT.CustomerNumber
		,RMH.CustNmbr
		,RMH.CprCstNm
		,RMH.DocNumbr
		,RMH.OrTrxAmt
		,CASE WHEN CRT.Payment <> RMH.OrTrxAmt THEN 'DIFF' ELSE 'OK' END AS Result
FROM	GPCustom.dbo.CashReceiptTrucking CRT
		LEFT JOIN RM30101 RMH ON CRT.InvoiceNumber = RMH.DocNumbr
ORDER BY
		CRT.InvoiceNumber
		
/*
-- 886 Invoices
SELECT	CustNmbr
		,CprCstNm
		,DocNumbr
FROM	RM30101
WHERE	DocNumbr IN (SELECT InvoiceNumber FROM GPCustom.dbo.CashReceiptTrucking)
ORDER BY DocNumbr

SELECT * FROM RM20101
SELECT * FROM RM30101

SELECT	CustNmbr
		,CprCstNm
		,DocNumbr
FROM	RM20101
WHERE	DocNumbr IN (SELECT InvoiceNumber FROM GPCustom.dbo.CashReceiptTrucking)
ORDER BY DocNumbr

SELECT	InvoiceNumber 
FROM	GPCustom.dbo.CashReceiptTrucking
WHERE	InvoiceNumber NOT IN (SELECT DocNumbr FROM RM20101)
		AND InvoiceNumber NOT IN (SELECT DocNumbr FROM RM30101)
*/