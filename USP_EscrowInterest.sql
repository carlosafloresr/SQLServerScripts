CREATE PROCEDURE USP_EscrowInterest
	@EscrowInterestId	Int, 
	@CompanyId		Char(6), 
	@AccountIndex		Int, 
	@AccountNumber		Char(10), 
	@VendorId		Char(10), 
	@Fk_EscrowRateId	Int, 
	@DateIni		Smalldatetime, 
	@DateEnd		Smalldatetime, 
	@AmountInvested		Money, 
	@InterestRate		Numeric(18,3), 
	@InterestAmount		Money, 
        @CreatedOn		Smalldatetime
AS
IF @EscrowInterestId = 0
BEGIN
	BEGIN TRANSACTION

	INSERT INTO EscrowInterest
	       (CompanyId, 
		AccountIndex, 
		AccountNumber, 
		VendorId, 
		Fk_EscrowRateId, 
		DateIni, 
		DateEnd, 
		AmountInvested, 
		InterestRate, 
		InterestAmount)
	VALUES (@CompanyId, 
		@AccountIndex, 
		@AccountNumber, 
		@VendorId, 
		@Fk_EscrowRateId, 
		@DateIni, 
		@DateEnd, 
		@AmountInvested, 
		@InterestRate, 
		@InterestAmount)

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

	UPDATE 	EscrowInterest
	SET	Fk_EscrowRateId		= @Fk_EscrowRateId, 
		DateIni			= @DateIni, 
		DateEnd			= @DateEnd, 
		AmountInvested		= @AmountInvested, 
		InterestRate		= @InterestRate, 
		InterestAmount		= @InterestAmount
	WHERE	EscrowInterestId	= @EscrowInterestId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @EscrowInterestId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END