DECLARE	@FromBatchId	Varchar(25) = '22FSI20180720_1426',
		@ToBatchId		Varchar(25) = '22FSI20180720_1420',
		@Company		Varchar(5)

SET @Company = (SELECT Company FROM FSI_ReceivedHeader WHERE BatchId = @FromBatchId)

IF @Company IS NOT Null
BEGIN
	DELETE ReceivedIntegrations WHERE Company = @Company AND BatchId = @ToBatchId AND Integration = 'FSI'
	DELETE FSI_ReceivedHeader WHERE Company = @Company AND BatchId = @ToBatchId
	DELETE FSI_ReceivedDetails WHERE BatchId = @ToBatchId

	INSERT INTO FSI_ReceivedHeader
	SELECT	[Company]
			,@ToBatchId AS [BatchId]
			,[WeekEndDate]
			,[ReceivedOn]
			,[TotalTransactions]
			,[TotalSales]
			,[TotalVendorAccrual]
			,[TotalTruckAccrual]
			,0 AS [Status]
			,[Agent]
			,[Imaged]
	FROM	FSI_ReceivedHeader
	WHERE	BatchId IN (@FromBatchId)

	INSERT INTO FSI_ReceivedDetails
	SELECT	@ToBatchId AS [BatchId]
			,[DetailId]
			,[VoucherNumber]
			,[InvoiceNumber]
			,[CustomerNumber]
			,[ApplyTo]
			,[BillToRef]
			,[InvoiceDate]
			,[DeliveryDate]
			,[DueDate]
			,[AccessorialTotal]
			,[VendorPayTotal]
			,[FuelSurcharge]
			,[FuelRebateTotal]
			,[InvoiceTotal]
			,[DocumentType]
			,[ShipperName]
			,[ShipperCity]
			,[ConsigneeName]
			,[ConsigneeCity]
			,[BrokeredSale]
			,[TruckAccrualTotal]
			,[CompanyTruckAccrual]
			,[CompanyTruckDivision]
			,[CompanyTruckFuelRebate]
			,[CompanyDriverPay]
			,[InvoiceType]
			,[Division]
			,[RatingTable]
			,[Verification]
			,0 AS [Processed]
			,[Intercompany]
			,[RecordStatus]
			,[Imaged]
			,[Printed]
			,[Emailed]
			,[BrokerageOrderId]
			,[Equipment]
			,[TipProcessed]
	FROM	FSI_ReceivedDetails
	WHERE	BatchId IN (@FromBatchId)
			--AND InvoiceNumber IN ()

	--INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, [Status], GPServer) VALUES ('FSIG', @Company, @ToBatchId, 0, 'SECSQL01T')
END