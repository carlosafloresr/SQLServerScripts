/*
EXECUTE	USP_Integration_FSI_Full 'GIS', '2FSI20170524_1642_SUM'
EXECUTE	USP_Integration_FSI_Full 'IMC', '1FSI20170524_1129'
*/
ALTER PROCEDURE USP_Integration_FSI_Full
	@Company	Varchar(5),
	@BatchId	Varchar(25),
	@Status		Smallint = 0
AS
IF @BatchId LIKE '%_SUM'
BEGIN
	PRINT 'Summary Batch'

	SELECT	FSI_ReceivedDetailId,
			InvoiceNumber,
			ROW_NUMBER() OVER(ORDER BY InvoiceNumber) AS DetailId
	INTO	##tmpDetailIds
	FROM	View_Integration_FSI_Full 
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND Intercompany = 0
			AND ((@BatchId LIKE '%_SUM' AND InvoiceNumber LIKE 'S-%')
			OR @BatchId NOT LIKE '%_SUM')
	ORDER BY FSI_ReceivedDetailId

	SELECT	FSI_ReceivedDetailId AS ValueIni,
			ValueEnd = ISNULL((SELECT DET2.FSI_ReceivedDetailId - 1 FROM ##tmpDetailIds DET2 WHERE DET2.DetailId = (DET1.DetailId + 1)), 99999999),
			DetailId,
			InvoiceNumber
	INTO	##tmpDetailIds2
	FROM	##tmpDetailIds DET1

	SELECT	FSI_ReceivedHeaderId
			,Company
			,WeekEndDate
			,ReceivedOn
			,TotalTransactions
			,TotalSales
			,TotalVendorAccrual
			,TotalTruckAccrual
			,FSI_ReceivedDetailId
			,BatchId
			,TMPD.DetailId
			,VoucherNumber
			,VFSI.InvoiceNumber
			,Original_InvoiceNumber
			,CustomerNumber
			,ApplyTo
			,BillToRef
			,InvoiceDate
			,DeliveryDate
			,DueDate
			,AccessorialTotal
			,VendorPayTotal
			,FuelSurcharge
			,FuelRebateTotal
			,InvoiceTotal
			,DocumentType
			,ShipperName
			,ShipperCity
			,ConsigneeName
			,ConsigneeCity
			,BrokeredSale
			,TruckAccrualTotal
			,CompanyTruckAccrual
			,CompanyTruckDivision
			,CompanyTruckFuelRebate
			,CompanyDriverPay
			,InvoiceType
			,Division
			,RatingTable
			,Verification
			,Processed
			,Status
			,CASE WHEN VFSI.InvoiceNumber = TMPD.InvoiceNumber THEN 'NON' ELSE 'DET' END RecordType
			,RecordCode
			,Reference
			,ChargeAmount1
			,ChargeAmount2
			,ReferenceCode
			,SubVerification
			,SubProcessed
			,Intercompany
			,VndIntercompany
			,GPBatchId
			,VendorDocument
			,VendorReference
			,Agent
			,RecordStatus
			,Imaged
			,Printed
			,Emailed
			,Equipment
			,PrePay
			,AccCode
			,IsSummary
			,FSI_ReceivedSubDetailId
	FROM	View_Integration_FSI_Full VFSI
			LEFT JOIN ##tmpDetailIds2 TMPD ON VFSI.FSI_ReceivedDetailId BETWEEN TMPD.ValueIni AND TMPD.ValueEnd
	WHERE	VFSI.Company = @Company
			AND VFSI.BatchId = @BatchId
			AND VFSI.Intercompany = 0
	ORDER BY FSI_ReceivedDetailId, TMPD.DetailId, RecordType

	DROP TABLE ##tmpDetailIds
	DROP TABLE ##tmpDetailIds2
END
ELSE
BEGIN
	PRINT 'Regular Batch'

	SELECT	FSI_ReceivedHeaderId
			,Company
			,WeekEndDate
			,ReceivedOn
			,TotalTransactions
			,TotalSales
			,TotalVendorAccrual
			,TotalTruckAccrual
			,FSI_ReceivedDetailId
			,BatchId
			,DetailId
			,VoucherNumber
			,InvoiceNumber
			,Original_InvoiceNumber
			,CustomerNumber
			,ApplyTo
			,BillToRef
			,InvoiceDate
			,DeliveryDate
			,DueDate
			,AccessorialTotal
			,VendorPayTotal
			,FuelSurcharge
			,FuelRebateTotal
			,InvoiceTotal
			,DocumentType
			,ShipperName
			,ShipperCity
			,ConsigneeName
			,ConsigneeCity
			,BrokeredSale
			,TruckAccrualTotal
			,CompanyTruckAccrual
			,CompanyTruckDivision
			,CompanyTruckFuelRebate
			,CompanyDriverPay
			,InvoiceType
			,Division
			,RatingTable
			,Verification
			,Processed
			,Status
			,RecordType
			,RecordCode
			,Reference
			,ChargeAmount1
			,ChargeAmount2
			,ReferenceCode
			,SubVerification
			,SubProcessed
			,Intercompany
			,VndIntercompany
			,GPBatchId
			,VendorDocument
			,VendorReference
			,Agent
			,RecordStatus
			,Imaged
			,Printed
			,Emailed
			,Equipment
			,PrePay
			,AccCode
			,IsSummary
			,FSI_ReceivedSubDetailId
	FROM	View_Integration_FSI_Full VFSI
	WHERE	VFSI.Company = @Company
			AND VFSI.BatchId = @BatchId
			AND VFSI.Intercompany = 0
	ORDER BY DetailId, RecordType
END