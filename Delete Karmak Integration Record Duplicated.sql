DELETE	KarmakIntegration
FROM	(
		SELECT	InvoiceNumber,
				MAX(KarmakIntegrationId) AS RecordId
		FROM	KarmakIntegration
		WHERE	InvoiceNumber IN (
								SELECT	InvoiceNumber
								FROM	(
										SELECT	InvoiceNumber,
												COUNT(InvoiceNumber) AS Counter
										FROM	KarmakIntegration
										WHERE	InvoiceNumber > 43000
										GROUP BY InvoiceNumber
										HAVING COUNT(InvoiceNumber) > 1
										) DATA
								)
		GROUP BY InvoiceNumber
		) DATA
WHERE	KarmakIntegration.KarmakIntegrationId = DATA.RecordId