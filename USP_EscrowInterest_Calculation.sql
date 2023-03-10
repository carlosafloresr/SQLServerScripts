USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_EscrowInterest_Calculation]    Script Date: 4/2/2019 4:28:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_EscrowInterest_Calculation 'AIS',248,'0-00-2790','DRV','12/30/2018','04/06/2019','201901','CFLORES'
SELECT * FROM nds.dbo.GL00105 WHERE ACTNUMST = '00-00-2790'
*/
ALTER PROCEDURE [dbo].[USP_EscrowInterest_Calculation]
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
		@PeriodIni	Date,
		@PeriodEnd	Date,
		@Rate		Money,
		@Interest	Money,
		@PeriodNum	Int = CAST(RIGHT(@Period, 2) AS Int),
		@Query		Varchar(Max)

SET	@Counter	= 1
SET	@TotDays	= DATEDIFF(wk, @BegDate, @EndDate + 2)
SET @Current 	= dbo.DayFwdBack(@BegDate, 'P', 'Saturday')-- DATEADD(DD, -3, @BegDate)

--SET @PeriodIni	= CAST(CASE	@PeriodNum WHEN 1 THEN '01/01/'
--						WHEN 2 THEN '04/01/'
--						WHEN 3 THEN '07/01/'
--						ELSE '10/01/' END + LEFT(@Period, 4) AS Date)
--SET @PeriodEnd	= CAST(CASE	@PeriodNum WHEN 1 THEN '03/31/'
--						WHEN 2 THEN '06/30/'
--						WHEN 3 THEN '09/31/'
--						ELSE '12/31/' END + LEFT(@Period, 4) AS Date)

DECLARE	@tblFiscalDate TABLE (DateIni Date, DateEnd Date)

SET	@Query	= 'SELECT	MIN(DateStart) AS DateIni,
		MAX(DateEnd) AS DateEnd
FROM	' + @CompanyId + '.dbo.View_FiscalPeriods
WHERE	Year1 = ''' + LEFT(@Period, 4) + '''
		AND PeriodId IN ' + CASE @PeriodNum WHEN 1 THEN '(1,2,3)' WHEN 2 THEN '(4,5,6)' WHEN 3 THEN '(7,8,9)' ELSE '(10,11,12)' END

INSERT INTO @tblFiscalDate
EXECUTE(@Query)

DECLARE @tblVendors TABLE (
	VendorId	Varchar(15))

DECLARE	@tblRates TABLE (
	StartDate	Date,
	DateIni		Date,
	DateEnd		Date,
	IntRate		Money)

DECLARE @tblData TABLE (
	DateIni		Smalldatetime,
	DateEnd		Smalldatetime,
	Balance		Money,
	IntRate		Money,
	Interest	Money)

