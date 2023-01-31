ALTER PROCEDURE USP_EscrowTransactions
	@VoucherNumber		Varchar(22), 
	@CompanyId		Char(6), 
	@Fk_EscrowModuleId	Int, 
	@AccountNumber		Char(10),
	@AccountType		Int,
	@VendorId		Char(10) = Null, 
	@DriverId		Char(10) = Null, 
	@Division		Char(10) = Null, 
	@Amount			Money, 
	@ClaimNumber		Varchar(25) = Null, 
	@DriverClass		Char(1) = Null, 
        @AccidentType		Char(2) = Null, 
	@Comments		Varchar(1000) = Null,
	@UserId			Varchar(25)
AS
DECLARE @EscrowTransactionId	Int
SET	@EscrowTransactionId	= (SELECT EscrowTransactionId 
					FROM 	EscrowTransactions
					WHERE 	VoucherNumber 		= @VoucherNumber AND
						CompanyId		= @CompanyId AND
						Fk_EscrowModuleId	= @Fk_EscrowModuleId AND
						AccountNumber		= @AccountNumber AND
						AccountType		= @AccountType)
IF @EscrowTransactionId IS Null
BEGIN
	BEGIN TRANSACTION

	INSERT INTO EscrowTransactions 
	       (VoucherNumber, 
		CompanyId, 
		Fk_EscrowModuleId, 
		AccountNumber,
		AccountType,
		VendorId, 
		DriverId, 
		Division, 
		Amount, 
		ClaimNumber, 
		DriverClass, 
	        AccidentType, 
		Comments, 
		EnteredBy, 
		ChangedBy)
	VALUES (@VoucherNumber, 
		@CompanyId, 
		@Fk_EscrowModuleId, 
		@AccountNumber,
		@AccountType,
		@VendorId, 
		@DriverId, 
		@Division, 
		@Amount, 
		@ClaimNumber, 
		@DriverClass, 
	        @AccidentType, 
		@Comments, 
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

	UPDATE 	EscrowTransactions 
	SET	VoucherNumber		= @VoucherNumber, 
		CompanyId		= @CompanyId, 
		Fk_EscrowModuleId	= @Fk_EscrowModuleId, 
		AccountNumber		= @AccountNumber, 
		VendorId		= @VendorId, 
		DriverId		= @DriverId, 
		Division		= @Division, 
		Amount			= @Amount, 
		ClaimNumber		= @ClaimNumber, 
		DriverClass		= @DriverClass, 
	        AccidentType		= @AccidentType, 
		Comments		= @Comments, 
		ChangedBy		= @UserId, 
		ChangedOn		= GETDATE()
	WHERE	EscrowTransactionId	= @EscrowTransactionId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @EscrowTransactionId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END
GO