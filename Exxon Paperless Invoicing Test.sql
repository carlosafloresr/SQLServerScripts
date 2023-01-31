SELECT	*
FROM	PaperlessInvoices
WHERE	Company = 'GIS'
		AND Customer IN ('')
		AND InvoiceNumber IN ('2-259689','2-260098','2-259365')

--DELETE	PaperlessInvoices
--WHERE	Company = 'GIS'
--		AND InvoiceNumber IN ('2-259689','2-260098','2-259365')

DELETE	PaperlessInvoices
FROM	(
SELECT	FSID.Company,
		FSID.CustomerNumber,
		FSID.InvoiceNumber
FROM	View_Integration_FSI FSID
		LEFT JOIN PaperlessInvoices PINV ON FSID.Company = PINV.Company AND FSID.CustomerNumber = PINV.Customer AND FSID.InvoiceNumber = PINV.InvoiceNumber
WHERE	FSID.Company = 'GIS'
		AND FSID.CustomerNumber IN ('7000A','7000C','7000H','7000I','7000S','7000ST','7000IF')
		AND FSID.WeekEndDate = '04/11/2020'
		AND FSID.BatchId NOT LIKE '%_SUM'
		AND FSID.InvoiceType <> 'C'
		AND FSID.InvoiceTotal > 0.1
		AND LEFT(FSID.InvoiceNumber, 1) NOT IN ('C')
		AND PINV.InvoiceNumber IS NOT NULL
		AND FSID.InvoiceNumber NOT IN ('2-260573','2-259427-A','2-260928','2-259567')
		) DATA
WHERE	PaperlessInvoices.Company = DATA.Company 
		AND PaperlessInvoices.Customer = DATA.CustomerNumber
		AND PaperlessInvoices.InvoiceNumber = DATA.InvoiceNumber