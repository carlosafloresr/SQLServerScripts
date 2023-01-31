DECLARE	@Days Int = 45

SELECT	RM.CUSTNMBR,
		RM.DOCNUMBR,
		CAST(RM.DOCDATE AS Date) AS DocDate,
		CAST(RM.DUEDATE AS Date) AS DueDate,
		RM.ORTRXAMT AS Invoice_Amount,
		RM.CURTRXAM AS Balance,
		DATEDIFF(dd, RM.DOCDATE, GETDATE()) AS DaysFromInvoiced,
		DATEDIFF(dd, RM.DUEDATE, GETDATE()) AS DaysFromDue,
		CM.RequiredDocuments,
		CM.InvoiceEmailOption,
		dbo.FindGPCustomerEmails(RM.CUSTNMBR) AS EmailAddresses
FROM	RM20101 RM
		INNER JOIN GPCustom.dbo.CustomerMaster CM ON RM.CUSTNMBR = CM.CustNmbr AND CM.CompanyId = DB_NAME()
WHERE	RM.RMDTYPAL = 1
		AND DATEDIFF(dd, RM.DOCDATE, GETDATE()) >= @Days
		AND RM.CURTRXAM > 0
		AND CM.InvoiceEmailOption > 1
		--AND CM.SendPastDueInvoices = 1
ORDER BY RM.CUSTNMBR, 7 DESC

/*
SELECT	*
FROM	GPCustom.dbo.CustomerMaster
WHERE	CompanyId = 'AIS'
*/