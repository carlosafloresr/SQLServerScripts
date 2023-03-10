DECLARE	@Company			Varchar(6),
		@BatchDate			DateTime,
		@DedTypes			Char(1),
		@UserId				Varchar(25)

SET		@Company	= 'IMC'
SET		@BatchDate	= '03/31/2011'
SET		@DedTypes	= 'S'
SET		@UserId		= 'CFLORES'

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
		@DeductionCode		Char(10),
		@Consecutive		Int,
		@Period				Char(7),
		@ReturnDate			DateTime,
		@WeekEndDate		Datetime,
		@EscrowBalance		Bit,
		@FinalDeduction		Money,
		@WorkBatchId		Varchar(25)

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

DELETE OOS_Transactions WHERE BatchId = @WorkBatchId

--EXECUTE USP_OOS_RestoreHistory
EXECUTE USP_OOS_Escrow_Repayment @Company, @UserId
EXECUTE USP_TempVendorMaster @Company, @WorkBatchId, @UserId

--UPDATE	OOS_Transactions
--SET		OOS_Transactions.DeductionNumber = RECS.DeductionNumber
--FROM	(SELECT	VendorId
--				,DeductionCode
--				,TransactionId
--				,DeductionDate
--				,ROW_NUMBER() OVER(PARTITION BY VendorId, DeductionCode ORDER BY DeductionDate) AS DeductionNumber
--		FROM	View_OOS_Transactions
--		WHERE	Trans_DeletedBy IS Null) RECS
--WHERE	OOS_TransactionId = TransactionId

DECLARE	@Fk_OOS_DeductionId	Int,
		@DeductionAmount	Money,
		@LastDeduction		Money,
		@Balance			Money

--DECLARE Deductions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT 	OD.DeductionId, 
		OD.AmountToDeduct, 
		OD.StartDate, 
		OD.VendorId,
		OD.Frequency, 
		OD.DeductionCode,
		OD.MaxDeduction, 
		OD.NumberOfDeductions, 
		CASE WHEN OD.MaxDeduction > 0 AND OD.EscrowBalance = 1 THEN OD.Balance ELSE OD.Deducted END AS Deducted, 
		OD.DeductionNumber, 
		OD.Perpetual, 
		OD.DeductionNumber + 1 AS Consecutive,
		ISNULL(OD.Balance,0.0) AS Balance,
		OD.EscrowBalance
FROM 	View_OOS_Deductions OD
		INNER JOIN (SELECT DISTINCT VendorId, TerminationDate FROM TempVendorMaster WHERE BatchId = @WorkBatchId) VM ON OD.VendorId = VM.VendorId
WHERE 	OD.Company = @Company
		AND OD.Completed = 0
		AND OD.DeductionInactive = 0
		AND OD.DeductionTypeInactive = 0
		AND OD.StartDate <= @BatchDate
		--AND CASE WHEN OD.Frequency = 'W' AND OD.LastPeriod <> @WPeriod THEN 1
		--		 WHEN OD.Frequency = 'M' AND OD.LastPeriod <> @MPeriod THEN 1
		--ELSE 0 END = 1
		AND ((OD.NumberOfDeductions > 0 AND (SELECT ISNULL(MAX(LST.DeductionNumber),0) FROM View_OOS_Transactions LST WHERE LST.Company = @Company AND LST.VendorId = OD.VendorId AND LST.DeductionCode = OD.DeductionCode AND LST.DeductionDate >= LST.StartDate) < OD.NumberOfDeductions) OR OD.NumberOfDeductions = 0)
		AND ((OD.MaxDeduction > 0 AND (SELECT ISNULL(SUM(LST.DeductionAmount),0) FROM View_OOS_Transactions LST WHERE LST.Company = @Company AND LST.VendorId = OD.VendorId AND LST.DeductionCode = OD.DeductionCode) < OD.MaxDeduction) OR OD.MaxDeduction = 0)
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
		0
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
		INNER JOIN (SELECT DISTINCT VendorId, SubType, Rate, Amount, TerminationDate FROM TempVendorMaster WHERE SubType = 2 AND BatchId = @WorkBatchId) VM ON DE.VendorId = VM.VendorId
WHERE	DT.DeductionCode = 'MANT' AND
		VM.TerminationDate IS Null AND
		DT.Inactive = 0 AND
		DE.Inactive = 0 AND
		DE.StartDate <= @ReturnDate AND
		DT.Company = @Company) DPY
