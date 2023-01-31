/*
SELECT	CompanyId,
		SWSCustomerId,
		ISNULL(CASE WHEN SWSCustomerId = '' THEN Null ELSE SWSCustomerId END, CustNmbr) AS CustNmbr,
		CustName,
		RequiredDocuments,
		InvoiceEmailOption,
		ReferenceOnEmail,
		TextPDF,
		Exxon
FROM	GPCustom.dbo.CustomerMaster
WHERE	CompanyId = 'GIS'
		AND CUSTNMBR IN ('7000A','7000C','7000H','7000I','7000S','7000ST','7000IF')
		--AND InvoiceEmailOption > 1
*/

UPDATE	CustomerMaster
SET		InvoiceEmailOption = 5--CustomerMaster_GISExxon.InvoiceEmailOption
FROM	CustomerMaster_GISExxon
WHERE	CustomerMaster.CompanyId = CustomerMaster_GISExxon.CompanyId
		AND CustomerMaster.CustNmbr = CustomerMaster_GISExxon.CustNmbr