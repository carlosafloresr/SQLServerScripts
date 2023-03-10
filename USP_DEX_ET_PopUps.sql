USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_DEX_ET_PopUps]    Script Date: 2/2/2017 2:16:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_DEX_ET_PopUps]
		@DocNumber				Varchar(30), 
		@CompanyId				Varchar(5), 
		@Fk_EscrowModuleId		Int,
		@AccountNumber			Varchar(15),
		@AccountType			Int,
		@VendorId				Varchar(10) = Null, 
		@DriverId				Varchar(10) = Null, 
		@Division				Varchar(3) = Null, 
		@Amount					Money, 
		@ClaimNumber			Varchar(15) = Null, 
		@DriverClass			Int = Null, 
		@AccidentType			Int = Null, 
		@Comments				Varchar(1000) = Null,
		@UserId					Varchar(25),
		@DMSubmitted			Int = Null,
		@Status					Int = Null,
		@Source					Char(2),
		@TransactionDate		DateTime = Null,
		@DEX_ET_PopUpsId		Int = Null,
		@ItemNumber				Int = Null,
		@ProNumber				Varchar(50) = Null,
		@PostingDate			Datetime = Null,
		@DeductionPlan			Varchar(5) = Null,
		@OtherStatus			Varchar(20) = Null,
		@BatchId				Varchar(25) = Null,
		@InvoiceNumber			Varchar(30) = Null,
		@VoucherNumber			Varchar(22) = Null,
		@ETADate				Date = Null,
		@RepairDate				Date = Null,
		@UnitNumber				Varchar(90) = Null
AS
IF @Fk_EscrowModuleId = 5 AND @Status IN (1,2) AND @DeductionPlan IS Null
BEGIN
	SET @DeductionPlan = dbo.PADL(MONTH(GETDATE() + 30), 2, '0') + '/' + CAST(YEAR(GETDATE() + 30) AS Char(4))
END

IF @TransactionDate < '1/1/1990'
	SET @TransactionDate = CAST(CONVERT(Char(10), GETDATE(), 101) AS Datetime)
	
IF @PostingDate < '1/1/1990'
	SET @PostingDate = CAST(CONVERT(Char(10), GETDATE(), 101) AS Datetime)

IF @DEX_ET_PopUpsId	IS Null
BEGIN
	IF @UserId = 'ILSLISTENER'
	BEGIN
		SET	@DEX_ET_PopUpsId = (	SELECT	DEX_ET_PopUpsId 
									FROM 	DEX_ET_PopUps
									WHERE 	DocNumber 			= @DocNumber AND
											CompanyId			= @CompanyId AND
											Fk_EscrowModuleId	= @Fk_EscrowModuleId AND
											VendorId			= @VendorId AND
											TransactionDate		= @TransactionDate AND
											Amount				= @Amount)
	END
END

IF @DEX_ET_PopUpsId IS Null OR NOT EXISTS(SELECT TOP 1 DEX_ET_PopUpsId FROM DEX_ET_PopUps WHERE DEX_ET_PopUpsId = @DEX_ET_PopUpsId)
BEGIN
	BEGIN TRANSACTION

	INSERT INTO DEX_ET_PopUps 
	       (Source,
			DocNumber,
			VoucherNumber,
			CompanyId, 
			Fk_EscrowModuleId,
			ItemNumber, 
			AccountNumber,
			AccountType,
			VendorId, 
			DriverId, 
			Division, 
			Amount, 
			ClaimNumber, 
			DriverClass, 
	        AccidentType,
			ProNumber,
			Comments,
			DMSubmitted,
			Status,
			DeductionPlan,
			TransactionDate,
			PostingDate,
			BatchId,
			InvoiceNumber,
			ETADate,
			RepairDate,
			UnitNumber,
			EnteredBy, 
			ChangedBy)
	VALUES (@Source,
			@DocNumber, 
			@VoucherNumber,
			@CompanyId, 
			@Fk_EscrowModuleId,
			@ItemNumber,
			@AccountNumber,
			@AccountType,
			@VendorId, 
			@DriverId, 
			CASE WHEN @BatchId LIKE 'CU%' AND @Division IS NULL THEN 'DM' ELSE @Division END, 
			@Amount, 
			@ClaimNumber, 
			@DriverClass, 
	        @AccidentType,
			@ProNumber,
			@Comments,
			@DMSubmitted,
			@Status,
			@DeductionPlan,
			@TransactionDate,
			@PostingDate,
			@BatchId,
			@InvoiceNumber,
			@ETADate,
			@RepairDate,
			@UnitNumber,
			@UserId, 
			@UserId)

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @@IDENTITY
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END
ELSE
BEGIN
	BEGIN TRANSACTION

	IF @DeductionPlan IS Null
	BEGIN
		SET @DeductionPlan = (SELECT DeductionPlan FROM DEX_ET_PopUps WHERE DEX_ET_PopUpsId = @DEX_ET_PopUpsId)
	END

	UPDATE 	DEX_ET_PopUps 
	SET		VendorId			= @VendorId, 
			DriverId			= @DriverId, 
			Division			= @Division,
			VoucherNumber		= @VoucherNumber,
			Amount				= @Amount,
			Fk_EscrowModuleId	= @Fk_EscrowModuleId,
			ClaimNumber			= @ClaimNumber, 
			DriverClass			= @DriverClass,
			AccountNumber		= @AccountNumber,
			AccidentType		= @AccidentType,
			ProNumber			= @ProNumber,
			Comments			= @Comments,
			DMSubmitted			= @DMSubmitted,
			Status				= @Status,
			DeductionPlan		= @DeductionPlan,
			TransactionDate		= @TransactionDate,
			PostingDate			= CASE WHEN PostingDate IS Null THEN @PostingDate ELSE PostingDate END,
			InvoiceNumber		= @InvoiceNumber,
			ETADate				= @ETADate,
			RepairDate			= @RepairDate,
			UnitNumber			= @UnitNumber,
			ChangedBy			= @UserId, 
			ChangedOn			= GETDATE()
	WHERE	DEX_ET_PopUpsId		= @DEX_ET_PopUpsId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @DEX_ET_PopUpsId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END
