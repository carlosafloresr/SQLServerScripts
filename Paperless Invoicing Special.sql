TRUNCATE TABLE [Integrations].[dbo].[PaperlessInvoices_Special]
/*
="INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('HMIS','"&B2&"','"&A2&"')"
="INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','"&A1&"')"
*/
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-439380')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-439943')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-439818')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-440255')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-440310')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-441319')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-442231')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-441978')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-442658')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-442821')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-443064')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-443060')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-442981')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-443283')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-442970')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-443443')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-442982')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-443915')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-443541')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-444123')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-444656')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-445048')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-445868')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-446334')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-447784')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-447642')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-446920')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-447537')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-448070')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-448617')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-448796')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-449570')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','7-383926')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-449571')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','7-385152')
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber) VALUES ('IMC','1119N','9-451680')

SELECT	*
FROM	[Integrations].[dbo].[PaperlessInvoices_Special]

/*
INSERT INTO PaperlessInvoices_Special (Company, CustomerNumber, InvoiceNumber)
SELECT	'IMC',
		CustomerNumber,
		InvoiceNumber
FROM	FSI_ReceivedDetails
WHERE	CustomerNumber = '4112'
		AND InvoiceDate > '12/01/2022'
		AND InvoiceNumber NOT IN (SELECT InvoiceNumber FROM PaperlessInvoices WHERE Company = 'IMC' AND Customer = '4112')
*/