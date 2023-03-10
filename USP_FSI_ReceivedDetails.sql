USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_ReceivedDetails]    Script Date: 1/12/2022 9:55:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_FSI_ReceivedDetails]
		@BatchId				varchar(25),
		@DetailId				varchar(10),
		@VoucherNumber			varchar(30),
		@InvoiceNumber			varchar(30),
		@CustomerNumber			varchar(10),
		@ApplyTo				varchar(30),
		@BillToRef				varchar(50),
		@InvoiceDate			datetime,
		@DeliveryDate			datetime,
		@DueDate				datetime,
		@AccessorialTotal		money,
		@VendorPayTotal			money,
		@FuelSurcharge			money,
		@FuelRebateTotal		money,
		@InvoiceTotal			money,
		@DocumentType			char(1),
		@ShipperName			varchar(30),
		@ShipperCity			varchar(25),
		@ConsigneeName			varchar(30),
		@ConsigneeCity			varchar(100),
		@BrokeredSale			bit,
		@TruckAccrualTotal		money,
		@CompanyTruckAccrual	money,
		@CompanyTruckDivision	char(2),
		@CompanyTruckFuelRebate	money,
		@CompanyDriverPay		money,
		@InvoiceType			char(1),
		@Division				char(2),
		@RatingTable			char(5),
		@Verification			varchar(50),
		@Processed				bit = 0,
		@Intercompany			bit = 0,
		@RecordStatus			smallint,
		@Imaged					bit = 0,
		@Printed				bit = 0,
		@Emailed				bit = 0,
		@BrokerageOrderId		varchar(10) = Null,
		@ICB					bit = 0,
		@PrePayType				Char(1) = NULL,
		@WorkOrder				Int = Null
AS
IF LEN(RTRIM(@InvoiceNumber)) > 17
BEGIN
	SET @InvoiceNumber	= LEFT(REPLACE(REPLACE(REPLACE(@InvoiceNumber, 'DRAYAGE', 'DRAY'), ' ', ''), ',', ''), 17)
	SET @VoucherNumber	= @InvoiceNumber
	SET @ApplyTo		= @InvoiceNumber
END

IF NOT EXISTS(SELECT TOP 1 BatchId FROM FSI_ReceivedDetails WHERE BatchId = @BatchId AND InvoiceNumber = @InvoiceNumber AND DetailId = @DetailId)
BEGIN
	BEGIN TRANSACTION

	IF @PrePayType IS NOT Null
	BEGIN
		IF @PrePayType NOT IN ('A','P')
			SET @PrePayType = Null
	END

	INSERT INTO dbo.FSI_ReceivedDetails
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
			   ,ICB
			   ,PrePayType
			   ,WorkOrder)
		 VALUES
			   (@BatchId
			   ,@DetailId
			   ,@VoucherNumber
			   ,@InvoiceNumber
			   ,@CustomerNumber
			   ,@ApplyTo
			   ,@BillToRef
			   ,@InvoiceDate
			   ,@DeliveryDate
			   ,@DueDate
			   ,@AccessorialTotal
			   ,@VendorPayTotal
			   ,@FuelSurcharge
			   ,@FuelRebateTotal
			   ,@InvoiceTotal
			   ,@DocumentType
			   ,@ShipperName
			   ,@ShipperCity
			   ,@ConsigneeName
			   ,@ConsigneeCity
			   ,@BrokeredSale
			   ,@TruckAccrualTotal
			   ,@CompanyTruckAccrual
			   ,@CompanyTruckDivision
			   ,@CompanyTruckFuelRebate
			   ,@CompanyDriverPay
			   ,@InvoiceType
			   ,@Division
			   ,@RatingTable
			   ,@Verification
			   ,@Processed
			   ,@Intercompany
			   ,@RecordStatus
			   ,@Imaged
			   ,@Printed
			   ,@Emailed
			   ,@BrokerageOrderId
			   ,@ICB
			   ,@PrePayType
			   ,@WorkOrder)

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @@IDENTITY
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN 0
	END
END