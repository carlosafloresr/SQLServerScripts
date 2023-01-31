DELETE	Transactions
FROM	(
		SELECT	TRA.Location,
				TRA.DocumentNumber,
				TRA.ReferenceNumber,
				TRA.Amount,
				MAX(TRA.TransactionId) AS TransactionId			
		FROM	Transactions TRA
				INNER JOIN (
							SELECT	Location,
									DocumentNumber,
									ReferenceNumber,
									Amount,
									COUNT(ReferenceNumber) AS Counter
							FROM	Transactions
							GROUP BY 
									Location,
									DocumentNumber,
									ReferenceNumber,
									Amount
							HAVING	COUNT(ReferenceNumber) > 1
							) DAT ON TRA.Location = DAT.Location AND TRA.DocumentNumber = DAT.DocumentNumber AND TRA.ReferenceNumber = DAT.ReferenceNumber AND TRA.Amount = DAT.Amount
		GROUP BY 
				TRA.Location,
				TRA.DocumentNumber,
				TRA.ReferenceNumber,
				TRA.Amount
		) DATA
WHERE	Transactions.Location = DATA.Location 
		AND Transactions.DocumentNumber = DATA.DocumentNumber 
		AND Transactions.ReferenceNumber = DATA.ReferenceNumber 
		AND Transactions.Amount = DATA.Amount
		AND Transactions.TransactionId < DATA.TransactionId