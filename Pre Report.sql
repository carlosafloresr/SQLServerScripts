/*
EXECUTE USP_OOS_PreReport 'AIS', 'CFLORES', '6/19/2008'
*/

ALTER PROCEDURE USP_OOS_PreReport
		@Company		Char(6),
		@UserId			Varchar(25),
		@Date			Datetime
AS
DECLARE	@LastCol		Int,
		@WeekEndDate	Datetime

SET		@WeekEndDate = @Date - 7
SET		@WeekEndDate = CONVERT(Char(10), (CASE WHEN DATENAME(Weekday, @WeekEndDate) = 'Sunday' THEN @WeekEndDate - 1
							ELSE DATEADD(Day, 7 - GPCustom.dbo.WeekDay(@WeekEndDate), @WeekEndDate) END), 101)

DELETE OOS_PreReport WHERE Company = @Company AND UserId = @UserId
DELETE OOS_PreReport_Columns WHERE Company = @Company AND UserId = @UserId

INSERT INTO OOS_PreReport_Columns
-- OOS Calculations (Except M&R)
SELECT	OOS_DeductionTypeId,
		DeductionCode,
		ROW_NUMBER() OVER (ORDER BY OOS_DeductionTypeId) AS RowNumber,
		@Company,
		@UserId
FROM	OOS_DeductionTypes
WHERE	Company = @Company

SET		@LastCol = (SELECT	MAX(RowNumber) + 1 
					FROM	OOS_PreReport_Columns
					WHERE	Company = @Company AND 
							UserId = @UserId)

INSERT INTO OOS_PreReport
SELECT	DeductionTypeId,
		DeductionCode,
		VendorId,
		VendorName,
		MyTruck,
		HireDate,
		RowNumber,
		SUM(CASE WHEN RowNumber = 1 THEN AmountToDeduct ELSE Null END) AS Col01,
		SUM(CASE WHEN RowNumber = 2 THEN AmountToDeduct ELSE Null END) AS Col02,
		SUM(CASE WHEN RowNumber = 3 THEN AmountToDeduct ELSE Null END) AS Col03,
		SUM(CASE WHEN RowNumber = 4 THEN AmountToDeduct ELSE Null END) AS Col04,
		SUM(CASE WHEN RowNumber = 5 THEN AmountToDeduct ELSE Null END) AS Col05,
		SUM(CASE WHEN RowNumber = 6 THEN AmountToDeduct ELSE Null END) AS Col06,
		SUM(CASE WHEN RowNumber = 7 THEN AmountToDeduct ELSE Null END) AS Col07,
		SUM(CASE WHEN RowNumber = 8 THEN AmountToDeduct ELSE Null END) AS Col08,
		SUM(CASE WHEN RowNumber = 9 THEN AmountToDeduct ELSE Null END) AS Col09,
		SUM(CASE WHEN RowNumber = 10 THEN AmountToDeduct ELSE Null END) AS Col10,
		SUM(CASE WHEN RowNumber = 11 THEN AmountToDeduct ELSE Null END) AS Col11,
		SUM(CASE WHEN RowNumber = 12 THEN AmountToDeduct ELSE Null END) AS Col12,
		SUM(CASE WHEN RowNumber = 13 THEN AmountToDeduct ELSE Null END) AS Col13,
		SUM(CASE WHEN RowNumber = 14 THEN AmountToDeduct ELSE Null END) AS Col14,
		SUM(CASE WHEN RowNumber = 15 THEN AmountToDeduct ELSE Null END) AS Col15,
		SUM(CASE WHEN RowNumber = 16 THEN AmountToDeduct ELSE Null END) AS Col16,
		SUM(CASE WHEN RowNumber = 17 THEN AmountToDeduct ELSE Null END) AS Col17,
		SUM(CASE WHEN RowNumber = 18 THEN AmountToDeduct ELSE Null END) AS Col18,
		SUM(CASE WHEN RowNumber = 19 THEN AmountToDeduct ELSE Null END) AS Col19,
		SUM(CASE WHEN RowNumber = 20 THEN AmountToDeduct ELSE Null END) AS Col20,
		SUM(CASE WHEN RowNumber = 21 THEN AmountToDeduct ELSE Null END) AS Col21,
		SUM(CASE WHEN RowNumber = 22 THEN AmountToDeduct ELSE Null END) AS Col22,
		SUM(CASE WHEN RowNumber = 23 THEN AmountToDeduct ELSE Null END) AS Col23,
		SUM(CASE WHEN RowNumber = 24 THEN AmountToDeduct ELSE Null END) AS Col24,
		SUM(CASE WHEN RowNumber = 25 THEN AmountToDeduct ELSE Null END) AS Col25,
		SUM(CASE WHEN RowNumber = 26 THEN AmountToDeduct ELSE Null END) AS Col26,
		SUM(CASE WHEN RowNumber = 27 THEN AmountToDeduct ELSE Null END) AS Col27,
		SUM(CASE WHEN RowNumber = 28 THEN AmountToDeduct ELSE Null END) AS Col28,
		SUM(CASE WHEN RowNumber = 29 THEN AmountToDeduct ELSE Null END) AS Col29,
		SUM(CASE WHEN RowNumber = 30 THEN AmountToDeduct ELSE Null END) AS Col30,
		SUM(AmountToDeduct) AS Total,
		@Company AS Company,
		@UserId AS UserId