WHERE	DPY.Deduction1 + DPY.Deduction2 > 0
ORDER BY VendorId

--OPEN Deductions 
--FETCH FROM Deductions INTO @DeductionId, @AmountToDeduct, @StartDate, @VendorId, @Frequency, @DeductionCode,
--			  @MaxDeduction, @NumberOfDeductions, @Deducted, @DeductionNumber, @Perpetual, @Consecutive, @Balance, @EscrowBalance

--BEGIN TRANSACTION

--WHILE @@FETCH_STATUS = 0 
--BEGIN
--	SET @VoucherNumber	= 'OOS_' + RTRIM(@VendorId) + '_' + LEFT(@BatchId, 4) + RIGHT(@BatchId, 2)
--	SET @InvoiceNumber	= RTRIM(@DeductionCode) + RTRIM(@VendorId) + @BatchId + @DedTypes
--	SET @Description	= RTRIM(@DeductionCode) + ' ' + @BatchId + ' # ' + RTRIM(CAST(@Consecutive AS Char(8)))
--	SET	@FinalDeduction = CASE WHEN @MaxDeduction > 0 AND @EscrowBalance = 1 AND @Balance >= @MaxDeduction THEN 0.00
--							   WHEN @MaxDeduction > 0 AND @EscrowBalance = 0 AND @Deducted >= @MaxDeduction THEN 0.00
--							   WHEN @MaxDeduction > 0 AND @EscrowBalance = 1 AND @Balance < @MaxDeduction AND (@MaxDeduction - @Balance) < @AmountToDeduct THEN @MaxDeduction - @Balance 
--						  ELSE @AmountToDeduct END
	
--	IF @Frequency = 'M'
--		SET @Period = @Frequency + @MPeriod
--	ELSE
--		SET @Period = @Frequency + @WPeriod

--	print @Period
--	IF @DeductionId IS NOT Null
--	BEGIN
--		INSERT INTO OOS_Transactions
--			   (Fk_OOS_DeductionId,
--				BatchId,
--				MaxDeduction,
--				DeductionAmount,
--				DeductionDate,
--				Description,
--				Invoice,
--				Voucher,
--				Hold,
--				Period,
--				DeductionNumber,
--				CreatedBy,
--				ModifiedBy)
--		VALUES (@DeductionId,
--				'OOS' + RTRIM(@Company) + '_' + @BatchId,
--				@MaxDeduction - @Deducted,
--				@FinalDeduction,
--				@BatchDate,
--				@Description,
--				@InvoiceNumber,
--				@VoucherNumber,
--				0,
--				@Period,
--				@Consecutive,
--				@UserId,
--				@UserId)
--	END

--	FETCH FROM Deductions INTO @DeductionId, @AmountToDeduct, @StartDate, @VendorId, @Frequency, @DeductionCode,
--				  @MaxDeduction, @NumberOfDeductions, @Deducted, @DeductionNumber, @Perpetual, @Consecutive, @Balance, @EscrowBalance
--END
--CLOSE Deductions
--DEALLOCATE Deductions

--IF @@ERROR = 0
--BEGIN
--	COMMIT TRANSACTION
--END
--ELSE
--BEGIN
--	ROLLBACK TRANSACTION
--END

--DELETE TempVendorMaster WHERE BatchId = @BatchId AND UserId = @UserId

--DECLARE	@RunBatchId	Varchar(25)
--SET	@RunBatchId	= 'OOS' + RTRIM(@Company) + '_' + @BatchId

--IF @Company = 'AIS'
--BEGIN
--	EXECUTE AIS.dbo.OOS_Integrations_Balance_All @Company, @BatchDate
--END

--IF @Company = 'DNJ'
--BEGIN
--	EXECUTE DNJ.dbo.OOS_Integrations_Balance_All @Company, @BatchDate
--END

--IF @Company = 'GIS'
--BEGIN
--	EXECUTE GIS.dbo.OOS_Integrations_Balance_All @Company, @BatchDate
--END

--IF @Company = 'IMC'
--BEGIN
--	EXECUTE IMC.dbo.OOS_Integrations_Balance_All @Company, @BatchDate
--END

--IF @Company = 'NDS'
--BEGIN
--	EXECUTE NDS.dbo.OOS_Integrations_Balance_All @Company, @BatchDate
--END

--EXECUTE USP_OOS_Transactions @Company, @RunBatchId

--/*
--EXECUTE NDS.dbo.OOS_Integrations_Balance_All 'AIS', '02/03/2011'
--*/