/*
EXECUTE USP_FindDriverSafetyBonus 'AIS','A0061','05/19/2016'
-- IF($F{BonusPayDate}.compareTo($P{parPayDate}) == 0 || $F{SortColumn} == 0, 0, IF($F{PayDate} == $P{parPayDate}, 1, 2))
*/
ALTER PROCEDURE [dbo].[USP_FindDriverSafetyBonus]
		@Company		Varchar(5),
		@VendorId		Varchar(10),
		@PayDate		Datetime
AS
DECLARE	@CalculateBasedOn	Char(1)

SELECT	@CalculateBasedOn	= CalculateBasedOn
FROM	SafetyBonusParameters
WHERE	Company = @Company

IF DATENAME(weekday, @PayDate) <> 'Thursday'
	SET	@PayDate = dbo.TTOD(dbo.DayFwdBack(@PayDate,'N','Thursday'))

SELECT	SafetyBonusId
		,Company
		,VendorId
		,OldDriverId
		,VendorName
		,CAST(HireDate AS Date) AS HireDate
		,Period
		,CAST(PayDate AS Date) AS PayDate
		,CAST(BonusPayDate AS Date) AS BonusPayDate
		,Miles
		,ToPay
		,PeriodMiles
		,PeriodPay
		,SortColumn
		,WeeksCounter
		,Paid
		,CAST(LastRunWeek AS Date) AS LastRunWeek
		,Percentage
		,BonusType
		,BonusUnits
		,BonusAmount
		,ROW_NUMBER() OVER (PARTITION BY VendorId, BonusPayDate ORDER BY PayDate DESC) AS 'RowNumber'
		,CASE WHEN BonusPayDate < @PayDate THEN 'Prior Evaluation Period' ELSE 'Current Evaluation Period' END AS BonusPeriod
		,AdditionalLabel
