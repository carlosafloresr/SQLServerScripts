USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_OOS_CreateBatch]    Script Date: 6/9/2021 5:34:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_OOS_CreateBatch 'IMC', '06/10/2021', 'W', 'CFLORES'

EXECUTE USP_OOS_DeleteBatch 'OOSHMIS_082318','CFLORES'

EXECUTE DNJ.dbo.OOS_Integrations_Balance_All 'NDS', '09/27/2018'
*/
ALTER PROCEDURE [dbo].[USP_OOS_CreateBatch]
		@Company			Varchar(6),
		@BatchDate			DateTime,
		@DedTypes			Char(1) = 'W',
		@UserId				Varchar(25)
AS
DECLARE	@BOYDate			SmallDateTime,
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
		@DeductionCode		Varchar(10),
		@DeductionType		Varchar(50),
		@Consecutive		Int,
		@Period				Char(7),
		@ReturnDate			DateTime,
		@WeekEndDate		Datetime,
		@EscrowBalance		Bit,
		@FinalDeduction		Money,
		@WorkBatchId		Varchar(25),
		@WebUserId			Varchar(25),
		@Query				Varchar(2000),
		@Fk_OOS_DeductionId	Int,
		@DeductionAmount	Money,
		@LastDeduction		Money,
		@Balance			Money,
		@SpecialDeduction	Bit,
		@QuarterDate		Date,
		@DPYBatchId			Varchar(25)

SET NOCOUNT ON

IF DATENAME(weekday, @BatchDate) = 'Monday'
	SET @ReturnDate = DATEADD(Day, 3, @BatchDate)
ELSE
BEGIN
	IF DATENAME(weekday, @BatchDate) = 'Tuesday'
		SET @ReturnDate = DATEADD(Day, 2, @BatchDate)
	ELSE
	BEGIN
		IF DATENAME(weekday, @BatchDate) = 'Wednesday'
			SET @ReturnDate = DATEADD(Day, 1, @BatchDate)
		ELSE
		BEGIN
			IF DATENAME(weekday, @BatchDate) = 'Thursday'
				SET @ReturnDate = @BatchDate
			ELSE
			BEGIN
				IF DATENAME(weekday, @BatchDate) = 'Friday'
					SET @ReturnDate = DATEADD(Day, -1, @BatchDate)
				ELSE
				BEGIN
					IF DATENAME(weekday, @BatchDate) = 'Saturday'
						SET @ReturnDate = DATEADD(Day, -2, @BatchDate)
					ELSE
					BEGIN
						IF DATENAME(weekday, @BatchDate) = 'Sunday'
							SET @ReturnDate = DATEADD(Day, -3, @BatchDate)
					END
				END
			END
		END
	END
END

SET	@BatchDate		= @ReturnDate
SET	@BOYDate		= CAST('01/01/' + CAST(YEAR(@BatchDate) AS Char(4)) AS SmallDateTime)
SET	@Week			= CASE WHEN DATEDIFF(d, @BOYDate, @BatchDate) = 0 THEN 1 ELSE CAST(DATEDIFF(d, @BOYDate, @BatchDate) / 7 AS Int) + 1 END
SET	@WPeriod		= CAST(YEAR(@BatchDate) AS Char(4)) + dbo.PADL(@Week, 2, '0')
SET	@MPeriod		= CAST(YEAR(@BatchDate) AS Char(4)) + dbo.PADL(MONTH(@BatchDate), 2, '0')
SET	@BatchId		= dbo.PADL(RTRIM(CAST(MONTH(@BatchDate) AS Char(2))), 2, '0') + dbo.PADL(RTRIM(CAST(DAY(@BatchDate) AS Char(2))), 2, '0') + RIGHT(CAST(YEAR(@BatchDate) AS Char(4)), 2)
SET	@WeekEndDate	= @BatchDate - 7
SET	@WeekEndDate	= (CASE WHEN DATENAME(Weekday, @WeekEndDate) = 'Sunday' THEN @WeekEndDate - 1
							ELSE DATEADD(Day, 7 - GPCustom.dbo.WeekDay(@WeekEndDate), @WeekEndDate) END)
SET	@WorkBatchId	= 'OOS' + RTRIM(@Company) + '_' + @BatchId
SET	@WebUserId		= RTRIM(@UserId) + '_WEB'
SET @DPYBatchId		= (SELECT BatchId FROM Integration_APHeader WHERE Company = @Company AND WeekEndDate = CAST(dbo.DayFwdBack(@ReturnDate, 'P', 'Saturday') AS Date))

