SELECT	Company,
		DriverId,
		Pronumber,
		TransactionDate,
		Description,
		Origin,
		Destination,
		MIN(DetailId) AS DetailNumber,
		COUNT(*) AS Counter
FROM	View_Settlements
WHERE	FileName like '%.20211002.INT'
		AND Company = 'IMC'
group by Company,
		DriverId,
		Pronumber,
		TransactionDate,
		Description,
		Origin,
		Destination
having COUNT(*) > 1


DELETE	SettlementDetails
FROM	(
		SELECT	Company,
				DriverId,
				Pronumber,
				TransactionDate,
				Description,
				Origin,
				Destination,
				MIN(DetailId) AS DetailNumber,
				COUNT(*) AS Counter
		FROM	View_Settlements
		WHERE	FileName like '%.20211002.INT'
				AND Company = 'IMC'
		group by Company,
				DriverId,
				Pronumber,
				TransactionDate,
				Description,
				Origin,
				Destination
		having COUNT(*) > 1
		) DATA
WHERE	SettlementDetailId = DATA.DetailNumber
