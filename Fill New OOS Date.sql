
UPDATE	VendorMaster
SET		NewOOSDate = DOC.WeekEndingDate
FROM	(
					SELECT	Company, VendorId, MAX(WeekEndingDate) AS WeekEndingDate
					FROM	DriverDocuments
					WHERE	Company <> 'NDS'
							AND WeekEndingDate > '06/15/2021'
							--AND VendorId = 'G50282'
					GROUP BY Company, VendorId
		) DOC
WHERE	VendorMaster.Company NOT IN ('','NDS')
		AND VendorMaster.TerminationDate IS Null
		--AND VendorMaster.NewOOSDate IS Null
		AND VendorMaster.Company = DOC.Company 
		AND VendorMaster.VendorId = DOC.VendorId