DELETE OOS_Transactions WHERE BatchId = @WorkBatchId

PRINT 'Batch Date: ' + CAST(@BatchDate AS Varchar)

EXECUTE USP_OOS_RestoreHistory @Company
-- EXECUTE USP_OOS_Escrow_Repayment @Company, @WebUserId -- Disabled on 08/18/2017 by Carlos A. Flores
EXECUTE USP_TempVendorMaster @Company, @WorkBatchId, @UserId

UPDATE	OOS_Deductions
SET		OOS_Deductions.DeductionNumber = DATA.Counter
FROM	(
		SELECT	VendorId
				,DeductionCode
				,DeductionId
				,COUNT(*) AS Counter
		FROM	View_OOS_Transactions
		WHERE	Trans_DeletedBy IS Null
				AND Company = @Company
		GROUP BY
				VendorId
				,DeductionCode
				,DeductionId
		) DATA
WHERE	OOS_Deductions.OOS_DeductionId = DATA.DeductionId

UPDATE	OOS_Transactions
SET		OOS_Transactions.DeductionNumber = RECS.DeductionNumber
FROM	(
		SELECT	VendorId
				,DeductionCode
				,TransactionId
				,DeductionDate
				,ROW_NUMBER() OVER(PARTITION BY VendorId, DeductionCode ORDER BY DeductionDate) AS DeductionNumber
		FROM	View_OOS_Transactions
		WHERE	Trans_DeletedBy IS Null
				AND Company = @Company
		) RECS
WHERE	OOS_TransactionId = TransactionId

DELETE	TempVendorMaster
WHERE	NewOOSDate IS NOT Null
		AND NewOOSDate < @BatchDate

PRINT 'DPY BatchId: ' + @DPYBatchId

SELECT	*,
		CASE WHEN Perpetual = 1	THEN 1
			 WHEN NumberOfDeductions > 0 AND Counter < NumberOfDeductions THEN 1
			 WHEN MaxDeduction <> 0 AND NumberOfDeductions = 0 AND IIF(MaintainBalance = 1, Balance, Deducted) < MaxDeduction THEN 1
			 WHEN NumberOfDeductions <> 0 AND Counter < NumberOfDeductions THEN 1
			 WHEN DrayageRequired =  1 AND ISNULL((SELECT SUM(DPY.Drayage) FROM Integration_APDetails DPY WHERE DPY.BatchId = @DPYBatchId AND DPY.Processed = 1 AND DPY.Vendorid = DATA.Vendorid),0) > 0 THEN 1
			 ELSE 0 END AS PeriodActive
INTO	#tmpValidDeductions
FROM	(
		SELECT	DED.VendorId,
				DED.DeductionCode,
				DED.MaxDeduction,
				DED.NumberOfDeductions,
				DED.Perpetual,
				DED.Balance,
				DED.MaintainBalance,
				ISNULL(SUM(LST.DeductionAmount),0) AS Deducted,
				ISNULL(COUNT(LST.DeductionAmount),0) AS Counter,
				DED.Sequence,
				DED.DeductionId,
				DED.DrayageRequired
		FROM	View_OOS_Deductions DED
				LEFT JOIN View_OOS_Transactions LST ON DED.Company = LST.Company AND DED.VendorId = LST.VendorId AND DED.DeductionId = LST.DeductionId
		WHERE	DED.Company = @Company
				AND DED.DeductionInactive = 0
				AND DED.DeductionTypeInactive = 0
				AND DED.DeductionCode <> 'MANT'
				AND DED.Vendorid IN (SELECT VendorId FROM TempVendorMaster WHERE TerminationDate IS Null OR TerminationDate >= DATEADD(dd, -90, GETDATE()))
		GROUP BY
				DED.VendorId,
				DED.DeductionCode,
				DED.MaxDeduction,
				DED.NumberOfDeductions,
				DED.Perpetual,
				DED.Balance,
				DED.MaintainBalance,
				DED.Sequence,
				DED.DrayageRequired,
				DED.DeductionId
		) DATA
ORDER BY 
		VendorId,
		DeductionCode

