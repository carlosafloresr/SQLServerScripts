USE [Integrations]
GO

DECLARE	@BatchId	Varchar(30) = '9FSI20190903_1524'

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
FROM	PRISQL004P.Integrations.dbo.FSI_ReceivedHeader
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
		,[CheckDigit])
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
		,0 AS [TipProcessed]
		,[ICB]
		,[CheckDigit]
FROM	PRISQL004P.Integrations.dbo.FSI_ReceivedDetails
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
		,[PrePayType])
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
FROM	PRISQL004P.Integrations.dbo.FSI_ReceivedSubDetails
WHERE	BatchId = @BatchId

UPDATE	FSI_ReceivedSubDetails
SET		PrePayType = 'A'
WHERE	BatchId = @BatchId
		AND RecordType = 'VND'
		AND RecordCode = '1038'

--SELECT	*
--FROM	View_Integration_FSI_Full
--WHERE	BatchId = @BatchId
--		AND RecordType = 'VND'
--		AND RecordCode = '1060'
--ORDER BY RecordCode

IF @@ERROR = 0
BEGIN
	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer) VALUES ('FSI', 'GLSO', @BatchId, 'SECSQL01T')
	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer) VALUES ('TIP', 'GLSO', @BatchId, 'SECSQL01T')
	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer) VALUES ('FSIG', 'GLSO', @BatchId, 'SECSQL01T')
	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer) VALUES ('FSIP', 'GLSO', @BatchId, 'SECSQL01T')
END

GO

/*
DELETE ReceivedIntegrations WHERE batchId = '9FSI20190903_1524'
DELETE FSI_ReceivedHeader WHERE batchId = '9FSI20190903_1524'
DELETE FSI_ReceivedDetails WHERE batchId = '9FSI20190903_1524'
DELETE FSI_ReceivedSubDetails WHERE batchId = '9FSI20190903_1524'

SELECT * FROM ReceivedIntegrations
TRUNCATE TABLE ReceivedIntegrations
*/