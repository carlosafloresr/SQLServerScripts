UPDATE	FSI_ReceivedDetails
SET		RecordStatus = 2,
		Emailed = 1
FROM	(
		SELECT	*
		FROM	(
				SELECT	FSI.Company,
						FSI.CustomerNumber,
						FSI.InvoiceNumber,
						FSI.FSI_ReceivedDetailId AS RecordId,
						FSI.RecordStatus AS RowStatus,
						FSI.Emailed,
						PPI.RunDate,
						CAST(dbo.DayFwdBack(FSI.InvoiceDate,'P','Saturday') AS Date) AS WeekendingDate
				FROM	View_Integration_FSI FSI
						INNER JOIN PRISQL01P.GPCustom.dbo.CustomerMaster CMA ON FSI.Company = CMA.CompanyId AND FSI.CustomerNumber = ISNULL(CMA.SWSCustomerId, CMA.CustNmbr) AND CMA.InvoiceEmailOption > 1
						LEFT JOIN PaperlessInvoices PPI ON FSI.Company = PPI.Company AND FSI.CustomerNumber = PPI.Customer AND FSI.InvoiceNumber = PPI.InvoiceNumber
				WHERE	FSI.InvoiceDate >= DATEADD(DD, -14, GETDATE())
						AND FSI.InvoiceType <> 'C'		
				) DATA
		WHERE	WeekendingDate < dbo.DayFwdBack(GETDATE(),'P','Saturday')
		) DATA
WHERE	FSI_ReceivedDetailId = RecordId
		AND RecordStatus <> 2

INSERT INTO PaperlessInvoices (Company, Customer, InvoiceNumber)
SELECT	Company, CustomerNumber, InvoiceNumber
FROM	(
		SELECT	FSI.Company,
				FSI.CustomerNumber,
				FSI.InvoiceNumber,
				FSI.FSI_ReceivedDetailId AS RecordId,
				FSI.RecordStatus,
				FSI.Emailed,
				PPI.RunDate,
				CAST(dbo.DayFwdBack(FSI.InvoiceDate,'P','Saturday') AS Date) AS WeekendingDate
		FROM	View_Integration_FSI FSI
				INNER JOIN PRISQL01P.GPCustom.dbo.CustomerMaster CMA ON FSI.Company = CMA.CompanyId AND FSI.CustomerNumber = ISNULL(CMA.SWSCustomerId, CMA.CustNmbr) AND CMA.InvoiceEmailOption > 1
				LEFT JOIN PaperlessInvoices PPI ON FSI.Company = PPI.Company AND FSI.CustomerNumber = PPI.Customer AND FSI.InvoiceNumber = PPI.InvoiceNumber
		WHERE	FSI.InvoiceDate >= DATEADD(DD, -14, GETDATE())
				AND FSI.InvoiceType <> 'C'
				AND PPI.RunDate IS Null
		) DATA
WHERE	WeekendingDate < dbo.DayFwdBack(GETDATE(),'P','Saturday')

PRINT dbo.DayFwdBack(GETDATE(),'P','Saturday')