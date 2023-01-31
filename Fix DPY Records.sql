SELECT	*
FROM	Integration_APDetails
WHERE	BatchId IN (SELECT BatchId
					FROM	Integration_APHeader
					WHERE	Company = 'NDS'
							AND WeekEndDate = '10/15/2011')
		AND VendorId = 'N25005'


UPDATE	Integration_APDetails
SET		Processed = 0
WHERE	BatchId IN (SELECT BatchId
					FROM	Integration_APHeader
					WHERE	Company = 'NDS'
							AND WeekEndDate = '10/15/2011')
							
UPDATE	Integration_APHeader
SET		Status = 1
WHERE	Company = 'NDS'
		AND WeekEndDate = '10/15/2011'
/*
UPDATE	Integration_APDetails
SET		VendorId = 'N25005',
		DriverId = 'N25005'
WHERE	BatchId = '25_DPY_20111015'
		AND VendorId = 'N25005'

UPDATE	Integration_APDetails
SET		Integration_APDetails.Drayage			= RECS.Drayage,
		Integration_APDetails.Miles				= RECS.Miles,
		Integration_APDetails.DriverFuelRebate	= RECS.DriverFuelRebate,
		Integration_APDetails.Accrud			= RECS.Accrud
FROM	(
		SELECT	SUM(Drayage) AS Drayage,
				SUM(Miles) AS Miles,
				SUM(DriverFuelRebate) AS DriverFuelRebate,
				SUM(Accrud) AS Accrud
		FROM	Integration_APDetails
		WHERE	BatchId IN (SELECT BatchId
							FROM	Integration_APHeader
							WHERE	Company = 'NDS'
									AND WeekEndDate = '10/15/2011')
									AND VendorId = 'N25005'
		) RECS
WHERE	Integration_APDetId = 85842

DELETE	Integration_APDetails WHERE Integration_APDetId = 85847
*/