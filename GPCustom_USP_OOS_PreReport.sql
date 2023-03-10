USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_OOS_PreReport]    Script Date: 08/05/2008 15:30:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_OOS_PreReport 'IMC', 'CFLORES', '8/7/2008'
*/

ALTER PROCEDURE [dbo].[USP_OOS_PreReport]
		@Company	Char(6),
		@UserId		Varchar(25),
		@Date		Datetime
AS
DECLARE	@LastCol	Int

DELETE OOS_PreReport WHERE Company = @Company AND UserId = @UserId
DELETE OOS_PreReport_Columns WHERE Company = @Company AND UserId = @UserId

INSERT INTO OOS_PreReport_Columns
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

EXECUTE USP_OOS_RestoreHistory

IF @Company = 'AIS'
BEGIN
	INSERT INTO OOS_PreReport
	SELECT	DeductionTypeId,
			DeductionCode,
			VendorId,
			VendorName,
			MyTruck,
			HireDate,
			TerminationDate,
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
			SUM(CASE WHEN TerminationDate IS Null THEN AmountToDeduct ELSE 0.00 END) AS Total,
			@Company AS Company,
			@UserId AS UserId
	FROM	(
	SELECT	OD.DeductionTypeId,
			OD.DeductionCode,
			OD.VendorId,
			VE.VendName AS VendorName,
			CASE WHEN VM.SubType = 2 THEN 'Y' ELSE '' END AS MyTruck,
			VM.HireDate,
			VM.TerminationDate,
			OD.AmountToDeduct,
			ORD.RowNumber
	FROM	AIS.dbo.PM00200 VE
			LEFT JOIN View_OOS_Deductions OD ON VE.VendorId = OD.VendorId
			LEFT JOIN VendorMaster VM ON VE.VendorId = VM.VendorId AND VM.Company = @Company
			INNER JOIN OOS_PreReport_Columns ORD ON OD.DeductionTypeId = ORD.RecordId
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
			VendorName,
			MyTruck,
			HireDate,
			TerminationDate,
			RowNumber
END

IF @Company = 'IMC'
BEGIN
	INSERT INTO OOS_PreReport
	SELECT	DeductionTypeId,
			DeductionCode,
			VendorId,
			VendorName,
			MyTruck,
			HireDate,
			TerminationDate,
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
			SUM(CASE WHEN TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Total,
			@Company AS Company,
			@UserId AS UserId
	FROM	(
	SELECT	OD.DeductionTypeId,
			OD.DeductionCode,
			OD.VendorId,
			VE.VendName AS VendorName,
			CASE WHEN VM.SubType = 2 THEN 'Y' ELSE '' END AS MyTruck,
			VM.HireDate,
			VM.TerminationDate,
			OD.AmountToDeduct,
			ORD.RowNumber
	FROM	IMC.dbo.PM00200 VE
			LEFT JOIN View_OOS_Deductions OD ON VE.VendorId = OD.VendorId
			LEFT JOIN VendorMaster VM ON VE.VendorId = VM.VendorId AND VM.Company = @Company
			INNER JOIN OOS_PreReport_Columns ORD ON OD.DeductionTypeId = ORD.RecordId
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
			VendorName,
			MyTruck,
			HireDate,
			TerminationDate,
			RowNumber
END

IF @Company = 'IMCT'
BEGIN
	INSERT INTO OOS_PreReport
	SELECT	DeductionTypeId,
			DeductionCode,
			VendorId,
			VendorName,
			MyTruck,
			HireDate,
			TerminationDate,
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
			SUM(CASE WHEN TerminationDate IS Null THEN AmountToDeduct ELSE Null END) AS Total,
			@Company AS Company,
			@UserId AS UserId
	FROM	(
	SELECT	OD.DeductionTypeId,
			OD.DeductionCode,
			OD.VendorId,
			VE.VendName AS VendorName,
			CASE WHEN VM.SubType = 2 THEN 'Y' ELSE '' END AS MyTruck,
			VM.HireDate,
			VM.TerminationDate,
			OD.AmountToDeduct,
			ORD.RowNumber
	FROM	IMCT.dbo.PM00200 VE
			LEFT JOIN View_OOS_Deductions OD ON VE.VendorId = OD.VendorId
			LEFT JOIN VendorMaster VM ON VE.VendorId = VM.VendorId AND VM.Company = @Company
			INNER JOIN OOS_PreReport_Columns ORD ON OD.DeductionTypeId = ORD.RecordId
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
			VendorName,
			MyTruck,
			HireDate,
			TerminationDate,
			RowNumber
END

-- Summary Records
SELECT	VendorId,
		VendorName,
		MyTruck,
		HireDate,
		TerminationDate,
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
		HireDate,
		TerminationDate
ORDER BY
		MyTruck DESC,
		TerminationDate,
		VendorId