USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_OOS_Deductions_Create]    Script Date: 7/18/2017 10:42:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_OOS_Deductions_Create 'AIS', 'A1693', 'FUELTAX', '8/22/2017', 500, 4
EXECUTE USP_OOS_Deductions_Create 'AIS', 'A1693', 'FUELTAX', '12/22/2017', -500, 4
*/
CREATE PROCEDURE [dbo].[USP_OOS_Deductions_Create]
		@Company					Varchar(5),
		@VendorId					Varchar(10),
		@DeductionCode				Varchar(10),
		@StartDate					Smalldatetime,
		@MaxDeduction				Numeric(10,2),
		@NumberOfDeductions			Int
AS
DECLARE	@OOS_DeductionId			Int,
		@Fk_OOS_DeductionTypeId     Int,
		@Sequence					Smallint,
		@TempSequence				Smallint,
		@DeductionAmount			Money,
		@Perpetual					Bit = 0,
		@Inactive					Bit = 0,
		@UserId						Varchar(25) = 'INTEGRATIONS',
		@Err_Message				Varchar(255)

SET	@Fk_OOS_DeductionTypeId	= (SELECT OOS_DeductionTypeId FROM OOS_DeductionTypes WHERE Company = @Company AND DeductionCode = @DeductionCode)
SET	@StartDate				= dbo.DayFwdBack(@StartDate, 'N', 'Thursday')
SET @DeductionAmount		= CASE WHEN @NumberOfDeductions = 1 THEN @MaxDeduction ELSE ROUND(@MaxDeduction / @NumberOfDeductions, 2) END

PRINT '      Start Date: ' + CONVERT(Char(10), @StartDate, 101)
PRINT 'Deduction Amount: ' + CAST(ISNULL(@DeductionAmount, 0) AS Varchar)

IF @Fk_OOS_DeductionTypeId IS Null
BEGIN		
	SET	@Err_Message = 'ERROR: The Deduction Code ''' + @DeductionCode + ''' is not setup for the Company ' + @Company
	RAISERROR (@Err_Message, 10, 1)
	RETURN 0
END
ELSE
BEGIN
	IF NOT EXISTS(SELECT VendorId FROM VendorMaster WHERE Company = @Company AND VendorId = @VendorId)
	BEGIN
		SET	@Err_Message = 'ERROR: The ' + RTRIM(@Company) + ' Driver Id ' + RTRIM(@VendorId) + ' can''t be found'
		RAISERROR (@Err_Message, 10, 1)
		RETURN 0
	END
	ELSE
	BEGIN
		SET @Sequence			= (SELECT MAX(Sequence) FROM OOS_Deductions WHERE Fk_OOS_DeductionTypeId = @Fk_OOS_DeductionTypeId AND VendorId = @VendorId)
		SET	@OOS_DeductionId	= (SELECT OOS_DeductionId FROM OOS_Deductions WHERE Fk_OOS_DeductionTypeId = @Fk_OOS_DeductionTypeId AND Vendorid = @VendorId AND StartDate = @StartDate)

		IF @OOS_DeductionId IS NULL
		BEGIN
			SET @Sequence = CASE WHEN @Sequence IS Null THEN 0 ELSE @Sequence + 1 END
			PRINT '        Sequence: ' + CAST(@Sequence AS Varchar)

			INSERT INTO [GPCustom].[dbo].[OOS_Deductions]
						([Fk_OOS_DeductionTypeId]
						,[Sequence]
						,[Vendorid]
						,[StartDate]
						,[DeductionAmount]
						,[MaxDeduction]
						,[NumberOfDeductions]
						,[Perpetual]
						,[CreatedBy]
						,[ModifiedBy])
			VALUES
						(@Fk_OOS_DeductionTypeId
						,@Sequence
						,@Vendorid
						,@StartDate
						,@DeductionAmount
						,@MaxDeduction
						,@NumberOfDeductions
						,@Perpetual
						,@UserId
						,@UserId)

			IF @@ERROR = 0
				RETURN @@IDENTITY
			ELSE
				RETURN 0
		END
	END
END