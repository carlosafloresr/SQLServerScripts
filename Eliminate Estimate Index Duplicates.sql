DELETE	Estimates
FROM	(
		SELECT	Inv_No, min(EstimateId) AS EstimateId
		FROM	Estimates
		WHERE	Inv_No IN (
						SELECT	Inv_No
						FROM	(
								SELECT	Inv_No ,
										COUNT(Inv_No) as counter
								FROM	Estimates 
								GROUP BY Inv_No
								HAVING COUNT(Inv_No) > 1
								) RECS
						)
		GROUP BY Inv_No
		) RECS
WHERE	Estimates.EstimateId > RECS.EstimateId
		AND Estimates.Inv_No = RECS.Inv_No