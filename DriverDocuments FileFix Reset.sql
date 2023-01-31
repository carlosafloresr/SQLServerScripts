SELECT	TOP 100 *
FROM	View_DriverDocuments
WHERE	WeekEndingDate = '07/11/2019'
		AND Company = 'DNJ'
		AND VendorId = 'D0047'
/*
UPDATE	DriverDocuments
SET		FileFixed = 0
WHERE	WeekEndingDate = '07/04/2019'
		AND Company = 'DNJ'
*/