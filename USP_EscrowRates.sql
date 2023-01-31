--execute USP_EscrowRates 0, 'AISTE', 248, '0-00-2790', 'DDD', '3/22/2007', '4/22/2007', 5.95, 'CFLORES'

ALTER PROCEDURE USP_EscrowRates
	@EscrowRateId	Int,
	@CompanyId	Char(60), 
	@AccountIndex	Int, 
	@AccountNumber	Char(10), 
	@DriverClass	Char(30), 
	@IniDate	Smalldatetime, 
	@EndDate	Smalldatetime, 
	@InterestRate	Numeric(18,3), 
	@UserId		Varchar(25)
AS
IF @EscrowRateId = 0
BEGIN
	BEGIN TRANSACTION

	INSERT INTO EscrowRates
	       (CompanyId, 
		AccountIndex, 
		AccountNumber, 
		DriverClass, 
		IniDate, 
		EndDate, 
		InterestRate, 
		EnteredBy, 
		ChangedBy)
	VALUES (@CompanyId, 
		@AccountIndex, 
		@AccountNumber, 
		@DriverClass, 
		@IniDate, 
		@EndDate, 
		@InterestRate, 
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

	UPDATE	EscrowRates
	SET	IniDate		= @IniDate, 
		EndDate		= @EndDate, 
		InterestRate	= @InterestRate, 
		ChangedBy	= @UserId, 
		ChangedOn	= GETDATE()
	WHERE	EscrowRateId	= @EscrowRateId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @EscrowRateId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END
GO