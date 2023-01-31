/*
EXECUTE USP_OOS_Deductions 'A0145', 'OAC', 145, '1/1/2012'
*/
ALTER PROCEDURE USP_OOS_Deductions
		@VendorId					Varchar(10),
		@DeductionCode				Varchar(10),
		@DeductionAmount			Money,
		@StartDate					Smalldatetime,
		@Perpetual					Bit = 1,
		@MaxDeduction				Money = 0,
		@NumberOfDeductions			Int = 0,
		@Inactive					Bit = 0,
		@UserId						Varchar(25) = 'INTEGRATIONS'
AS
DECLARE	@Company					Varchar(5),
		@OOS_DeductionId			int,
		@Fk_OOS_DeductionTypeId     int,
		@Err_Message				Varchar(255)


SET @Company					= (SELECT RTRIM(Company) FROM VendorMaster WHERE VendorId = @VendorId)
SET	@Fk_OOS_DeductionTypeId		= (SELECT OOS_DeductionTypeId FROM OOS_DeductionTypes WHERE Company = @Company AND DeductionCode = @DeductionCode)
SET	@OOS_DeductionId			= (SELECT OOS_DeductionId FROM OOS_Deductions WHERE Fk_OOS_DeductionTypeId = @Fk_OOS_DeductionTypeId AND Vendorid = @VendorId)

IF RTRIM(@DeductionCode) = 'OAC' OR RTRIM(@DeductionCode) = 'TINS'
BEGIN
	SET @DeductionAmount = ROUND(@DeductionAmount / 4, 2)
END

IF @Company IS Null
BEGIN
	SET	@Err_Message = 'Driver ' + RTRIM(@VendorId) + ' not found'
	RAISERROR (@Err_Message, 10, 1)
	RETURN 0
END
ELSE
BEGIN
	IF @OOS_DeductionId IS NULL
	BEGIN
		SET	@StartDate = dbo.DayFwdBack(CAST(CAST(CASE WHEN MONTH(@StartDate) = 12 THEN 1 ELSE MONTH(@StartDate) + 1 END AS Varchar(2)) + '/1/' + CAST(CASE WHEN MONTH(@StartDate) = 12 THEN YEAR(@StartDate) + 1 ELSE YEAR(@StartDate) END AS Varchar(4)) AS Smalldatetime) - 1, 'N', 'Thursday')
		PRINT @StartDate
		
		INSERT INTO [GPCustom].[dbo].[OOS_Deductions]
				   ([Fk_OOS_DeductionTypeId]
				   ,[Vendorid]
				   ,[StartDate]
				   ,[DeductionAmount]
				   ,[MaxDeduction]
				   ,[NumberOfDeductions]
				   ,[Perpetual]
				   ,[CreatedBy]
				   ,[ModifiedBy])
			 VALUES
				   (@Fk_OOS_DeductionTypeId,
				   @Vendorid,
				   @StartDate,
				   @DeductionAmount,
				   @MaxDeduction,
				   @NumberOfDeductions,
				   @Perpetual,
				   @UserId,
				   @UserId)

		IF @@ERROR = 0
			RETURN @@IDENTITY
		ELSE
			RETURN 0
	END
	ELSE
	BEGIN
		SET	@StartDate = CASE WHEN @Perpetual = 1 THEN Null ELSE @StartDate END
		PRINT @StartDate
		
		IF @Inactive = 1
		BEGIN
			UPDATE	OOS_Deductions
			SET		Inactive			= @Inactive
			WHERE	OOS_DeductionId		= @OOS_DeductionId
		END
		ELSE
		BEGIN
			UPDATE	OOS_Deductions
			SET		StartDate			= CASE WHEN @StartDate IS Null THEN StartDate ELSE @StartDate END,
					DeductionAmount		= @DeductionAmount,
					MaxDeduction		= @MaxDeduction,
					NumberOfDeductions	= @NumberOfDeductions,
					Perpetual			= @Perpetual,
					Inactive			= @Inactive,
					ModifiedBy			= @UserId
			WHERE	OOS_DeductionId		= @OOS_DeductionId
		END
		
		IF @@ERROR = 0
			RETURN @OOS_DeductionId
		ELSE
			RETURN 0
	END
END