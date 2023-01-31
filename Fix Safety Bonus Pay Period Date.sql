DECLARE	@Company		Varchar(5) = 'GIS',
		@StartDate		Date,
		@Rate			Decimal(10,2),
		@BenPeriods		Int,
		@RunDate		Date = '7/29/2021'

SELECT	@StartDate	= StartDate,
		@BenPeriods = PayPeriods,
		@Rate		= Rate
FROM	SafetyBonusParameters
WHERE	Company		= @Company

UPDATE	SafetyBonus
SET		Period = dbo.FindBonusPeriod(Company, HireDate, @BenPeriods, PayDate),
		BonusPayDate = dbo.FindBonusPeriodDates(Company, HireDate, @BenPeriods, PayDate)
WHERE	Company = @Company
		AND PayDate >= @RunDate
		--AND VendorId = 'G50822'

SELECT	VendorId, PayDate,
		dbo.FindBonusPeriod(Company, HireDate, @BenPeriods, PayDate) AS Period,
		dbo.FindBonusPeriodDates(Company, HireDate, @BenPeriods, PayDate) AS BonusPayDate
from	SafetyBonus
WHERE	Company = @Company
		AND PayDate >= @RunDate
		--AND VendorId = 'G50822'
order by VendorId, PayDate desc

-- PRINT dbo.FindBonusPeriodDates('GIS', '03/18/2010', 2, '01/05/2017')