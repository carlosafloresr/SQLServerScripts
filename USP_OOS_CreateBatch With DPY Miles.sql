USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_OOS_CreateBatch]    Script Date: 06/17/2008 13:52:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXECUTE USP_OOS_CreateBatch 'AISTE', '09/27/2007', 'A', 'CFLORES'
ALTER PROCEDURE [dbo].[USP_OOS_CreateBatch]
		@Company		Char(6),
		@BatchDate		SmallDateTime,
		@DedTypes		Char(1),
		@UserId			Varchar(25)
AS
DECLARE	@BOYDate		SmallDateTime,
		@Week				Int,
		@WPeriod			Char(6),
		@MPeriod			Char(6),
		@DeductionId		Int, 
		@AmountToDeduct		Money, 
		@StartDate			SmallDateTime, 
		@VendorId			Char(10), 
		@Frequency			Char(1), 
		@MaxDeduction		Money, 
		@NumberOfDeductions	Int, 
		@Deducted			Money, 
		@DeductionNumber	Int, 
		@Perpetual			Bit,
		@Description		Varchar(30),
		@InvoiceNumber		Varchar(20),
		@VoucherNumber		Varchar(17),
		@BatchId			Varchar(25),
		@DeductionCode		Char(10),
		@Consecutive		Int,
		@Period				Char(7),
		@ReturnDate			SmallDateTime,
		@WeekEndDate		Datetime

IF DATENAME(weekday, @BatchDate) = 'Monday'
	SET @ReturnDate = DATEADD(Day, 3, @BatchDate)

IF DATENAME(weekday, @BatchDate) = 'Tuesday'
	SET @ReturnDate = DATEADD(Day, 2, @BatchDate)

IF DATENAME(weekday, @BatchDate) = 'Wednesday'
	SET @ReturnDate = DATEADD(Day, 1, @BatchDate)

IF DATENAME(weekday, @BatchDate) = 'Thursday'
	SET @ReturnDate = @BatchDate

IF DATENAME(weekday, @BatchDate) = 'Friday'
	SET @ReturnDate = DATEADD(Day, -1, @BatchDate)

IF DATENAME(weekday, @BatchDate) = 'Saturday'
	SET @ReturnDate = DATEADD(Day, -2, @BatchDate)

IF DATENAME(weekday, @BatchDate) = 'Sunday'
	SET @ReturnDate = DATEADD(Day, -3, @BatchDate)

SET	@BatchDate		= @ReturnDate
SET	@BOYDate		= CAST('01/01/' + CAST(YEAR(@BatchDate) AS Char(4)) AS SmallDateTime)
SET	@Week			= CAST(DATEDIFF(d, @BOYDate, @BatchDate) / 7 AS Int)
SET	@WPeriod		= CAST(YEAR(@BatchDate) AS Char(4)) + dbo.PADL(@Week, 2, '0')
SET	@MPeriod		= CAST(YEAR(@BatchDate) AS Char(4)) + dbo.PADL(MONTH(@BatchDate), 2, '0')
SET	@BatchId		= dbo.PADL(RTRIM(CAST(MONTH(@BatchDate) AS Char(2))), 2, '0') + dbo.PADL(RTRIM(CAST(DAY(@BatchDate) AS Char(2))), 2, '0') + RIGHT(CAST(YEAR(@BatchDate) AS Char(4)), 2)
SET	@WeekEndDate	= @BatchDate - 7
SET	@WeekEndDate	= (CASE WHEN DATENAME(Weekday, @WeekEndDate) = 'Sunday' THEN @WeekEndDate - 1
							ELSE DATEADD(Day, 7 - GPCustom.dbo.WeekDay(@WeekEndDate), @WeekEndDate) END)

DELETE OOS_Transactions WHERE BatchId = 'OOS' + RTRIM(@Company) + '_' + @BatchId

EXECUTE USP_OOS_RestoreHistory

