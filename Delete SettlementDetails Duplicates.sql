DELETE	SettlementDetails
WHERE	SettlementDetailId IN (
SELECT	RecordId
FROM	(
		SELECT	Fk_SettlementId,
				ProNumber,
				Description,
				TransactionDate,
				Origin,
				Destination,
				Miles,
				MAX(SettlementDetailId) AS RecordId,
				COUNT(*) AS Counter
		FROM	[Integrations].[dbo].[SettlementDetails]
		GROUP BY Fk_SettlementId,
				ProNumber,
				Description,
				TransactionDate,
				Origin,
				Destination,
				Miles
		HAVING	COUNT(*) > 1
		) DATA)