SET	@Query	= 'SELECT PM.VendorId FROM ' + @CompanyId + 
	'.dbo.PM00200 PM INNER JOIN GPCustom.dbo.View_EscrowBalances_ForInterest EI ON PM.VendorId = EI.VendorId AND EI.AccountNumber = ''' +	@AccountNumber + ''' AND ' +
	'EI.CompanyId = ''' + @CompanyId + ''' WHERE VendStts = 1 AND VndClsId = ''' + @DriverClass + ''' ORDER BY PM.VendorId'

INSERT INTO @tblVendors
EXECUTE(@Query)

INSERT INTO @tblRates
SELECT	'01/01/2000' AS StartDate,
		IniDate,
		EndDate,
		ISNULL(InterestRate, 0.00) AS InterestRate
FROM	EscrowRates ER
		INNER JOIN @tblFiscalDate FD ON ER.IniDate BETWEEN FD.DateIni AND FD.DateEnd
WHERE	CompanyId = @CompanyId AND 
		AccountNumber = @AccountNumber AND 
		DriverClass = @DriverClass
ORDER BY IniDate 

DELETE FROM EscrowInterest 
WHERE 	CompanyId = @CompanyId AND 
		AccountNumber = @AccountNumber AND 
		DriverClass = @DriverClass AND
		Period = @Period

INSERT INTO EscrowInterest (CompanyId, AccountIndex, AccountNumber, DriverClass, VendorId, Period, DateIni, DateEnd, AmountInvested, InterestRate, InterestAmount, Approved, CreatedOn, CreatedBy, BatchId)
SELECT	@CompanyId,
		@AccountIndex,
		@AccountNumber,
		@DriverClass,
		VendorId,
		@Period,
		DateIni,
		DateEnd,
		Balance,
		IntRate,
		ISNULL(CAST(ROUND(Balance * (IntRate / 100.000) * (7.000 / 365.000), 2) AS Numeric(10,2)), 0.000),
		0,
		GETDATE(),
		@UserId,
		'EI' + RTRIM(REPLACE(SUBSTRING(@AccountNumber, 3, 7), '-', '')) + RTRIM(@DriverClass) + SUBSTRING(@Period, 3, 4)
FROM	(
		SELECT	VendorId,
				DateIni,
				DateEnd,
				IntRate,
				SUM(Amount) AS Balance
		FROM	(
				SELECT 	TR.VendorId,
						RT.DateIni,
						RT.DateEnd,
						ISNULL(RT.IntRate,0.0000) AS IntRate,
						TR.Amount
				FROM 	View_EscrowTransactions TR
						INNER JOIN @tblVendors VD ON TR.VendorId = VD.VendorId
						INNER JOIN @tblRates RT ON CAST(TR.TransactionDate AS Date) BETWEEN RT.StartDate AND RT.DateEnd
				WHERE	TR.CompanyId = @CompanyId 
						AND TR.AccountNumber = @AccountNumber
						AND TR.TransactionDate <= RT.DateEnd
						AND TR.Fk_EscrowModuleId IN (1,2)
				) DATA
		GROUP BY
				VendorId,
				DateIni,
				DateEnd,
				IntRate
		) DATA
--WHERE	Balance <> 0
ORDER BY VendorId, DateIni

--INSERT INTO EscrowInterest (CompanyId, AccountIndex, AccountNumber, DriverClass, VendorId, Period, DateIni, DateEnd, AmountInvested, InterestRate, InterestAmount, Approved, CreatedOn, CreatedBy, BatchId)
--SELECT	DISTINCT @CompanyId,
--		@AccountIndex,
--		@AccountNumber,
--		@DriverClass,
--		VendorId,
--		@Period,
--		DateIni,
--		DateEnd,
--		Balance,
--		IntRate,
--		ISNULL(CAST(ROUND(Balance * (IntRate / 100.000) * (7.000 / 365.000), 2) AS Numeric(10,2)), 0.000),
--		0,
--		GETDATE(),
--		@UserId,
--		'EI' + RTRIM(REPLACE(SUBSTRING(@AccountNumber, 3, 7), '-', '')) + RTRIM(@DriverClass) + SUBSTRING(@Period, 3, 4)
--FROM	(
--		SELECT 	TR.VendorId,
--				RT.DateIni,
--				RT.DateEnd,
--				ISNULL(RT.IntRate,0.0000) AS IntRate,
--				Balance = ISNULL((SELECT SUM(VT.Amount) FROM View_EscrowTransactions VT WHERE VT.CompanyId = TR.CompanyId AND VT.VendorId = TR.VendorId AND VT.AccountNumber = TR.AccountNumber AND VT.TransactionDate BETWEEN '01/01/2000' AND RT.DateEnd AND VT.Fk_EscrowModuleId IN (1,2,5)),0)
--				-- Balance = ISNULL((SELECT SUM(CASE WHEN VT.Source = 'AR' THEN VT.Amount * -1 ELSE VT.Amount END) FROM View_EscrowTransactions VT WHERE VT.CompanyId = TR.CompanyId AND VT.VendorId = TR.VendorId AND VT.AccountNumber = TR.AccountNumber AND VT.TransactionDate BETWEEN '01/01/2000' AND RT.DateEnd AND VT.Fk_EscrowModuleId IN (1,2,5)),0)
--		FROM 	View_EscrowTransactions TR
--				INNER JOIN @tblVendors VD ON TR.VendorId = VD.VendorId
--				INNER JOIN @tblRates RT ON CAST(TR.TransactionDate AS Date) BETWEEN RT.DateIni AND RT.DateEnd
--		WHERE	TR.CompanyId = @CompanyId AND 
--				--TR.AccountNumber = @AccountNumber AND 
--				TR.TransactionDate <= RT.DateEnd AND
--				TR.Fk_EscrowModuleId IN (1,2,5)
--		) DATA
--WHERE	Balance <> 0
--ORDER BY VendorId, DateIni