INSERT INTO PaperlessInvoices (Company, Customer, InvoiceNumber)
SELECT	Company, CustomerNumber, InvoiceNumber
FROM	View_Integration_FSI
WHERE	InvoiceNumber IN ('D37-132310C','D37-132311B','D37-132313C','D37-132314C','D37-132315B','D37-132316B','D37-132319B','D37-132320B','D37-132321C','D37-132322B')