DECLARE Deductions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT 	OD.DeductionId, 
		OD.AmountToDeduct, 
		OD.StartDate, 
		OD.VendorId,
		OD.Frequency, 
		OD.DeductionCode,
		OD.MaxDeduction, 
		OD.NumberOfDeductions, 
		CASE WHEN OD.MaxDeduction <> 0 AND OD.EscrowBalance = 1 THEN OD.Balance ELSE OD.Deducted END AS Deducted, 
		OD.DeductionNumber, 
		OD.Perpetual, 
		OD.DeductionNumber + 1 AS Consecutive,
		ISNULL(OD.Balance,0.00) AS Balance,
		OD.EscrowBalance,
		OD.SpecialDeduction,
		OD.DeductionType
FROM 	View_OOS_Deductions OD
		INNER JOIN (SELECT DISTINCT VendorId, TerminationDate FROM TempVendorMaster WHERE BatchId = @WorkBatchId) VM ON OD.VendorId = VM.VendorId
		INNER JOIN #tmpValidDeductions VD ON OD.Vendorid = VD.Vendorid AND OD.DeductionId = VD.DeductionId AND VD.PeriodActive = 1
WHERE 	OD.Company = @Company
		AND OD.Completed = 0
		AND OD.DeductionInactive = 0
		AND OD.DeductionTypeInactive = 0
		AND OD.StartDate <= @BatchDate
		--AND ((OD.NumberOfDeductions > 0 AND (SELECT ISNULL(COUNT(LST.DeductionNumber),0) FROM View_OOS_Transactions LST WHERE LST.Company = @Company AND LST.VendorId = OD.VendorId AND LST.DeductionCode = OD.DeductionCode AND LST.DeductionDate >= LST.StartDate) < OD.NumberOfDeductions) OR OD.NumberOfDeductions = 0)
		--AND ((OD.MaxDeduction <> 0 AND ABS((SELECT ISNULL(SUM(LST.DeductionAmount),0) FROM View_OOS_Transactions LST WHERE LST.Company = @Company AND LST.VendorId = OD.VendorId AND LST.DeductionCode = OD.DeductionCode)) < ABS(OD.MaxDeduction)) OR OD.MaxDeduction = 0)
		--AND ((OD.DeductionCode = 'CESC' AND OD.MaxDeduction <> 0 AND OD.MaxDeduction > ISNULL(OD.Balance,0.00)) OR (OD.MaxDeduction = 0 AND OD.Perpetual = 1))
		AND OD.DeductionCode <> 'MANT'
		AND VM.TerminationDate IS Null
UNION
SELECT	DeductionId,
		CASE WHEN Deduction2 > 0 AND Deduction1 < Deduction2 THEN Deduction2 ELSE Deduction1 END AS Deduction,
		StartDate,
		VendorId,
		Frequency,
		DeductionCode,
		MaxDeduction,
		NumberOfDeductions,
		Deducted,
		DeductionNumber,
		Perpetual,
		Consecutive,
		0.00,
		0,
		SpecialDeduction,
		DeductionType
FROM	(
		SELECT	DE.OOS_DeductionId AS DeductionId,
				Deduction1 = ISNULL((SELECT SUM(Miles) FROM View_Integration_AP DPY WHERE DE.VendorId = DPY.VendorId AND DT.Company = DPY.Company AND DPY.WeekEndDate = @WeekEndDate), 0.00) * ISNULL(VM.Rate, 0.00),
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
				DeductionNumber + 1 AS Consecutive,
				DT.SpecialDeduction,
				DT.DeductionType
		FROM	OOS_DeductionTypes DT
				INNER JOIN OOS_Deductions DE ON DT.OOS_DeductionTypeId = DE.Fk_OOS_DeductionTypeId
				INNER JOIN (SELECT DISTINCT VendorId, SubType, Rate, Amount, TerminationDate FROM TempVendorMaster WHERE SubType = 2 AND BatchId = @WorkBatchId) VM ON DE.VendorId = VM.VendorId
		WHERE	DT.DeductionCode = 'MANT' AND
				VM.TerminationDate IS Null AND
				DT.Inactive = 0 AND
				DE.Inactive = 0 AND
				DE.StartDate <= @BatchDate AND
				DT.Company = @Company
		) DPY
WHERE	DPY.Deduction1 + DPY.Deduction2 > 0
ORDER BY VendorId

OPEN Deductions 
FETCH FROM Deductions INTO @DeductionId, @AmountToDeduct, @StartDate, @VendorId, @Frequency, @DeductionCode,
			  @MaxDeduction, @NumberOfDeductions, @Deducted, @DeductionNumber, @Perpetual, @Consecutive, @Balance, 
			  @EscrowBalance, @SpecialDeduction, @DeductionType

