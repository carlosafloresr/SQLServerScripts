/*
EXECUTE USP_OOS_PreReport 'IMC', 'CFLORES', '8/7/2008'
SELECT * FROM GPCustom.dbo.View_Integration_FPT_Summary WHERE Company = 'IMC' AND VendorId = '004465'
SELECT WeekEndDate, Cash + CashFee AS Cash, FuelAmount + Fees AS Fuel FROM GPCustom.dbo.View_Integration_FPT_Summary WHERE Company = 'IMC' AND VendorId = '004465'
*/

ALTER PROCEDURE [dbo].[USP_OOS_PreReport]
		@Company		Char(6),
		@UserId			Varchar(25),
		@Date			Datetime
AS
DECLARE	@LastCol		Int,
		@WeekEndDateSat	Datetime,
		@WeekEndDateSun	Datetime,
		@FuelRow		Int,
		@FuelCashRow	Int,
		@EscrowStart	Int,
		@EscrowEnd		Int

SET		@WeekEndDateSat = @Date - 7
SET		@WeekEndDateSat = CONVERT(Char(10), (CASE WHEN DATENAME(Weekday, @WeekEndDateSat) = 'Sunday' THEN @WeekEndDateSat - 1
							ELSE DATEADD(Day, 7 - GPCustom.dbo.WeekDay(@WeekEndDateSat), @WeekEndDateSat) END), 101)
SET		@WeekEndDateSun = CONVERT(Char(10), CAST(@WeekEndDateSat AS Datetime) + 1, 101)

DELETE GPCustom.dbo.OOS_PreReport WHERE Company = @Company AND UserId = @UserId
DELETE GPCustom.dbo.OOS_PreReport_Columns WHERE Company = @Company AND UserId = @UserId

INSERT INTO GPCustom.dbo.OOS_PreReport_Columns
SELECT	DISTINCT OOS_DeductionTypeId,
		DeductionCode,
		ROW_NUMBER() OVER (ORDER BY OOS_DeductionTypeId) AS RowNumber,
		@Company,
		@UserId
FROM	GPCustom.dbo.OOS_DeductionTypes
WHERE	Company = @Company

SET		@LastCol = (SELECT	MAX(RowNumber)
					FROM	GPCustom.dbo.OOS_PreReport_Columns
					WHERE	Company = @Company AND 
							UserId = @UserId)
SET		@FuelRow		= @LastCol + 1
SET		@FuelCashRow	= @LastCol + 2

INSERT INTO GPCustom.dbo.OOS_PreReport_Columns 
		(RecordId, ColumnCode, RowNumber, Company, UserId)
VALUES
		(100, 'FUEL', @FuelRow, @Company, @UserId)

INSERT INTO GPCustom.dbo.OOS_PreReport_Columns 
		(RecordId, ColumnCode, RowNumber, Company, UserId)
VALUES
		(101, 'FUEL_CASH', @FuelCashRow, @Company, @UserId)

SET		@LastCol = @FuelCashRow

DECLARE curEscrowTypes CURSOR FOR
SELECT	Fk_EscrowModuleId + 200 AS RecordId,
		ShortCode
FROM	GPCustom.dbo.EscrowAccounts
WHERE	CompanyId = @Company AND
		RemittanceAdvise = 1

DECLARE	@RecordId	Int, 
		@Code		Char(15)

OPEN curEscrowTypes

SET	@EscrowStart = @LastCol + 1

FETCH NEXT FROM curEscrowTypes INTO @RecordId, @Code
WHILE @@FETCH_STATUS = 0
BEGIN
	SET		@LastCol = @LastCol + 1

	INSERT INTO GPCustom.dbo.OOS_PreReport_Columns 
			(RecordId, ColumnCode, RowNumber, Company, UserId)
	VALUES
			(@RecordId, @Code, @LastCol, @Company, @UserId)

	FETCH NEXT FROM curEscrowTypes INTO @RecordId, @Code
END

SET	@EscrowEnd = @LastCol

CLOSE curEscrowTypes
DEALLOCATE curEscrowTypes

