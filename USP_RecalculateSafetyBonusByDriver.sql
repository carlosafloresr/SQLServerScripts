USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_RecalculateSafetyBonusByDriver]    Script Date: 10/6/2022 10:05:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_RecalculateSafetyBonusByDriver 'AIS', 'A52378'
*/
ALTER PROCEDURE [dbo].[USP_RecalculateSafetyBonusByDriver]
		@Company		Varchar(5),
		@VendorId		Varchar(15)
AS
SET NOCOUNT ON

DECLARE	@StartDate		Date,
		@Rate			Decimal(10,2),
		@BenPeriods		Int,
		@Period			Varchar(10),
		@Paid			Bit,
		@PayDate		Datetime,
		@SafetyBonusId	Int

SELECT	@StartDate	= StartDate,
		@BenPeriods = PayPeriods,
		@Rate		= Rate
FROM	SafetyBonusParameters
WHERE	Company		= @Company

DECLARE @tblPeriods Table (Period Varchar(10))

INSERT INTO @tblPeriods
SELECT	TOP 2 *
FROM	(
		SELECT	DISTINCT Period
		FROM	SafetyBonus
		WHERE	Company = @Company
				AND VendorId = @VendorId
				AND SortColumn = 1
		GROUP BY Period
		) DATA
ORDER BY 1 DESC

-- *** DELETE DUPLICATED ENTRY RECORDS
DELETE	SafetyBonus
WHERE	SafetyBonusId IN (
							SELECT	SafetyBonusId
							FROM	(
									SELECT	SAF.VendorId, SAF.Period, SAF.PayDate, SAF.SafetyBonusId
									FROM	SafetyBonus SAF
											INNER JOIN (
														SELECT	Company, VendorId, Period, PayDate, MIN(SafetyBonusId) AS SafetyBonusId, COUNT(PayDate) AS Counter
														FROM	SafetyBonus
														WHERE	Company = @Company
																AND VendorId = @VendorId
																--AND Paid = 0
																AND SortColumn = 1
																AND Period IN (SELECT Period FROM @tblPeriods)
														GROUP BY Company, VendorId, Period, PayDate
														HAVING COUNT(period) > 1
														) COU ON SAF.Company = COU.Company AND SAF.VendorId = COU.VendorId AND SAF.Period = COU.Period AND SAF.PayDate = COU.PayDate AND SAF.SafetyBonusId > COU.SafetyBonusId
									) DATA
						)

-- *** UPDATE THE MILES AND DRAYAGE OF EACH PAID PERIOD
DECLARE PaidPeriods CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	SafetyBonusId,
		PayDate
FROM	SafetyBonus
WHERE	Company = @Company
		AND VendorId = @VendorId
		AND SortColumn = 0
		AND Period IN (SELECT Period FROM @tblPeriods)

OPEN PaidPeriods 
FETCH FROM PaidPeriods INTO @SafetyBonusId, @PayDate

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_Update_SafetyBonus_MilesAndDrayage @PayDate, @Company, @VendorId, @SafetyBonusId

	FETCH FROM PaidPeriods INTO @SafetyBonusId, @PayDate
END

CLOSE PaidPeriods
DEALLOCATE PaidPeriods
			
UPDATE	SafetyBonus
SET		Percentage = dbo.SafetyBonusPercentage(@Company, @VendorId, @StartDate, NULL, HireDate, PayDate, @Rate),
		ToPay = Miles * dbo.SafetyBonusPercentage(@Company, @VendorId, @StartDate, NULL, HireDate, PayDate, @Rate),
		PeriodToPay = Miles * dbo.SafetyBonusPercentage(@Company, @VendorId, @StartDate, NULL, HireDate, PayDate, @Rate),
		PeriodPay = Miles * dbo.SafetyBonusPercentage(@Company, @VendorId, @StartDate, NULL, HireDate, PayDate, @Rate),
		DrayageBonus = Drayage * dbo.SafetyBonusPercentage(@Company, @VendorId, @StartDate, NULL, HireDate, PayDate, @Rate),
		Period = dbo.FindBonusPeriod(Company, HireDate, @BenPeriods, PayDate),
		BonusPayDate = dbo.FindBonusPeriodDates(Company, HireDate, @BenPeriods, PayDate)
WHERE	Company = @Company
		AND VendorId = @VendorId
		AND SortColumn = 1

DECLARE Periods CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	TOP 2 *
FROM	(
		SELECT	DISTINCT Period, MAX(CAST(PayDate AS Date)) AS PayDate
		FROM	SafetyBonus
		WHERE	Company = @Company
				AND VendorId = @VendorId
				AND SortColumn = 1
		GROUP BY Period
		) DATA
ORDER BY 1 DESC

UPDATE	SafetyBonus
SET		Period = dbo.FindBonusPeriod(Company, HireDate, @BenPeriods, PayDate),
		BonusPayDate = dbo.FindBonusPeriodDates(Company, HireDate, @BenPeriods, PayDate)
