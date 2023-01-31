--SELECT * FROM View_Integration_FSI WHERE BatchId = '4FSI070908_09102007_1323'
ALTER PROCEDURE USP_FSI_Reports
	@BatchId	Char(25),
	@Company	Char(6)
AS
SELECT 	FD.BatchId,
	FD.CompaNy,
	FD.InvoiceNumber,
	FD.InvoiceDate,
	FD.CustomerNumber, 
	FD.InvoiceTotal,
	FD.ApplyTo,
	FS.ChargeAmount1,
	FD.TruckAccrualTotal,
	FD.BilltoRef,
	FD.Division
FROM 	View_Integration_FSI FD
	LEFT JOIN FSI_ReceivedSubDetails FS ON FD.BatchId = FS.BatchId AND FD.DetailId = FS.DetailId AND FS.RecordType = 'VND'
WHERE 	FD.BatchId = @BatchId AND
	FD.Company = @Company
GO

'4FSI070908_09102007_1323'

SELECT 	FD.BatchId,
	FD.CompaNy,
	FD.InvoiceNumber,
	FD.InvoiceDate,
	FD.CustomerNumber, 
	FD.InvoiceTotal,
	FD.ApplyTo,
	FS.ChargeAmount1,
	FD.TruckAccrualTotal,
	FD.BilltoRef,
	FD.Division
FROM 	View_Integration_FSI FD
	LEFT JOIN FSI_ReceivedSubDetails FS ON FD.BatchId = FS.BatchId AND FD.DetailId = FS.DetailId AND FS.RecordType = 'VND'
WHERE 	FD.BatchId = '4FSI070908_09102007_1323' AND
	FD.Company = 'AIS'