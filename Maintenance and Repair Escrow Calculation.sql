/*
SELECT * FROM VendorMaster
SELECT * FROM OOS_Deductions
SELECT * FROM OOS_DeductionTypes
SELECT * FROM View_Integration_AP WHERE WeekEndDate = '6/7/2008' AND VendorId = '9503' --384669
*/
DECLARE	@Company		Char(6),
		@WeekEndDate	Datetime

SET		@Company	 = 'IMC'
SET		@WeekEndDate = CAST('6/18/2008' AS Datetime) - 7
SET		@WeekEndDate = CONVERT(Char(10), (CASE WHEN DATENAME(Weekday, @WeekEndDate) = 'Sunday' THEN @WeekEndDate - 1
							ELSE DATEADD(Day, 7 - GPCustom.dbo.WeekDay(@WeekEndDate), @WeekEndDate) END), 101)
/*
SET		@WeekEndDate = (CASE WHEN DATENAME(Weekday, @WeekEndDate) = 'Sunday' THEN @WeekEndDate - 1
							ELSE DATEADD(Day, 7 - GPCustom.dbo.WeekDay(@WeekEndDate), @WeekEndDate) END)
*/
print @WeekEndDate

SELECT	DeductionId,
		CASE WHEN Deduction2 > 0 AND Deduction1 < Deduction2 THEN Deduction2 ELSE Deduction1 END AS Deduction,
		Deduction1 AS RateCalculation,
		Deduction2 AS FixAmount,
		StartDate,
		VendorId,
		Frequency,
		DeductionCode,
		MaxDeduction,
		NumberOfDeductions,
		Deducted,
		DeductionNumber,
		Perpetual,
		Consecutive
FROM	(
SELECT	DE.OOS_DeductionId AS DeductionId,
		Deduction1 = ISNULL((SELECT SUM(Miles) FROM View_Integration_AP DPY WHERE DE.VendorId = DPY.VendorId AND DT.Company = DPY.Company AND DPY.WeekEndDate = @WeekEndDate), 0) * ISNULL(VM.Rate, 0),
		Deduction2 = VM.Amount,
		DE.StartDate,
		DE.VendorId,
		DE.Frequency,
		DT.DeductionCode,
		MaxDeduction,
		NumberOfDeductions,
		Deducted,
		DeductionNumber,
		Perpetual,
		DeductionNumber + 1 AS Consecutive
FROM	OOS_DeductionTypes DT
		INNER JOIN OOS_Deductions DE ON DT.OOS_DeductionTypeId = DE.Fk_OOS_DeductionTypeId
		LEFT JOIN VendorMaster VM ON DE.VendorId = VM.VendorId AND DT.Company = VM.Company
WHERE	VM.SubType = 2 AND
		DT.DeductionCode = 'MANT' AND
		VM.TerminationDate IS Null AND
		DT.Inactive = 0 AND
		DE.Inactive = 0 AND
		CONVERT(Char(10), DE.StartDate, 101) <= @WeekEndDate AND
		DT.Company = @Company) DPY
WHERE	DPY.Deduction1 + DPY.Deduction2 > 0
ORDER BY VendorId