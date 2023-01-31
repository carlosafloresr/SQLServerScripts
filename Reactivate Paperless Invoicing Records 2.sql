UPDATE	FSI_ReceivedDetails
SET		RecordStatus = 1
FROM	(
		SELECT	Company,
				InvoiceNumber,
				RecordStatus,
				WeekEndDate,
				FSI_ReceivedDetailId
		FROM	View_Integration_FSI
		WHERE	WeekEndDate = '04/21/2018'
				AND RecordStatus = 2
				AND InvoiceNumber IN (
									SELECT	InvoiceNumber
									FROM	PaperlessInvoices
									WHERE	Company = 'NDS'
											AND CAST(RunDate AS Date) = '04/24/2018'
									)
		) DATA
WHERE	FSI_ReceivedDetails.FSI_ReceivedDetailId = DATA.FSI_ReceivedDetailId

DELETE	PaperlessInvoices
WHERE	Company = 'NDS'
		AND CAST(RunDate AS Date) = '04/24/2018'