WHERE	Company = @Company
		AND VendorId = @VendorId
		AND SortColumn = 1

OPEN Periods 
FETCH FROM Periods INTO @Period, @PayDate

WHILE @@FETCH_STATUS = 0 
BEGIN
	--PRINT RTRIM(@VendorId) + ' / ' + @Period

	UPDATE	SafetyBonus
	SET		SortColumn = 1
	WHERE	Company = @Company 
			AND VendorId = @VendorId 
			AND Period = @Period
			AND PayDate < @PayDate

	SELECT	@Paid = MAX(CAST(Paid AS Int))
	FROM	SafetyBonus
	WHERE	Company = @Company 
			AND VendorId = @VendorId 
			AND SortColumn = 0 
			AND Period = @Period

	IF EXISTS(SELECT Period FROM SafetyBonus WHERE Company = @Company AND VendorId = @VendorId AND Period = @Period AND SortColumn = 0)
	BEGIN
		UPDATE	SafetyBonus
		SET		SafetyBonus.Percentage	= DATA.Percentage,
				SafetyBonus.Miles		= DATA.Miles,
				SafetyBonus.ToPay		= DATA.ToPay,
				SafetyBonus.PeriodMiles	= DATA.PeriodMiles,
				SafetyBonus.PeriodPay	= DATA.PeriodPay,
				SafetyBonus.PeriodToPay	= DATA.PeriodToPay,
				SafetyBonus.Drayage		= DATA.Drayage,
				SafetyBonus.DrayageBonus= DATA.DrayageBonus,
				SafetyBonus.BonusPayDate= dbo.FindBonusPeriodDates(DATA.Company, HireDate, @BenPeriods, DATA.PayDate),
				SafetyBonus.Paid		= @Paid
		FROM	(
					SELECT	Company,
							VendorId,
							MAX(PayDate) AS PayDate,
							MAX(Percentage) AS Percentage,
							SUM(Miles) AS Miles,
							SUM(ToPay) AS ToPay,
							SUM(PeriodMiles) AS PeriodMiles,
							SUM(PeriodPay) AS PeriodPay,
							SUM(PeriodToPay) AS PeriodToPay,
							SUM(Drayage) AS Drayage,
							SUM(DrayageBonus) AS DrayageBonus
					FROM	SafetyBonus
					WHERE	Company = @Company
							AND VendorId = @VendorId
							AND SortColumn = 1
							AND Period = @Period
					GROUP BY 
							Company,
							VendorId,
							Period,
							HireDate
				) DATA
		WHERE	SafetyBonus.Company = DATA.Company
				AND SafetyBonus.VendorId = DATA.VendorId
				AND SafetyBonus.Period = @Period
				AND SafetyBonus.SortColumn = 0

		UPDATE	SafetyBonus
		SET		Paid = @Paid
		WHERE	Company = @Company
				AND VendorId = @VendorId
				AND SortColumn = 1
				AND Period = @Period

		UPDATE	SafetyBonus
		SET		Paid = @Paid
		WHERE	Company = @Company
				AND VendorId = @VendorId
				AND SortColumn = 1
				AND Period = @Period
	END
	ELSE
	BEGIN
		INSERT INTO SafetyBonus
		SELECT	Company,
				VendorId,
				OldDriverId,
				VendorName,
				HireDate,
				Period = dbo.FindBonusPeriod(Company, HireDate, @BenPeriods, PayDate),
				PayDate,
				BonusPayDate = dbo.FindBonusPeriodDates(Company, HireDate, @BenPeriods, PayDate),
				Miles,
				ToPay,
				PeriodMiles,
				PeriodPay,
				PeriodToPay,
				0 AS SortColumn,
				0 AS WeeksCounter,
				ISNULL(@Paid, 0) AS Paid,
				GETDATE() AS LastRunWeek,
				Percentage,
				Drayage,
				DrayageBonus
		FROM	(
				SELECT	Company,
						VendorId,
						MAX(OldDriverId) AS OldDriverId,
						VendorName,
						HireDate,
						MAX(PayDate) AS PayDate,
						SUM(Miles) AS Miles,
						SUM(ToPay) AS ToPay,
						SUM(PeriodMiles) AS PeriodMiles,
						SUM(PeriodPay) AS PeriodPay,
						SUM(PeriodToPay) AS PeriodToPay,
						MAX(Percentage) AS Percentage,
						SUM(Drayage) AS Drayage,
						SUM(DrayageBonus) AS DrayageBonus
				FROM	SafetyBonus
				WHERE	Company = @Company
						AND VendorId = @VendorId
						AND SortColumn = 1
						AND Period = @Period
				GROUP BY 
						Company,
						VendorId,
						VendorName,
						Period,
						HireDate
				) DATA
	END

	FETCH FROM Periods INTO @Period, @PayDate
END

CLOSE Periods
DEALLOCATE Periods
/*
SELECT	*
FROM	SafetyBonus
WHERE	Company = @Company
		AND VendorId = @VendorId
		AND SortColumn = 0
		AND Paid = 0
*/