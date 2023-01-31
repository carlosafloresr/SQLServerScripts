SELECT	CustNmbr,
		CustName,
		CustClas,
		Address1,
		Address2,
		City,
		State,
		Zip,
		Phone1,
		Inactive,
		Hold,
		CntCprsn,
		CASE WHEN InvoiceEmailOption = 1 THEN 'Print' ELSE 'Email' END AS InvoicePrint,
		lower(NDS.dbo.FindGPCustomerEmails(CustNmbr)) AS SendTo
FROM	CustomerMaster
WHERE	CompanyId = 'NDS'
		AND CustNmbr IN ('10422','10644','22059','22069','22115','22277','22411','229914')
		--AND CustNmbr IN ('10590','11561','11406','11543','11742','14170','22043','22264','22356','7185','7316','7582','7686','8111','8196','8542','8572','8886','9862')
ORDER BY CustNmbr