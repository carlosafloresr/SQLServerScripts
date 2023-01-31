DELETE	MRInvoices_AP
FROM	(
		SELECT	InvoiceNumber,
				MAX(MRInvoices_APId) AS RecordId,
				COUNT(*) AS Counter
		FROM	MRInvoices_AP
		GROUP BY InvoiceNumber
		HAVING COUNT(*) > 1
		) DATA
WHERE	MRInvoices_AP.InvoiceNumber = DATA.InvoiceNumber
		AND MRInvoices_AP.MRInvoices_APId < DATA.RecordId