-- OOS Calculations (Except M&R)
INSERT INTO GPCustom.dbo.OOS_PreReport
SELECT	DeductionTypeId,
		DeductionCode,
		VendorId,
		RowNumber,
		SUM(CASE WHEN RowNumber = 1 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col01,
		SUM(CASE WHEN RowNumber = 2 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col02,
		SUM(CASE WHEN RowNumber = 3 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col03,
		SUM(CASE WHEN RowNumber = 4 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col04,
		SUM(CASE WHEN RowNumber = 5 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col05,
		SUM(CASE WHEN RowNumber = 6 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col06,
		SUM(CASE WHEN RowNumber = 7 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col07,
		SUM(CASE WHEN RowNumber = 8 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col08,
		SUM(CASE WHEN RowNumber = 9 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col09,
		SUM(CASE WHEN RowNumber = 10 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col10,
		SUM(CASE WHEN RowNumber = 11 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col11,
		SUM(CASE WHEN RowNumber = 12 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col12,
		SUM(CASE WHEN RowNumber = 13 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col13,
		SUM(CASE WHEN RowNumber = 14 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col14,
		SUM(CASE WHEN RowNumber = 15 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col15,
		SUM(CASE WHEN RowNumber = 16 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col16,
		SUM(CASE WHEN RowNumber = 17 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col17,
		SUM(CASE WHEN RowNumber = 18 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col18,
		SUM(CASE WHEN RowNumber = 19 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col19,
		SUM(CASE WHEN RowNumber = 20 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col20,
		SUM(CASE WHEN RowNumber = 21 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col21,
		SUM(CASE WHEN RowNumber = 22 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col22,
		SUM(CASE WHEN RowNumber = 23 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col23,
		SUM(CASE WHEN RowNumber = 24 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col24,
		SUM(CASE WHEN RowNumber = 25 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col25,
		SUM(CASE WHEN RowNumber = 26 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col26,
		SUM(CASE WHEN RowNumber = 27 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col27,
		SUM(CASE WHEN RowNumber = 28 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col28,
		SUM(CASE WHEN RowNumber = 29 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col29,
		SUM(CASE WHEN RowNumber = 30 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col30,
		SUM(CASE WHEN RowNumber = 31 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col31,
		SUM(CASE WHEN RowNumber = 32 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col32,
		SUM(CASE WHEN RowNumber = 33 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col33,
		SUM(CASE WHEN RowNumber = 34 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col34,
		SUM(CASE WHEN RowNumber = 35 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col35,
		SUM(CASE WHEN RowNumber = 36 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col36,
		SUM(CASE WHEN RowNumber = 37 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col37,
		SUM(CASE WHEN RowNumber = 38 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col38,
		SUM(CASE WHEN RowNumber = 39 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col39,
		SUM(CASE WHEN RowNumber = 40 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col40,
		SUM(CASE WHEN RowNumber = 41 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col41,
		SUM(CASE WHEN RowNumber = 42 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col42,
		SUM(CASE WHEN RowNumber = 43 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col43,
		SUM(CASE WHEN RowNumber = 44 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col44,
		SUM(CASE WHEN RowNumber = 45 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col45,
		SUM(CASE WHEN RowNumber = 46 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col46,
		SUM(CASE WHEN RowNumber = 47 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col47,
		SUM(CASE WHEN RowNumber = 48 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col48,
		SUM(CASE WHEN RowNumber = 49 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col49,
		SUM(CASE WHEN RowNumber = 50 AND TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Col50,
		SUM(CASE WHEN TerminationDate IS Null THEN AmountToDeduct ELSE 0.00 END) AS Total,
		@Company AS Company,
		@UserId AS UserId
FROM	(
SELECT	OD.DeductionTypeId,
		OD.DeductionCode,
		OD.VendorId,
		OD.AmountToDeduct,
		ORD.RowNumber,
		VM.TerminationDate
FROM	PM00200 VE
		LEFT JOIN GPCustom.dbo.View_OOS_Deductions OD ON VE.VendorId = OD.VendorId
		LEFT JOIN GPCustom.dbo.VendorMaster VM ON VE.VendorId = VM.VendorId AND VM.Company = @Company
		INNER JOIN GPCustom.dbo.OOS_PreReport_Columns ORD ON OD.DeductionTypeId = ORD.RecordId AND ORD.Company = @Company AND ORD.UserId = @UserId
WHERE	OD.Company = @Company
		AND OD.DedTypeInactive = 0
		AND OD.DeductionInactive = 0
		AND OD.StartDate <= @Date
		AND ((OD.NumberOfDeductions > 0 AND OD.DeductionNumber < OD.NumberOfDeductions) OR OD.NumberOfDeductions = 0)
		AND ((OD.MaxDeduction > 0 AND CASE WHEN OD.EscrowBalance = 1 THEN OD.Balance ELSE OD.Deducted END < OD.MaxDeduction) OR OD.MaxDeduction = 0)
		AND OD.DeductionCode <> 'MANT') OOS
GROUP BY
		DeductionTypeId,
		DeductionCode,
		VendorId,
		RowNumber
UNION
-- M&R Calculation
SELECT	DeductionId,
		DeductionCode,
		VendorId,
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
		SUM(CASE WHEN RowNumber = 31 THEN AmountToDeduct ELSE Null END) AS Col31,
		SUM(CASE WHEN RowNumber = 32 THEN AmountToDeduct ELSE Null END) AS Col32,
		SUM(CASE WHEN RowNumber = 33 THEN AmountToDeduct ELSE Null END) AS Col33,
		SUM(CASE WHEN RowNumber = 34 THEN AmountToDeduct ELSE Null END) AS Col34,
		SUM(CASE WHEN RowNumber = 35 THEN AmountToDeduct ELSE Null END) AS Col35,
		SUM(CASE WHEN RowNumber = 36 THEN AmountToDeduct ELSE Null END) AS Col36,
		SUM(CASE WHEN RowNumber = 37 THEN AmountToDeduct ELSE Null END) AS Col37,
		SUM(CASE WHEN RowNumber = 38 THEN AmountToDeduct ELSE Null END) AS Col38,
		SUM(CASE WHEN RowNumber = 39 THEN AmountToDeduct ELSE Null END) AS Col39,
		SUM(CASE WHEN RowNumber = 40 THEN AmountToDeduct ELSE Null END) AS Col40,
		SUM(CASE WHEN RowNumber = 41 THEN AmountToDeduct ELSE Null END) AS Col41,
		SUM(CASE WHEN RowNumber = 42 THEN AmountToDeduct ELSE Null END) AS Col42,
		SUM(CASE WHEN RowNumber = 43 THEN AmountToDeduct ELSE Null END) AS Col43,
		SUM(CASE WHEN RowNumber = 44 THEN AmountToDeduct ELSE Null END) AS Col44,
		SUM(CASE WHEN RowNumber = 45 THEN AmountToDeduct ELSE Null END) AS Col45,
		SUM(CASE WHEN RowNumber = 46 THEN AmountToDeduct ELSE Null END) AS Col46,
		SUM(CASE WHEN RowNumber = 47 THEN AmountToDeduct ELSE Null END) AS Col47,
		SUM(CASE WHEN RowNumber = 48 THEN AmountToDeduct ELSE Null END) AS Col48,
		SUM(CASE WHEN RowNumber = 49 THEN AmountToDeduct ELSE Null END) AS Col49,
		SUM(CASE WHEN RowNumber = 50 THEN AmountToDeduct ELSE Null END) AS Col50,
		SUM(AmountToDeduct) AS Total,
		@Company AS Company,
		@UserId AS UserId
FROM	(
SELECT	DeductionId,
		DeductionCode,
		VendorId,
		CASE WHEN Deduction2 > 0 AND Deduction1 < Deduction2 THEN Deduction2 ELSE Deduction1 END AS AmountToDeduct,
		RowNumber
FROM	(
SELECT	DE.OOS_DeductionId AS DeductionId,
		Deduction1 = ISNULL((SELECT SUM(Miles) FROM GPCustom.dbo.View_Integration_AP DPY WHERE DE.VendorId = DPY.VendorId AND DT.Company = DPY.Company AND DPY.WeekEndDate = @WeekEndDateSat), 0) * ISNULL(VM.Rate, 0),
		Deduction2 = VM.Amount,
		DE.VendorId,
		DT.DeductionCode,
		ORD.RowNumber
FROM	GPCustom.dbo.OOS_DeductionTypes DT
		INNER JOIN GPCustom.dbo.OOS_Deductions DE ON DT.OOS_DeductionTypeId = DE.Fk_OOS_DeductionTypeId
		LEFT JOIN GPCustom.dbo.VendorMaster VM ON DE.VendorId = VM.VendorId AND DT.Company = VM.Company
		INNER JOIN GPCustom.dbo.OOS_PreReport_Columns ORD ON DT.OOS_DeductionTypeId = ORD.RecordId AND ORD.Company = @Company AND ORD.UserId = @UserId
WHERE	VM.SubType = 2 AND
		DT.DeductionCode = 'MANT' AND
		VM.TerminationDate IS Null AND
		DT.Inactive = 0 AND
		DE.Inactive = 0 AND
		CONVERT(Char(10), DE.StartDate, 101) <= @WeekEndDateSat AND
		DT.Company = @Company) DPY
WHERE	DPY.Deduction1 + DPY.Deduction2 > 0) MAR
GROUP BY
		DeductionId,
		DeductionCode,
		VendorId,
		RowNumber
UNION
-- Fuel Column Calculation
SELECT	DeductionId,
		DeductionCode,
		VendorId,
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
		SUM(CASE WHEN RowNumber = 31 THEN AmountToDeduct ELSE Null END) AS Col31,
		SUM(CASE WHEN RowNumber = 32 THEN AmountToDeduct ELSE Null END) AS Col32,
		SUM(CASE WHEN RowNumber = 33 THEN AmountToDeduct ELSE Null END) AS Col33,
		SUM(CASE WHEN RowNumber = 34 THEN AmountToDeduct ELSE Null END) AS Col34,
		SUM(CASE WHEN RowNumber = 35 THEN AmountToDeduct ELSE Null END) AS Col35,
		SUM(CASE WHEN RowNumber = 36 THEN AmountToDeduct ELSE Null END) AS Col36,
		SUM(CASE WHEN RowNumber = 37 THEN AmountToDeduct ELSE Null END) AS Col37,
		SUM(CASE WHEN RowNumber = 38 THEN AmountToDeduct ELSE Null END) AS Col38,
		SUM(CASE WHEN RowNumber = 39 THEN AmountToDeduct ELSE Null END) AS Col39,
		SUM(CASE WHEN RowNumber = 40 THEN AmountToDeduct ELSE Null END) AS Col40,
		SUM(CASE WHEN RowNumber = 41 THEN AmountToDeduct ELSE Null END) AS Col41,
		SUM(CASE WHEN RowNumber = 42 THEN AmountToDeduct ELSE Null END) AS Col42,
		SUM(CASE WHEN RowNumber = 43 THEN AmountToDeduct ELSE Null END) AS Col43,
		SUM(CASE WHEN RowNumber = 44 THEN AmountToDeduct ELSE Null END) AS Col44,
		SUM(CASE WHEN RowNumber = 45 THEN AmountToDeduct ELSE Null END) AS Col45,
		SUM(CASE WHEN RowNumber = 46 THEN AmountToDeduct ELSE Null END) AS Col46,
		SUM(CASE WHEN RowNumber = 47 THEN AmountToDeduct ELSE Null END) AS Col47,
		SUM(CASE WHEN RowNumber = 48 THEN AmountToDeduct ELSE Null END) AS Col48,
		SUM(CASE WHEN RowNumber = 49 THEN AmountToDeduct ELSE Null END) AS Col49,
		SUM(CASE WHEN RowNumber = 50 THEN AmountToDeduct ELSE Null END) AS Col50,
		SUM(AmountToDeduct) AS Total,
		@Company AS Company,
		@UserId AS UserId
FROM	(
SELECT	100 AS DeductionId, 
		'FUEL' AS DeductionCode,
		VE.VendorId,
		FU.FuelAmount + FU.Fees AS AmountToDeduct,
		@FuelRow AS RowNumber
FROM	GPCustom.dbo.View_Integration_FPT_Summary FU
		INNER JOIN PM00200 VE ON FU.VendorId = GPCustom.dbo.PADL(VE.VendorId, 6, '0')
WHERE	FU.Company = @Company AND 
		FU.FuelAmount + FU.Fees <> 0 AND 
		FU.WeekEndDate = @WeekEndDateSun) FUE
GROUP BY
		DeductionId,
		DeductionCode,
		VendorId,
		RowNumber
UNION
-- Fuel Cash Column Calculation
SELECT	DeductionId,
		DeductionCode,
		VendorId,
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
		SUM(CASE WHEN RowNumber = 31 THEN AmountToDeduct ELSE Null END) AS Col31,
		SUM(CASE WHEN RowNumber = 32 THEN AmountToDeduct ELSE Null END) AS Col32,
		SUM(CASE WHEN RowNumber = 33 THEN AmountToDeduct ELSE Null END) AS Col33,
		SUM(CASE WHEN RowNumber = 34 THEN AmountToDeduct ELSE Null END) AS Col34,
		SUM(CASE WHEN RowNumber = 35 THEN AmountToDeduct ELSE Null END) AS Col35,
		SUM(CASE WHEN RowNumber = 36 THEN AmountToDeduct ELSE Null END) AS Col36,
		SUM(CASE WHEN RowNumber = 37 THEN AmountToDeduct ELSE Null END) AS Col37,
		SUM(CASE WHEN RowNumber = 38 THEN AmountToDeduct ELSE Null END) AS Col38,
		SUM(CASE WHEN RowNumber = 39 THEN AmountToDeduct ELSE Null END) AS Col39,
		SUM(CASE WHEN RowNumber = 40 THEN AmountToDeduct ELSE Null END) AS Col40,
		SUM(CASE WHEN RowNumber = 41 THEN AmountToDeduct ELSE Null END) AS Col41,
		SUM(CASE WHEN RowNumber = 42 THEN AmountToDeduct ELSE Null END) AS Col42,
		SUM(CASE WHEN RowNumber = 43 THEN AmountToDeduct ELSE Null END) AS Col43,
		SUM(CASE WHEN RowNumber = 44 THEN AmountToDeduct ELSE Null END) AS Col44,
		SUM(CASE WHEN RowNumber = 45 THEN AmountToDeduct ELSE Null END) AS Col45,
		SUM(CASE WHEN RowNumber = 46 THEN AmountToDeduct ELSE Null END) AS Col46,
		SUM(CASE WHEN RowNumber = 47 THEN AmountToDeduct ELSE Null END) AS Col47,
		SUM(CASE WHEN RowNumber = 48 THEN AmountToDeduct ELSE Null END) AS Col48,
		SUM(CASE WHEN RowNumber = 49 THEN AmountToDeduct ELSE Null END) AS Col49,
		SUM(CASE WHEN RowNumber = 50 THEN AmountToDeduct ELSE Null END) AS Col50,
		SUM(AmountToDeduct) AS Total,
		@Company AS Company,
		@UserId AS UserId
FROM	(
SELECT	101 AS DeductionId, 
		'FUEL_CASH' AS DeductionCode,
		VE.VendorId,
		FU.Cash + FU.CashFee AS AmountToDeduct,
		@FuelCashRow AS RowNumber
FROM	GPCustom.dbo.View_Integration_FPT_Summary FU
		INNER JOIN PM00200 VE ON FU.VendorId = GPCustom.dbo.PADL(VE.VendorId, 6, '0')
WHERE	FU.Company = @Company AND 
		FU.FuelAmount + FU.Fees <> 0 AND 
		FU.WeekEndDate = @WeekEndDateSun) FUE
GROUP BY
		DeductionId,
		DeductionCode,
		VendorId,
		RowNumber
UNION
-- Escrow Columns Calculation
SELECT	RecordId,
		RecordCode,
		VendorId,
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
		SUM(CASE WHEN RowNumber = 31 THEN AmountToDeduct ELSE Null END) AS Col31,
		SUM(CASE WHEN RowNumber = 32 THEN AmountToDeduct ELSE Null END) AS Col32,
		SUM(CASE WHEN RowNumber = 33 THEN AmountToDeduct ELSE Null END) AS Col33,
		SUM(CASE WHEN RowNumber = 34 THEN AmountToDeduct ELSE Null END) AS Col34,
		SUM(CASE WHEN RowNumber = 35 THEN AmountToDeduct ELSE Null END) AS Col35,
		SUM(CASE WHEN RowNumber = 36 THEN AmountToDeduct ELSE Null END) AS Col36,
		SUM(CASE WHEN RowNumber = 37 THEN AmountToDeduct ELSE Null END) AS Col37,
		SUM(CASE WHEN RowNumber = 38 THEN AmountToDeduct ELSE Null END) AS Col38,
		SUM(CASE WHEN RowNumber = 39 THEN AmountToDeduct ELSE Null END) AS Col39,
		SUM(CASE WHEN RowNumber = 40 THEN AmountToDeduct ELSE Null END) AS Col40,
		SUM(CASE WHEN RowNumber = 41 THEN AmountToDeduct ELSE Null END) AS Col41,
		SUM(CASE WHEN RowNumber = 42 THEN AmountToDeduct ELSE Null END) AS Col42,
		SUM(CASE WHEN RowNumber = 43 THEN AmountToDeduct ELSE Null END) AS Col43,
		SUM(CASE WHEN RowNumber = 44 THEN AmountToDeduct ELSE Null END) AS Col44,
		SUM(CASE WHEN RowNumber = 45 THEN AmountToDeduct ELSE Null END) AS Col45,
		SUM(CASE WHEN RowNumber = 46 THEN AmountToDeduct ELSE Null END) AS Col46,
		SUM(CASE WHEN RowNumber = 47 THEN AmountToDeduct ELSE Null END) AS Col47,
		SUM(CASE WHEN RowNumber = 48 THEN AmountToDeduct ELSE Null END) AS Col48,
		SUM(CASE WHEN RowNumber = 49 THEN AmountToDeduct ELSE Null END) AS Col49,
		SUM(CASE WHEN RowNumber = 50 THEN AmountToDeduct ELSE Null END) AS Col50,
		SUM(AmountToDeduct) AS Total,
		@Company AS Company,
		@UserId AS UserId
FROM	(
SELECT	EA.Fk_EscrowModuleId + 200 AS RecordId,
		EA.ShortCode AS RecordCode,
		ET.VendorId,
		SUM(ET.Amount) AS AmountToDeduct,
		ORD.RowNumber
FROM	GPCustom.dbo.EscrowAccounts EA
		INNER JOIN GPCustom.dbo.EscrowTransactions ET ON EA.CompanyId = ET.CompanyID AND EA.AccountNumber = ET.AccountNumber AND EA.Fk_EscrowModuleId = ET.Fk_EscrowModuleId
		INNER JOIN GPCustom.dbo.OOS_PreReport_Columns ORD ON (EA.Fk_EscrowModuleId + 200) = ORD.RecordId AND ORD.Company = @Company AND ORD.UserId = @UserId
WHERE	EA.CompanyId = @Company AND
		EA.RemittanceAdvise = 1 AND
		ET.PostingDate <= @Date AND
		ET.PostingDate IS NOT Null
GROUP BY
		EA.Fk_EscrowModuleId + 200,
		EA.ShortCode,
		ET.VendorId,
		ORD.RowNumber
HAVING	SUM(ET.Amount) <> 0) ESC
GROUP BY
		RecordId,
		RecordCode,
		VendorId,
		RowNumber

------------------------------
--     Summary Records      --
------------------------------
SELECT	PRE.VendorId,
		LEFT(GPCustom.dbo.PROPER(VEN.VendName), 50) AS VendorName,
		CASE WHEN VEM.SubType = 2 THEN 'Y' ELSE '' END AS MyTruck,
		VEM.HireDate,
		VEM.TerminationDate,
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
		SUM(Col31) AS Col31,
		SUM(Col32) AS Col32,
		SUM(Col33) AS Col33,
		SUM(Col34) AS Col34,
		SUM(Col35) AS Col35,
		SUM(Col36) AS Col36,
		SUM(Col37) AS Col37,
		SUM(Col38) AS Col38,
		SUM(Col39) AS Col39,
		SUM(Col40) AS Col40,
		SUM(Col41) AS Col41,
		SUM(Col42) AS Col42,
		SUM(Col43) AS Col43,
		SUM(Col44) AS Col44,
		SUM(Col45) AS Col45,
		SUM(Col46) AS Col46,
		SUM(Col47) AS Col47,
		SUM(Col48) AS Col48,
		SUM(Col49) AS Col49,
		SUM(Col50) AS Col50,
		SUM(Total) AS Total
FROM	GPCustom.dbo.OOS_PreReport PRE
		INNER JOIN PM00200 VEN ON PRE.VendorId = VEN.VendorId
		LEFT JOIN GPCustom.dbo.VendorMaster VEM ON PRE.VendorId = VEM.VendorId AND PRE.Company = VEM.Company
WHERE	PRE.Company = @Company AND 
		PRE.UserId = @UserId
GROUP BY
		PRE.VendorId,
		VEN.VendName,
		CASE WHEN VEM.SubType = 2 THEN 'Y' ELSE '' END,
		VEM.HireDate,
		VEM.TerminationDate
ORDER BY
		3 DESC,
		VEM.TerminationDate,
		PRE.VendorId