FROM	(
		-- ** PAY PERIOD RECORD
		SELECT	SAF.SafetyBonusId
				,SAF.Company
				,SAF.VendorId
				,SAF.OldDriverId
				,SAF.VendorName
				,SAF.HireDate
				,SAF.Period
				,SAF.PayDate
				,SAF.BonusPayDate
				,SAF.Miles
				,SAF.ToPay
				,ISNULL(SAF.PeriodMiles, 0) + ISNULL(OLD.PeriodMiles, 0) AS PeriodMiles
				,ISNULL(SAF.PeriodPay, 0) + ISNULL(OLD.PeriodPay, 0) AS PeriodPay
				,SAF.SortColumn
				,SAF.WeeksCounter
				,SAF.Paid
				,SAF.LastRunWeek
				,SAF.Percentage
				,@CalculateBasedOn AS BonusType
				,CASE WHEN @CalculateBasedOn = 'M' THEN ISNULL(SAF.PeriodMiles, 0) + ISNULL(OLD.PeriodMiles, 0) ELSE ISNULL(SAF.Drayage, 0) + ISNULL(OLD.Drayage, 0) END AS BonusUnits
				,CASE WHEN @CalculateBasedOn = 'M' THEN ISNULL(SAF.PeriodPay, 0) + ISNULL(OLD.PeriodPay, 0) ELSE ISNULL(SAF.DrayageBonus, 0) + ISNULL(OLD.DrayageBonus, 0) END AS BonusAmount
				,'Current Week' AS AdditionalLabel
		FROM	SafetyBonus SAF
				LEFT JOIN ( SELECT	Company,
									VendorId,
									Period,
									MAX(PayDate) AS PayDate,
									SUM(PeriodMiles) AS PeriodMiles,
									SUM(PeriodPay) AS PeriodPay,
									SUM(Drayage) AS Drayage,
									SUM(DrayageBonus) AS DrayageBonus
							FROM	SafetyBonus 
							WHERE	SortColumn = 1
									AND PayDate <= @PayDate
							GROUP BY Company, VendorId, Period) OLD ON SAF.Company = OLD.Company AND SAF.OldDriverId = OLD.VendorId AND SAF.Period = OLD.Period AND SAF.PayDate = OLD.PayDate
		WHERE	SAF.Company = @Company
				AND SAF.VendorId = @VendorId
				AND SAF.PayDate = @PayDate
				AND SAF.SortColumn = 1
				--AND SAF.Paid = 0
		UNION
		-- ** PREVIOUS PAY PERIOD RECORDS
		SELECT	0 AS SafetyBonusId
				,SAF.Company
				,SAF.VendorId
				,SAF.OldDriverId
				,SAF.VendorName
				,SAF.HireDate
				,SAF.Period
				,@PayDate AS PayDate
				,SAF.BonusPayDate
				,SUM(SAF.Miles) AS Miles
				,SUM(SAF.ToPay) AS ToPay
				,SUM(ISNULL(SAF.PeriodMiles, 0) + ISNULL(OLD.PeriodMiles, 0)) AS PeriodMiles
				,SUM(ISNULL(SAF.PeriodPay, 0) + ISNULL(OLD.PeriodPay, 0)) AS PeriodPay
				,2 AS SortColumn
				,Null AS WeeksCounter
				,SAF.Paid
				,NULL AS LastRunWeek
				,MAX(SAF.Percentage) AS Percentage
				,@CalculateBasedOn AS BonusType
				,SUM(CASE WHEN @CalculateBasedOn = 'M' THEN ISNULL(SAF.PeriodMiles, 0) + ISNULL(OLD.PeriodMiles, 0) ELSE ISNULL(SAF.Drayage, 0) + ISNULL(OLD.Drayage, 0) END) AS BonusUnits
				,SUM(CASE WHEN @CalculateBasedOn = 'M' THEN ISNULL(SAF.PeriodPay, 0) + ISNULL(OLD.PeriodPay, 0) ELSE ISNULL(SAF.DrayageBonus, 0) + ISNULL(OLD.DrayageBonus, 0) END) AS BonusAmount
				,'Prior Week(s)' AS AdditionalLabel
		FROM	SafetyBonus SAF
				LEFT JOIN ( SELECT	Company,
									VendorId,
									Period,
									--MAX(PayDate) AS PayDate,
									SUM(PeriodMiles) AS PeriodMiles,
									SUM(PeriodPay) AS PeriodPay,
									SUM(Drayage) AS Drayage,
									SUM(DrayageBonus) AS DrayageBonus
							FROM	SafetyBonus 
							WHERE	SortColumn = 1
									AND PayDate <= @PayDate
							GROUP BY Company, VendorId, Period) OLD ON SAF.Company = OLD.Company AND SAF.OldDriverId = OLD.VendorId AND SAF.Period = OLD.Period --AND SAF.PayDate = OLD.PayDate
		WHERE	SAF.Company = @Company
				AND SAF.VendorId = @VendorId
				AND SAF.PayDate < @PayDate
				AND SAF.SortColumn = 1
				--AND SAF.Paid = 0
		GROUP BY
				SAF.Company
				,SAF.VendorId
				,SAF.OldDriverId
				,SAF.VendorName
				,SAF.HireDate
				,SAF.Period
				,SAF.BonusPayDate
				,SAF.Paid
				--,CASE WHEN @CalculateBasedOn = 'M' THEN ISNULL(SAF.PeriodMiles, 0) + ISNULL(OLD.PeriodMiles, 0) ELSE ISNULL(SAF.Drayage, 0) + ISNULL(OLD.Drayage, 0) END
				--,CASE WHEN @CalculateBasedOn = 'M' THEN ISNULL(SAF.PeriodPay, 0) + ISNULL(OLD.PeriodPay, 0) ELSE ISNULL(SAF.DrayageBonus, 0) + ISNULL(OLD.DrayageBonus, 0) END
		UNION
		-- ** SAFETY PERIOD SUMMARY RECORD
		SELECT	SAF.SafetyBonusId
				,SAF.Company
				,SAF.VendorId
				,SAF.OldDriverId
				,SAF.VendorName
				,SAF.HireDate
				,SAF.Period
				,SAF.PayDate
				,SAF.BonusPayDate
				,SAF.Miles
				,SAF.ToPay
				,ISNULL(SAF.PeriodMiles, 0) + ISNULL(OLD.PeriodMiles, 0) AS PeriodMiles
				,ISNULL(SAF.PeriodPay, 0) + ISNULL(OLD.PeriodPay, 0) AS PeriodPay
				,SAF.SortColumn
				,SAF.WeeksCounter
				,SAF.Paid
				,SAF.LastRunWeek
				,SAF.Percentage
				,@CalculateBasedOn AS BonusType
				,CASE WHEN @CalculateBasedOn = 'M' THEN ISNULL(SAF.PeriodMiles, 0) + ISNULL(OLD.PeriodMiles, 0) ELSE ISNULL(SAF.Drayage, 0) + ISNULL(OLD.Drayage, 0) END AS BonusUnits
				,CASE WHEN @CalculateBasedOn = 'M' THEN ISNULL(SAF.PeriodPay, 0) + ISNULL(OLD.PeriodPay, 0) ELSE ISNULL(SAF.DrayageBonus, 0) + ISNULL(OLD.DrayageBonus, 0) END AS BonusAmount
				,'' AS AdditionalLabel
		FROM	SafetyBonus SAF
				LEFT JOIN ( SELECT	Company,
									VendorId,
									Period,
									SUM(PeriodMiles) AS PeriodMiles,
									SUM(PeriodPay) AS PeriodPay,
									SUM(Drayage) AS Drayage,
									SUM(DrayageBonus) AS DrayageBonus
							FROM	SafetyBonus 
							WHERE	SortColumn = 0
									AND PayDate = @PayDate
							GROUP BY Company, VendorId, Period) OLD ON SAF.Company = OLD.Company AND SAF.OldDriverId = OLD.VendorId AND SAF.Period = OLD.Period
		WHERE	SAF.Company = @Company
				AND SAF.VendorId = @VendorId
				AND SAF.BonusPayDate > DATEADD(dd, -60, @PayDate)
				AND SAF.SortColumn = 0
				--AND SAF.Paid = 0
		) RECS
WHERE	BonusPayDate >= @PayDate
		OR (BonusPayDate < @PayDate AND SortColumn = 0)
ORDER BY
		BonusPayDate DESC,
		PayDate DESC,
		SortColumn