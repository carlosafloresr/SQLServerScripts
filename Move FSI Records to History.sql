DECLARE @LastDate	Date = '06/30/2019',
		@IniDate	Date = '01/01/2009',
		@EndDate	Date = '06/30/2018',
		@Action		Char(1) = 'D'

IF @Action = 'I'
BEGIN
	--INSERT RECORDS IN HISTORICAL TABLES
	INSERT INTO FSI_ReceivedSubDetails_History
			([BatchId]
			,[DetailId]
			,[RecordType]
			,[RecordCode]
			,[Reference]
			,[ChargeAmount1]
			,[ChargeAmount2]
			,[ReferenceCode]
			,[Verification]
			,[Processed]
			,[VndIntercompany]
			,[VendorReference]
			,[PrePay]
			,[AccCode])
	SELECT	[BatchId]
			,[DetailId]
			,[RecordType]
			,[RecordCode]
			,[Reference]
			,[ChargeAmount1]
			,[ChargeAmount2]
			,[ReferenceCode]
			,[Verification]
			,[Processed]
			,[VndIntercompany]
			,[VendorReference]
			,[PrePay]
			,[AccCode]
	FROM	FSI_ReceivedSubDetails
	WHERE	BatchId + DetailId IN (SELECT BatchId + DetailId FROM FSI_ReceivedDetails WHERE BatchId IN (SELECT BatchId FROM FSI_ReceivedHeader WHERE ReceivedOn BETWEEN @IniDate AND @EndDate))
			AND BatchId + DetailId NOT IN (SELECT BatchId + DetailId FROM FSI_ReceivedSubDetails_History)

	INSERT INTO FSI_ReceivedHeader_History
			([Company]
			,[BatchId]
			,[WeekEndDate]
			,[ReceivedOn]
			,[TotalTransactions]
			,[TotalSales]
			,[TotalVendorAccrual]
			,[TotalTruckAccrual]
			,[Status])
	SELECT	[Company]
			,[BatchId]
			,[WeekEndDate]
			,[ReceivedOn]
			,[TotalTransactions]
			,[TotalSales]
			,[TotalVendorAccrual]
			,[TotalTruckAccrual]
			,[Status]
	FROM	FSI_ReceivedHeader
	WHERE	ReceivedOn < @LastDate

	INSERT INTO FSI_ReceivedDetails_History
			([BatchId]
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
			,[Processed]
			,[Intercompany]
			,[RecordStatus]
			,[TipProcessed])
	SELECT	[BatchId]
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
			,[Processed]
			,[Intercompany]
			,[RecordStatus]
			,[TipProcessed]
	FROM	FSI_ReceivedDetails
	WHERE	BatchId IN (SELECT BatchId FROM FSI_ReceivedHeader WHERE ReceivedOn < @LastDate)
END

IF @@ERROR = 0
BEGIN
	-- DELETE COPIED RECORDS FROM CURRENT TABLES
	DELETE	FSI_ReceivedSubDetails
	WHERE	BatchId + DetailId IN (SELECT BatchId + DetailId FROM FSI_ReceivedDetails WHERE BatchId IN (SELECT BatchId FROM FSI_ReceivedHeader WHERE ReceivedOn < @LastDate))

	DELETE	FSI_ReceivedDetails
	WHERE	BatchId IN (SELECT BatchId FROM FSI_ReceivedHeader WHERE ReceivedOn < @LastDate)

	DELETE	FSI_ReceivedHeader
	WHERE	ReceivedOn < @LastDate
END