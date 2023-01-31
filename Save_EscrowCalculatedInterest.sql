ALTER PROCEDURE Save_EscrowCalculatedInterest
	@CompanyId		Char(6), 
	@AccountIndex		Int, 
	@AccountNumber		Char(15),
	@DriverClass		Char(3),
	@VendorId		Char(10), 
	@Period			Char(6), 
	@DateIni		Smalldatetime, 
	@DateEnd		Smalldatetime, 
	@AmountInvested		Money, 
	@InterestRate		Numeric(18,3), 
	@InterestAmount		Money,
	@UserId			Varchar(25)
AS
BEGIN TRANSACTION

INSERT INTO EscrowInterest
       (CompanyId, 
	AccountIndex, 
	AccountNumber,
	DriverClass,
	VendorId, 
	Period, 
	DateIni, 
	DateEnd, 
	AmountInvested, 
	InterestRate, 
	InterestAmount,
	CreatedBy)
VALUES (@CompanyId, 
	@AccountIndex, 
	@AccountNumber, 
	@DriverClass,
	@VendorId, 
	@Period, 
	@DateIni, 
	@DateEnd, 
	@AmountInvested, 
	@InterestRate, 
	@InterestAmount,
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
GO