FROM	(
SELECT	OD.DeductionTypeId,
		OD.DeductionCode,
		OD.VendorId,
		VE.VendName AS VendorName,
		CASE WHEN VM.SubType = 2 THEN 'Y' ELSE '' END AS MyTruck,
		VM.HireDate,
		OD.AmountToDeduct,
		ORD.RowNumber
FROM	View_OOS_Deductions OD
		LEFT JOIN VendorMaster VM ON OD.VendorId = VM.VendorId AND OD.Company = VM.Company
		INNER JOIN AIS.dbo.PM00200 VE ON OD.VendorId = VE.VendorId
		INNER JOIN OOS_PreReport_Columns ORD ON OD.DeductionTypeId = ORD.RecordId
WHERE	OD.Company = @Company AND
		OD.DedTypeInactive = 0 AND
		OD.DeductionInactive = 0 AND
		VM.TerminationDate IS Null AND
		OD.DeductionCode <> 'MANT') OOS
GROUP BY
		DeductionTypeId,
		DeductionCode,
		VendorId,
		VendorName,
		MyTruck,
		HireDate,
		RowNumber
UNION
-- M&R Calculation
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

-- Summary Records
SELECT	VendorId,
		VendorName,
		MyTruck,
		HireDate,
		SUM(Col01) AS Col01,
		SUM(Col02) AS Col02,
		SUM(Col03) AS Col03,
		SUM(Col04) AS Col04,
		SUM(Col05) AS Col05,
		SUM(Col06) AS Col06,
		SUM(Col07) AS Col07,
		SUM(Col08) AS Col08,
		SUM(Col09) AS Col09,
		SUM(Col10) AS Col10,
		SUM(Col11) AS Col11,
		SUM(Col12) AS Col12,
		SUM(Col13) AS Col13,
		SUM(Col14) AS Col14,
		SUM(Col15) AS Col15,
		SUM(Col16) AS Col16,
		SUM(Col17) AS Col17,
		SUM(Col18) AS Col18,
		SUM(Col19) AS Col19,
		SUM(Col20) AS Col20,
		SUM(Col21) AS Col21,
		SUM(Col22) AS Col22,
		SUM(Col23) AS Col23,
		SUM(Col24) AS Col24,
		SUM(Col25) AS Col25,
		SUM(Col26) AS Col26,
		SUM(Col27) AS Col27,
		SUM(Col28) AS Col28,
		SUM(Col29) AS Col29,
		SUM(Col30) AS Col30,
		SUM(Total) AS Total
FROM	OOS_PreReport
WHERE	Company = @Company AND 
		UserId = @UserId
GROUP BY
		VendorId,
		VendorName,
		MyTruck,
		HireDate
ORDER BY
		MyTruck DESC,
		VendorId