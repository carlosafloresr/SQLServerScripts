USE [Integrations]
GO

IF @@SERVERNAME <> 'PRISQL10P'
BEGIN
	DECLARE	@BatchId Varchar(20) = '9FSI20230122_1216'

	DELETE ReceivedIntegrations WHERE BatchId = @BatchId
	DELETE FSI_ReceivedHeader WHERE BatchId = @BatchId
	DELETE FSI_ReceivedDetails WHERE BatchId = @BatchId
	DELETE FSI_ReceivedSubDetails WHERE BatchId = @BatchId

	INSERT INTO [dbo].[FSI_ReceivedHeader]
			([Company]
			,[BatchId]
			,[WeekEndDate]
			,[ReceivedOn]
			,[TotalTransactions]
			,[TotalSales]
			,[TotalVendorAccrual]
			,[TotalTruckAccrual]
			,[Status]
			,[Agent]
			,[Imaged])
	SELECT	[Company]
			,[BatchId]
			,[WeekEndDate]
			,[ReceivedOn]
			,[TotalTransactions]
			,[TotalSales]
			,[TotalVendorAccrual]
			,[TotalTruckAccrual]
			,0 AS [Status]
			,[Agent]
			,[Imaged]
	FROM	PRISQL10P.Integrations.dbo.FSI_ReceivedHeader
	WHERE	BatchId = @BatchId

	INSERT INTO [dbo].[FSI_ReceivedDetails]
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
			,[Imaged]
			,[Printed]
			,[Emailed]
			,[BrokerageOrderId]
			,[Equipment]
			,[TipProcessed]
			,[ICB]
			,[CheckDigit]
			,[PrePayType])
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
			,0 AS [Processed]
			,[Intercompany]
			,[RecordStatus]
			,[Imaged]
			,[Printed]
			,[Emailed]
			,[BrokerageOrderId]
			,[Equipment]
			,[TipProcessed]
			,[ICB]
			,[CheckDigit]
			,[PrePayType]
	FROM	PRISQL10P.Integrations.dbo.FSI_ReceivedDetails
	WHERE	BatchId = @BatchId

	INSERT INTO [dbo].[FSI_ReceivedSubDetails]
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
			,[VendorDocument]
			,[VendorReference]
			,[PrePay]
			,[AccCode]
			,[ICB]
			,[CheckDigit]
			,[PrePayType]
			,[FileRowNumber]
			,[PerDiemType]
			,[DemurrageAdminFee])
	 SELECT	[BatchId]
			,[DetailId]
			,[RecordType]
			,[RecordCode]
			,[Reference]
			,[ChargeAmount1]
			,[ChargeAmount2]
			,[ReferenceCode]
			,[Verification]
			,0 AS [Processed]
			,[VndIntercompany]
			,[VendorDocument]
			,[VendorReference]
			,[PrePay]
			,[AccCode]
			,[ICB]
			,[CheckDigit]
			,[PrePayType]
			,[FileRowNumber]
			,[PerDiemType]
			,[DemurrageAdminFee]
	FROM	PRISQL10P.Integrations.dbo.FSI_ReceivedSubDetails
	WHERE	BatchId = @BatchId

	IF NOT EXISTS(SELECT Integration FROM Integrations.dbo.ReceivedIntegrations WHERE BatchId = @BatchId)
	BEGIN
		INSERT INTO ReceivedIntegrations (Integration, BatchId, Company, Status, GPServer)
		SELECT	Integration, BatchId, Company, 0, 'SECSQL01T'
		FROM	PRISQL10P.Integrations.dbo.ReceivedIntegrations 
		WHERE	BatchId = @BatchId

		SELECT	*
		FROM	ReceivedIntegrations
		WHERE	BatchId = @BatchId
	END
END
ELSE
	PRINT 'You can not run this in production ' + @@SERVERNAME