DECLARE Deductions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT 	DeductionId, AmountToDeduct, StartDate, VendorId, Frequency, DeductionCode,
		MaxDeduction, NumberOfDeductions, Deducted, DeductionNumber, Perpetual, DeductionNumber + 1 AS Consecutive
FROM 	View_OOS_Deductions
WHERE 	Company = @Company AND
		Completed = 0 AND
		DeductionInactive = 0 AND
		DeductionTypeInactive = 0 AND
		StartDate <= @BatchDate AND
		CASE	WHEN Frequency = 'W' AND LastPeriod <> @WPeriod THEN 1
				WHEN Frequency = 'M' AND LastPeriod <> @MPeriod THEN 1
		ELSE 0 END = 1 AND
		((NumberOfDeductions > 0 AND DeductionNumber < NumberOfDeductions) OR NumberOfDeductions = 0) AND
		((MaxDeduction > 0 AND Deducted < MaxDeduction) OR MaxDeduction = 0) AND
		DeductionCode <> 'MANT'
UNION
SELECT	*
FROM	(
SELECT	DE.OOS_DeductionId AS DeductionId,
		Deduction = ISNULL((SELECT SUM(Miles) FROM View_Integration_AP DPY WHERE DE.VendorId = DPY.VendorId AND DT.Company = DPY.Company AND DPY.WeekEndDate = @WeekEndDate), 0) * ISNULL(VM.Rate, 0),
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
		DE.StartDate < @WeekEndDate AND
		DT.Company = @Company) DPY
WHERE	DPY.Deduction > 0
ORDER BY VendorId

OPEN Deductions 
FETCH FROM Deductions INTO @DeductionId, @AmountToDeduct, @StartDate, @VendorId, @Frequency, @DeductionCode,
			  @MaxDeduction, @NumberOfDeductions, @Deducted, @DeductionNumber, @Perpetual, @Consecutive

BEGIN TRANSACTION

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @VoucherNumber	= 'OOS_' + RTRIM(@VendorId) + '_' + LEFT(@BatchId, 4) + RIGHT(@BatchId, 2)
	SET @InvoiceNumber	= RTRIM(@DeductionCode) + RTRIM(@VendorId) + @BatchId + @DedTypes
	SET @Description	= RTRIM(@DeductionCode) + ' ' + @BatchId + ' # ' + RTRIM(CAST(@Consecutive AS Char(8)))

	IF @MaxDeduction > 0
	BEGIN
		IF @Deducted >= @MaxDeduction
			SET @AmountToDeduct = 0.0
		ELSE
			IF @MaxDeduction - @Deducted < @AmountToDeduct
				SET @AmountToDeduct = @MaxDeduction - @Deducted
	END

	IF @Frequency = 'M'
		SET @Period = @Frequency + @MPeriod
	ELSE
		SET @Period = @Frequency + @WPeriod

	INSERT INTO OOS_Transactions
	       (Fk_OOS_DeductionId,
			BatchId,
			MaxDeduction,
			DeductionAmount,
			DeductionDate,
			Description,
			Invoice,
			Voucher,
			Hold,
			Period,
			DeductionNumber,
			CreatedBy,
			ModifiedBy)
	VALUES (@DeductionId,
			'OOS' + RTRIM(@Company) + '_' + @BatchId,
			@MaxDeduction - @Deducted,
			@AmountToDeduct,
			@BatchDate,
			@Description,
			@InvoiceNumber,
			@VoucherNumber,
			0,
			@Period,
			@Consecutive,
			@UserId,
			@UserId)

	FETCH FROM Deductions INTO @DeductionId, @AmountToDeduct, @StartDate, @VendorId, @Frequency, @DeductionCode,
				  @MaxDeduction, @NumberOfDeductions, @Deducted, @DeductionNumber, @Perpetual, @Consecutive
END
CLOSE Deductions
DEALLOCATE Deductions

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
END

DECLARE	@RunBatchId	Varchar(25)
SET	@RunBatchId	= 'OOS' + RTRIM(@Company) + '_' + @BatchId

EXECUTE USP_OOS_Transactions @Company, @RunBatchId

