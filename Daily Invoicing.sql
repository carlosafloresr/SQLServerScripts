DECLARE	@WeekEndDate Date = CASE WHEN DATENAME(Weekday, GETDATE()) = 'Saturday' THEN GETDATE() ELSE dbo.DayFwdBack(GETDATE(), 'P', 'Saturday') END

SELECT	FSI.CustomerNumber,
		FSI.InvoiceNumber,
		FSI.InvoiceDate,
		FSI.WeekEndDate,
		FSI.ReceivedOn,
		FSI.BatchId,
		FSI.RecordStatus,
		PLI.RunDate
FROM	View_Integration_FSI FSI
		LEFT JOIN PaperlessInvoices PLI ON FSI.Company = PLI.Company AND FSI.CustomerNumber = PLI.Customer AND FSI.InvoiceNumber = PLI.InvoiceNumber
WHERE	FSI.Company = 'NDS'
		AND FSI.CustomerNumber IN ('227799','221007')
		AND FSI.WeekEndDate >= @WeekEndDate
		--AND FSI.ReceivedOn > '11/01/2017'
ORDER BY 1,4,3,2