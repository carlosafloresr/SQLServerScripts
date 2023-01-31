UPDATE	RSA_Invoice
SET		Historic = 1
FROM	(
		SELECT	idrepairnumber, MAX(Creation) AS Creation
		FROM	RSA_Invoice
		WHERE	idrepairnumber IN (
									SELECT	idrepairnumber
									FROM	(
											SELECT	idrepairnumber, COUNT(idrepairnumber) AS Counter
											FROM	RSA_Invoice
											GROUP BY idrepairnumber
											HAVING COUNT(idrepairnumber) > 1
											) DATA
									)
		GROUP BY idrepairnumber
		) REC
WHERE	RSA_Invoice.IdRepairNumber = REC.IdRepairNumber
		AND RSA_Invoice.Creation < REC.Creation