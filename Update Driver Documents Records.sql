UPDATE	DriverDocuments
SET		DriverDocuments.BatchId = ISNULL(DAT.OtherBatchId, '')
FROM	(
		SELECT	DriverDocumentId,
				Company,
				VendorId,
				BatchId,
				OtherBatchId = (SELECT TOP 1 TWO.BatchId FROM View_DriverDocuments TWO WHERE TWO.WeekEndingDate = ONE.WeekEndingDate AND TWO.Company = ONE.Company AND TWO.VendorId = ONE.VendorId AND TWO.BatchId <> ONE.BatchId)
		FROM	View_DriverDocuments ONE
		WHERE	WeekEndingDate = '03/29/2018'
				AND BatchId = 'DSDR032918'
		) DAT
WHERE	DriverDocuments.DriverDocumentId = DAT.DriverDocumentId