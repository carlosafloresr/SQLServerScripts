ALTER PROCEDURE USP_Escrow_WeeklyBalance
	@CompanyId	Char(6),
	@AccountIndex	Int,
	@AccountNumber	Char(15), 
	@VendorId	Char(10),
	@DriverClass	Char(3),
	@BegDate	Smalldatetime,
	@EndDate	Smalldatetime,
	@Period		Char(6),
	@UserId		Varchar(25)
AS
DECLARE	@Balance	Money,
	@Counter	Int,
	@TotDays	Int,
	@Current	Smalldatetime,
	@NewDate	Smalldatetime,
	@Rate		Money,
	@Interest	Money,
	@CompanyName	Varchar(50)

SET	@Counter	= 1
SET	@TotDays	= DATEDIFF(wk, @BegDate, @EndDate + 1)
SET 	@Current 	= @BegDate - 1
SET	@CompanyName	= (SELECT Name FROM Dynamics.Dbo.View_Companies WHERE CompanyID = @CompanyId)

CREATE TABLE #tmpData (
	DateIni		Smalldatetime,
	DateEnd		Smalldatetime,
	Balance		Money,
	IntRate		Money,
	Interest	Money)

WHILE @Counter <= @TotDays
BEGIN
	SET @Counter 	= @Counter + 1
	SET @NewDate	= @Current + 1
	SET @Current 	= @NewDate + 6
	SET @Balance	= (	SELECT 	ISNULL(SUM(CASE WHEN Source = 'AR' THEN Amount * -1
					ELSE Amount END), 0.00)
				FROM 	EscrowTransactions
				WHERE	Fk_EscrowModuleId IN (1,2,5) AND 
					CompanyId = @CompanyId AND 
					AccountNumber = @AccountNumber AND 
					VendorId = @VendorId AND 
					TransactionDate BETWEEN @BegDate AND @Current)
	SET @Rate	= (	SELECT	ISNULL(InterestRate, 0.00)
				FROM	EscrowRates
				WHERE	CompanyId = @CompanyId AND 
					DriverClass = @DriverClass AND 
					AccountNumber = @AccountNumber AND 
					IniDate <= @NewDate AND 
					EndDate >= @Current)
	SET @Interest	= ROUND((@Balance * (@Rate / 100.000)) * (7.000 / 365.000), 2)

	INSERT INTO #tmpData (DateIni, DateEnd, Balance, IntRate, Interest) VALUES (@NewDate, @Current, @Balance, @Rate, @Interest)
END

DELETE FROM EscrowInterest 
WHERE 	CompanyId = @CompanyId AND 
	AccountIndex = @AccountIndex AND 
	DriverClass = @DriverClass AND
	Period = @Period AND
	VendorId = @VendorId

INSERT INTO EscrowInterest
SELECT	@CompanyId,
	@AccountIndex,
	@AccountNumber,
	@DriverClass,
	@VendorId,
	@Period,
	DateIni,
	DateEnd,
	Balance,
	IntRate,
	Interest,
	0,
	GETDATE(),
	@UserId
FROM 	#tmpData
GO

EXECUTE USP_Escrow_WeeklyBalance 'AISTE', 248, '0-00-2790', 'A0061', 'DDD', '07/01/2007', '10/06/2007', '200703', 'CFLORES'
select * from EscrowRates

print round(4.5678, 2)