BEGIN TRANSACTION

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @VoucherNumber	= 'OOS' + RTRIM(@VendorId) + LEFT(@BatchId, 4) + RIGHT(@BatchId, 2)
	SET @InvoiceNumber	= IIF(@DeductionCode = 'FUELTAX', 'FTAX', RTRIM(@DeductionCode)) + RTRIM(@VendorId) + @BatchId + @DedTypes

	IF @SpecialDeduction = 1
	BEGIN
		SET @QuarterDate	= DATEADD(dd, -80, @StartDate)
		SET @Description	= RTRIM(@VendorId) + ' ' + RTRIM(@DeductionType) + ' ' + dbo.GetDateQuarter(@QuarterDate) + ' ' + CAST(@Consecutive AS Varchar) + '/' + CAST(@NumberOfDeductions AS Varchar)
		SET @VoucherNumber	= @VoucherNumber + dbo.PADL(@Consecutive, 2, '0')
		SET @InvoiceNumber	= @InvoiceNumber + dbo.PADL(@Consecutive, 2, '0')
	END
	ELSE
		SET @Description	= RTRIM(@DeductionCode) + ' ' + @BatchId + ' # ' + RTRIM(CAST(@Consecutive AS Char(8)))

	SET	@FinalDeduction = CASE WHEN @MaxDeduction <> 0 AND @EscrowBalance = 1 AND ABS(@Balance) >= ABS(@MaxDeduction) THEN 0.0000
							   WHEN @MaxDeduction <> 0 AND @EscrowBalance = 0 AND ABS(@Deducted) >= ABS(@MaxDeduction) THEN 0.0000
							   WHEN @MaxDeduction <> 0 AND @EscrowBalance = 1 AND ABS(@Balance) < ABS(@MaxDeduction) AND ABS(@MaxDeduction - @Balance) < ABS(@AmountToDeduct) THEN @MaxDeduction - @Balance 
						  ELSE @AmountToDeduct END
	
	SET @Period = @Frequency + CASE WHEN @Frequency = 'M' THEN @MPeriod ELSE @WPeriod END

	IF ISNULL(@DeductionId, 0) > 0
	BEGIN
		BEGIN TRY
			INSERT INTO OOS_Transactions
				   (Fk_OOS_DeductionId,
					BatchId,
					MaxDeduction,
					DeductionAmount,
					DeductionDate,
					[Description],
					Invoice,
					Voucher,
					Hold,
					[Period],
					DeductionNumber,
					CreatedBy,
					ModifiedBy)
			VALUES (@DeductionId,
					@WorkBatchId,
					ISNULL(@MaxDeduction,0) - ISNULL(@Deducted,0),
					@FinalDeduction,
					@BatchDate,
					@Description,
					@InvoiceNumber,
					@VoucherNumber,
					0,
					@Period,
					@Consecutive,
					@UserId,
					@UserId)

			IF @VendorId = '60775'
			BEGIN
				PRINT @DeductionId
				PRINT @WorkBatchId
				PRINT ISNULL(@MaxDeduction,0) - ISNULL(@Deducted,0)
				PRINT @FinalDeduction
				PRINT @BatchDate
				PRINT @Description
				PRINT @InvoiceNumber
				PRINT @VoucherNumber
				PRINT @Period
				PRINT @Consecutive
				PRINT @UserId
			END

			--PRINT RTRIM(@VendorId) + ' ' + @Description + ' ' + CAST(@DeductionId AS Varchar) + ' ' + ISNULL(CAST(@FinalDeduction AS Varchar),'NULO 1')
		END TRY
		BEGIN CATCH
			PRINT @@ERROR
		END CATCH
	END

	FETCH FROM Deductions INTO @DeductionId, @AmountToDeduct, @StartDate, @VendorId, @Frequency, @DeductionCode,
				  @MaxDeduction, @NumberOfDeductions, @Deducted, @DeductionNumber, @Perpetual, @Consecutive, @Balance, 
				  @EscrowBalance, @SpecialDeduction, @DeductionType
END
CLOSE Deductions
DEALLOCATE Deductions

DROP TABLE #tmpValidDeductions

IF @@ERROR = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION

DELETE TempVendorMaster WHERE BatchId = @BatchId AND UserId = @UserId

SET @Query = N'EXECUTE ' + RTRIM(@Company) + '.dbo.OOS_Integrations_Balance_All ''' + RTRIM(@Company) + ''',''' + CAST(CAST(@BatchDate AS Date) AS Varchar) + ''''

EXECUTE(@Query)
EXECUTE USP_OOS_Transactions @Company, @WorkBatchId