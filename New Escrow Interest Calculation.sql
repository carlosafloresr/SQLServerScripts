/*
EXECUTE USP_EscrowInterest_Calculation 'NDS',64,'00-00-2790','DRV','09/30/2018','12/31/2018','201804','CFLORES'
SELECT * FROM nds.dbo.GL00105 WHERE ACTNUMST = '00-00-2790'
*/
ALTER PROCEDURE USP_EscrowInterest_Calculation
		@CompanyId		Varchar(6),
		@AccountIndex	Int,
		@AccountNumber	Varchar(15), 
		@DriverClass	Char(3),
		@BegDate		Smalldatetime,
		@EndDate		Smalldatetime,
		@Period			Char(6),
		@UserId			Varchar(25)
AS
SET NOCOUNT ON

DECLARE	@Balance	Money,
		@Counter	Int,
		@TotDays	Int,
		@Current	Smalldatetime,
		@NewDate	Smalldatetime,
		@Rate		Money,
		@Interest	Money,
		@Query		Varchar(Max)

SET	@Counter	= 1
SET	@TotDays	= DATEDIFF(wk, @BegDate, @EndDate + 1)
SET @Current 	= @BegDate - 1

DECLARE @tblVendors TABLE (
		VendorId		Varchar(15))

DECLARE	@tblRates TABLE (
	DateIni		Date,
	DateEnd		Date,
	IntRate		Money)

DECLARE @tblData TABLE (
	DateIni		Smalldatetime,
	DateEnd		Smalldatetime,
	Balance		Money,
	IntRate		Money,
	Interest	Money)

--SET @Query = N'SELECT VENDORID FROM ' + RTRIM(@CompanyId) + '.dbo.PM00200 WHERE VNDCLSID = ''' + RTRIM(@DriverClass) + ''''

SET	@Query	= 'SELECT PM.VendorId FROM ' + @CompanyId + 
	'.dbo.PM00200 PM INNER JOIN GPCustom.dbo.View_EscrowBalances_ForInterest EI ON PM.VendorId = EI.VendorId AND EI.AccountNumber = ''' +	@AccountNumber + ''' AND ' +
	'EI.CompanyId = ''' + @CompanyId + ''' WHERE VendStts = 1 AND VndClsId = ''' + @DriverClass + ''' ORDER BY PM.VendorId'

INSERT INTO @tblVendors
EXECUTE(@Query)

WHILE @Counter <= @TotDays
BEGIN
	SET @Counter	= @Counter + 1
	SET @NewDate	= @Current + 1
	SET @Current 	= @NewDate + 6
	SET @Rate		= (	SELECT	TOP 1 ISNULL(InterestRate, 0.00)
						FROM	EscrowRates
						WHERE	CompanyId = @CompanyId AND 
								AccountNumber = @AccountNumber AND 
								DriverClass = @DriverClass AND 
								IniDate >= @NewDate AND 
								EndDate <= @Current
						ORDER BY IniDate DESC)

	INSERT INTO @tblRates (DateIni, DateEnd, IntRate) VALUES (@NewDate, @Current, @Rate)
END

DELETE FROM EscrowInterest 
WHERE 	CompanyId = @CompanyId AND 
		AccountIndex = @AccountIndex AND 
		DriverClass = @DriverClass AND
		Period = @Period

INSERT INTO EscrowInterest (CompanyId, AccountIndex, AccountNumber, DriverClass, VendorId, Period, DateIni, DateEnd, AmountInvested, InterestRate, InterestAmount, Approved, CreatedOn, CreatedBy, BatchId)
SELECT	DISTINCT @CompanyId,
		@AccountIndex,
		@AccountNumber,
		@DriverClass,
		VendorId,
		@Period,
		DateIni,
		DateEnd,
		Balance,
		IntRate,
		ISNULL(CAST(ROUND(Balance * (IntRate / 100.000) * (7.000 / 365.000), 2) AS Numeric(10,2)), 0.0),
		0,
		GETDATE(),
		@UserId,
		'EI' + RTRIM(REPLACE(SUBSTRING(@AccountNumber, 3, 7), '-', '')) + RTRIM(@DriverClass) + SUBSTRING(@Period, 3, 4)
FROM	(
		SELECT 	TR.VendorId,
				RT.DateIni,
				RT.DateEnd,
				RT.IntRate,
				Balance = ISNULL((SELECT SUM(CASE WHEN VT.Source = 'AR' THEN VT.Amount * -1 ELSE VT.Amount END) FROM View_EscrowTransactions VT WHERE VT.CompanyId = TR.CompanyId AND VT.VendorId = TR.VendorId AND VT.AccountNumber = TR.AccountNumber AND VT.TransactionDate BETWEEN '01/01/2000' AND RT.DateEnd AND VT.Fk_EscrowModuleId IN (1,2,5)),0)
		FROM 	View_EscrowTransactions TR
				INNER JOIN @tblVendors VD ON TR.VendorId = VD.VendorId
				INNER JOIN @tblRates RT ON TR.TransactionDate BETWEEN RT.DateIni AND RT.DateEnd
		WHERE	TR.CompanyId = @CompanyId AND 
				TR.AccountNumber = @AccountNumber AND 
				TR.TransactionDate <= RT.DateEnd AND
				TR.Fk_EscrowModuleId IN (1,2,5)
		) DATA
WHERE	Balance <> 0
ORDER BY VendorId, DateIni