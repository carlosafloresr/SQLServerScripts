USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_SettlementDetails]    Script Date: 3/31/2022 8:19:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_SettlementDetails]
	@SettlementDetailId		int,
	@Fk_SettlementId		int,
	@ProNumber				varchar(12),
	@TransactionDate		datetime,
	@Description			varchar(11),
	@Origin					varchar(20),
	@Destination			varchar(15),
	@PayType				char(1),
	@Miles					int,
	@FuelCreditPercentage	numeric(10,2),
	@FuelCredit				numeric(10,2),
	@MovePay				numeric(10,2),
	@TotalPaid				numeric(10,2),
	@AmountHeld				numeric(10,2),
	@HeldReason				varchar(25)
AS
BEGIN TRANSACTION

IF @SettlementDetailId IS Null AND NOT EXISTS(SELECT SettlementDetailId FROM SettlementDetails WHERE ProNumber = @ProNumber AND TransactionDate = @TransactionDate AND Description = @Description AND Origin = @Origin AND Destination = @Description AND Miles = @Miles)
BEGIN
	INSERT INTO SettlementDetails
           (Fk_SettlementId
           ,ProNumber
           ,TransactionDate
           ,Description
           ,Origin
           ,Destination
           ,PayType
           ,Miles
           ,FuelCreditPercentage
           ,FuelCredit
           ,MovePay
           ,TotalPaid
           ,AmountHeld
           ,HeldReason)
     VALUES
           (@Fk_SettlementId
           ,@ProNumber
           ,@TransactionDate
           ,@Description
           ,@Origin
           ,@Destination
           ,@PayType
           ,@Miles
           ,@FuelCreditPercentage
           ,@FuelCredit
           ,@MovePay
           ,@TotalPaid
           ,@AmountHeld
           ,@HeldReason)
END
ELSE
BEGIN
	IF @SettlementDetailId IS NOT Null
	BEGIN
		UPDATE	SettlementDetails
		SET		Fk_SettlementId = @Fk_SettlementId
			   ,ProNumber = @ProNumber
			   ,TransactionDate = @TransactionDate
			   ,Description = @Description
			   ,Origin = @Origin
			   ,Destination = @Destination
			   ,PayType = @PayType
			   ,Miles = @Miles
			   ,FuelCreditPercentage = @FuelCreditPercentage
			   ,FuelCredit = @FuelCredit
			   ,MovePay = @MovePay
			   ,TotalPaid = @TotalPaid
			   ,AmountHeld = @AmountHeld
			   ,HeldReason = @HeldReason
		WHERE	SettlementDetailId = @SettlementDetailId
	END
END

IF @@ERROR = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION