USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_OOS_Escrow_AutoCreate]    Script Date: 10/30/2008 12:24:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXECUTE USP_OOS_Escrow_AutoCreate 'IMC', '99999', 'CFLORES'
ALTER PROCEDURE [dbo].[USP_OOS_Escrow_AutoCreate]
		@Company	Char(5),
		@VendorId	Char(10),
		@UserId		Varchar(25)
AS
DECLARE	@DedCode1		Char(10),
		@DedCode2		Char(10),
		@MaxBalance		Money,
		@AmntOOSTD		Money,
		@AmntOOMYT		Money,
		@AmntRePay		Money,
		@DrvDedCode		Char(10),
		@StartDate		Datetime,
		@TermDate		Datetime,
		@Deducted		Money,
		@DedNumber		Int,
		@Ded1Inactive	Bit,
		@Balance		Money,
		@VendorType		Int,
		@Deduction1Id	Int,
		@Deduction2Id	Int

SELECT	@DedCode1 = VarC
FROM	Parameters
WHERE	ParameterCode = 'ESCROW_OOACCT'

SELECT	@DedCode2 = VarC
FROM	Parameters
WHERE	ParameterCode = 'ESCROW_STNDRD'

SELECT	@MaxBalance = VarN
FROM	Parameters
WHERE	ParameterCode = 'MAXESCROWBALANCE'
		AND Company = @Company

SELECT	@AmntOOSTD = VarN
FROM	Parameters
WHERE	ParameterCode = 'DED_ESC_OOSTD'
		AND Company = @Company

SELECT	@AmntOOMYT = VarN
FROM	Parameters
WHERE	ParameterCode = 'DED_ESC_OOSMT'

SELECT	@AmntRePay = VarN
FROM	Parameters
WHERE	ParameterCode = 'DED_REPAYMENT'
		AND Company = @Company

-- Retrieve Identity for Standard Dedcution
SELECT	@Deduction1Id = OOS_DeductionTypeId
FROM	OOS_DeductionTypes
WHERE	Company = @Company
		AND DeductionCode = @DedCode1
		
-- Retrieve Identity for Repayment Dedcution
SELECT	@Deduction2Id = OOS_DeductionTypeId
FROM	OOS_DeductionTypes
WHERE	Company = @Company
		AND DeductionCode = @DedCode2

SELECT	@Balance = ISNULL(Balance,0)
FROM	View_GeneralEscrowBalance 
WHERE	VendorId = @VendorId 
		AND CompanyId = @Company

IF @Balance IS Null
	SET @Balance = 0

SELECT	@TermDate = VM.TerminationDate
		,@Deducted = ISNULL(OO.Deducted, 0)
		,@Ded1Inactive = OO.DeductionInactive
		,@DrvDedCode = OO.DeductionCode
		,@DedNumber = ISNULL(OO.DeductionNumber, 0)
		,@StartDate = VM.HireDate
		,@VendorType = VM.SubType
FROM	VendorMaster VM
		LEFT JOIN View_OOS_Deductions OO ON VM.VendorId = OO.VendorId AND VM.Company = OO.Company
WHERE	VM.TerminationDate IS Null
		AND (OO.DeductionCode = @DedCode1 OR OO.DeductionCode IS Null)
		AND VM.Company = @Company
		AND VM.VendorId = @VendorId
		AND VM.HireDate IS NOT Null
ORDER BY VM.VendorId

IF @DrvDedCode IS Null AND @Balance < @MaxBalance
BEGIN
	INSERT INTO OOS_Deductions
		(Fk_OOS_DeductionTypeId
		,Vendorid
		,StartDate
		,DeductionAmount
		,Frequency
		,MaxDeduction
		,NumberOfDeductions
		,Perpetual
		,Inactive
		,Completed
		,Notes
		,CurrentDeductions
		,Deducted
		,DeductionNumber
		,Balance
		,LastBatchId
		,LastAmount
		,LastPeriod
		,CreatedOn
		,CreatedBy
		,ModifiedOn
		,ModifiedBy)
VALUES	(@Deduction1Id	-- Fk_OOS_DeductionTypeId
		,@VendorId	-- Vendorid
		,CASE WHEN DATENAME(Weekday, @StartDate) = 'Sunday' THEN @StartDate + 3
		      WHEN DATENAME(Weekday, @StartDate) = 'Monday' THEN @StartDate + 2
			  WHEN DATENAME(Weekday, @StartDate) = 'Tuesday' THEN @StartDate + 1
			  WHEN DATENAME(Weekday, @StartDate) = 'Wednesday' THEN @StartDate
			  WHEN DATENAME(Weekday, @StartDate) = 'Thursday' THEN @StartDate + 6
			  WHEN DATENAME(Weekday, @StartDate) = 'Friday' THEN @StartDate + 5
		ELSE @StartDate + 4 END + CASE WHEN DATENAME(Weekday, @StartDate) = 'Wednesday' THEN 21 ELSE 14 END	-- StartDate
		,CASE WHEN @VendorType = 1 THEN 100 ELSE 150 END	--DeductionAmount
		,'W'	-- Frequency
		,@MaxBalance
		,@MaxBalance / CASE WHEN @VendorType = 1 THEN 100 ELSE 150 END
		,0
		,0
		,0
		,Null
		,0
		,0
		,0
		,@Balance
		,''
		,0
		,''
		,GETDATE()
		,@UserId
		,GETDATE()
		,@UserId)
END