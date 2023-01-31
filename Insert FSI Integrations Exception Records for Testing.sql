DECLARE	@Integration	Varchar(5) = 'FSI',
		@Company		Varchar(5),
		@BatchId		Varchar(25),
		@NewBatchId		Varchar(25),
		@CustomerNo		Varchar(20),
		@Counter		Int = 0,
		@Addition		Varchar(5) = '_99'

SELECT	TOP 1 
		@Company = Company, 
		@BatchId = RTRIM(BatchId)
FROM	FSI_ReceivedHeader
WHERE	BatchId NOT LIKE '%_SUM'
		AND Status = 2
ORDER BY ReceivedOn DESC

SET @NewBatchId = REPLACE(@BatchId, RIGHT(@BatchId, 4), '9999') 
PRINT 'New Batch Id: ' + @NewBatchId

DELETE	FSI_ReceivedHeader
WHERE	Company = @Company
		AND BatchId = @NewBatchId

DELETE	FSI_ReceivedDetails
WHERE	BatchId = @NewBatchId

DELETE	FSI_ReceivedSubDetails
WHERE	BatchId = @NewBatchId

DELETE	ReceivedIntegrations
WHERE	Integration = @Integration
		AND Company = @Company
		AND BatchId = @NewBatchId

DELETE	IntegrationExceptions
WHERE	Company = @Company
		AND BatchId = @NewBatchId

INSERT INTO FSI_ReceivedHeader
		(Company
		,BatchId
		,WeekEndDate
		,ReceivedOn
		,TotalTransactions
		,TotalSales
		,TotalVendorAccrual
		,TotalTruckAccrual
		,Status
		,Agent
		,Imaged)
SELECT	Company
		,@NewBatchId
		,WeekEndDate
		,ReceivedOn
		,TotalTransactions
		,TotalSales
		,TotalVendorAccrual
		,TotalTruckAccrual
		,1
		,Agent
		,Imaged
FROM	FSI_ReceivedHeader
WHERE	Company = @Company
		AND BatchId = @BatchId

DECLARE CustomerNumbers CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT CustomerNumber
FROM	FSI_ReceivedDetails
WHERE	BatchId = @BatchId
		AND InvoiceTotal > 0

OPEN CustomerNumbers 
FETCH FROM CustomerNumbers INTO @CustomerNo

WHILE @@FETCH_STATUS = 0 AND @Counter < 2
BEGIN
	SET @Counter = @Counter + 1

	INSERT INTO FSI_ReceivedDetails
			(BatchId
			,DetailId
			,VoucherNumber
			,InvoiceNumber
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
			,Intercompany
			,RecordStatus
			,Imaged
			,Printed
			,Emailed
			,BrokerageOrderId
			,Equipment)
	SELECT	@NewBatchId
			,DetailId
			,VoucherNumber
			,InvoiceNumber
			,RTRIM(CustomerNumber) + @Addition
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
			,Intercompany
			,0
			,Imaged
			,Printed
			,Emailed
			,BrokerageOrderId
			,Equipment
	FROM	FSI_ReceivedDetails
	WHERE	BatchId = @BatchId
			AND CustomerNumber = @CustomerNo

	IF @@ERROR = 0
	BEGIN
		INSERT INTO IntegrationExceptions
				([Integration]
				,[Company]
				,[BatchId]
				,[RecordId]
				,[Value]
				,[ValueType]
				,[Exception])
		SELECT	@Integration,
				@Company,
				@NewBatchId,
				FSI_ReceivedDetailId,
				RTRIM(CustomerNumber) + @Addition,
				'C',
				'The Customer Number [' + RTRIM(CustomerNumber) + @Addition + '] does not exists in Great Plains!'
		FROM	FSI_ReceivedDetails
		WHERE	BatchId = @NewBatchId
				AND CustomerNumber = @CustomerNo + @Addition

		INSERT INTO FSI_ReceivedSubDetails
				(BatchId
				,DetailId
				,RecordType
				,RecordCode
				,Reference
				,ChargeAmount1
				,ChargeAmount2
				,ReferenceCode
				,Verification
				,Processed
				,VndIntercompany
				,VendorDocument)
		SELECT	@NewBatchId
				,DetailId
				,RecordType
				,RecordCode
				,Reference
				,ChargeAmount1
				,ChargeAmount2
				,ReferenceCode
				,Verification
				,Processed
				,VndIntercompany
				,VendorDocument
		FROM	FSI_ReceivedSubDetails
		WHERE	BatchId = @BatchId
				AND DetailId IN (SELECT DetailId FROM FSI_ReceivedDetails WHERE BatchId = @BatchId AND CustomerNumber = @CustomerNo)
	END

	FETCH FROM CustomerNumbers INTO @CustomerNo
END

CLOSE CustomerNumbers
DEALLOCATE CustomerNumbers

INSERT INTO ReceivedIntegrations 
		(Integration, Company, BatchId, Status, GPServer)
VALUES
		(@Integration, @Company, @NewBatchId, 1, 'LENSASQL001T')

SELECT	*
FROM	FSI_ReceivedHeader
WHERE	Company = @Company
		AND BatchId = @NewBatchId

SELECT	*
FROM	FSI_ReceivedDetails
WHERE	BatchId = @NewBatchId

SELECT	*
FROM	FSI_ReceivedSubDetails
WHERE	BatchId = @NewBatchId

SELECT	*
FROM	IntegrationExceptions
WHERE	Company = @Company
		AND BatchId = @NewBatchId