SELECT	TransType,
		SourceType,
		dbo.PADL(FORMAT(SUM(Amount), 'C', 'en-us'), 20, ' ') AS Amount,
		COUNT(*) AS Counter
FROM	FSI_TransactionDetails
WHERE	BatchId = '9FSI20230125_1451'
		--AND IntegrationType IN ('FSIG')
		--AND TransType LIKE 'DEM%'
GROUP BY TransType, SourceType

/*
SELECT	*
FROM	FSI_TransactionDetails
WHERE	BatchId = '9FSI20230126_1006'
		AND InvoiceNumber = '95-290938'
		--AND IntegrationType IN ('FSIG')
		--AND TransType LIKE 'PREPAY'
ORDER BY InvoiceNumber

SELECT	SUBSTRING(InvoiceNumber, PATINDEX('%[0-9][0-9]-%', InvoiceNumber), 2),
		COUNT(*) AS Counter
FROM	FSI_TransactionDetails
WHERE	BatchId = '9FSI20230126_1006'
		AND IntegrationType = 'FSI'
		AND (InvoiceNumber LIKE '[0-9][0-9]-%'
		OR InvoiceNumber LIKE 'D[0-9][0-9]-%'
		OR InvoiceNumber LIKE 'C[0-9][0-9]-%')
group by SUBSTRING(InvoiceNumber, PATINDEX('%[0-9][0-9]-%', InvoiceNumber), 2)
*/