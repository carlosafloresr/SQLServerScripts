USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_OOS_DeductionTypes]    Script Date: 8/30/2017 9:19:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_OOS_DeductionTypes]
		@OOS_DeductionTypeId	Int,
		@Company				Varchar(6),
		@DeductionCode			Varchar(10),
		@Description			Varchar(50),
		@CrdAccounts			Int = 1,
		@DebAccounts			Int = 1,
		@CrdAcctIndex			Int,
		@CreditAccount			Varchar(15),
		@CreditPercentage		Numeric(12,4) = 100,
		@CrdAcctIndex2			Int = Null,
		@CreditAccount2			Varchar(15) = Null,
		@CreditPercentage2		Numeric(12,4) = Null,
		@DebAcctIndex			Int,
		@DebitAccount			Varchar(15),
		@DebitPercentage		Numeric(12,4) = 100,
		@DebAcctIndex2			Int = Null,
		@DebitAccount2			Varchar(15) = Null,
		@DebitPercentage2		Numeric(12,4) = Null,
		@MaintainBalance		Bit = 0,
		@EscrowBalance			Bit = 0,
		@Frequency				Char(1) = 'W',
		@DrayageRequired		Bit = 0,
		@AutoCreate				Bit = 0,
		@Inactive				Bit = 0,
		@UserId					Varchar(25),
		@DeductionType			Varchar(15) = Null,
		@SpecialDeduction		Bit = 0,
		@MobileAppVisible		Bit = 0,
		@CreditMaskAgent		Bit = 0,
		@CreditMaskDivision		Bit = 0,
		@DebitMaskAgent			Bit = 0,
		@DebitMaskDivision		Bit = 0
AS
IF @OOS_DeductionTypeId = 0
BEGIN
	BEGIN TRANSACTION

	INSERT INTO OOS_DeductionTypes
		   (Company,
			DeductionCode,
			Description,
			CrdAccounts,
			DebAccounts,
			CrdAcctIndex,
			CreditAccount,
			CreditPercentage,
			CreditMaskAgent,
			CreditMaskDivision,
			CrdAcctIndex2,
			CreditAccount2,
			CreditPercentage2,
			DebAcctIndex,
			DebitAccount,
			DebitPercentage,
			DebitMaskAgent,
			DebitMaskDivision,
			DebAcctIndex2,
			DebitAccount2,
			DebitPercentage2,
			MaintainBalance,
			EscrowBalance,
			Frequency,
			DrayageRequired,
			AutoCreate,
			Inactive,
			DeductionType,
			SpecialDeduction,
			MobileAppVisible,
			CreatedBy,
			CreatedOn,
			ModifiedBy,
			ModifiedOn)
	VALUES (@Company,
			@DeductionCode,
			@Description,
			@CrdAccounts,
			@DebAccounts,
			@CrdAcctIndex,
			@CreditAccount,
			@CreditPercentage,
			@CreditMaskAgent,
			@CreditMaskDivision,
			@CrdAcctIndex2,
			@CreditAccount2,
			@CreditPercentage2,
			@DebAcctIndex,
			@DebitAccount,
			@DebitPercentage,
			@DebitMaskAgent,
			@DebitMaskDivision,
			@DebAcctIndex2,
			@DebitAccount2,
			@DebitPercentage2,
			@MaintainBalance,
			@EscrowBalance,
			@Frequency,
			@DrayageRequired,
			@AutoCreate,
			@Inactive,
			@DeductionType,
			@SpecialDeduction,
			@MobileAppVisible,
			@UserId,
			GETDATE(),
			@UserId,
			GETDATE())

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @@IDENTITY
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END
ELSE
BEGIN
	BEGIN TRANSACTION

	UPDATE	OOS_DeductionTypes
	SET		Description			= @Description,
			CrdAccounts			= @CrdAccounts,
			DebAccounts			= @DebAccounts,
			CrdAcctIndex		= @CrdAcctIndex,
			CreditAccount		= @CreditAccount,
			CreditPercentage	= @CreditPercentage,
			CreditMaskAgent		= @CreditMaskAgent,
			CreditMaskDivision	= @CreditMaskDivision,
			CrdAcctIndex2		= @CrdAcctIndex2,
			CreditAccount2		= @CreditAccount2,
			CreditPercentage2	= @CreditPercentage2,
			DebAcctIndex		= @DebAcctIndex,
			DebitAccount		= @DebitAccount,
			DebitPercentage		= @DebitPercentage,
			DebitMaskAgent		= @DebitMaskAgent,
			DebitMaskDivision	= @DebitMaskDivision,
			DebAcctIndex2		= @DebAcctIndex2,
			DebitAccount2		= @DebitAccount2,
			DebitPercentage2	= @DebitPercentage2,
			MaintainBalance		= @MaintainBalance,
			EscrowBalance		= @EscrowBalance,
			Frequency			= @Frequency,
			DrayageRequired		= @DrayageRequired,
			AutoCreate			= @AutoCreate,
			Inactive			= @Inactive,
			DeductionType		= @DeductionType,
			MobileAppVisible	= @MobileAppVisible,
			ModifiedBy			= @UserId,
			ModifiedOn			= GETDATE()
	WHERE	OOS_DeductionTypeId	= @OOS_DeductionTypeId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @OOS_DeductionTypeId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END

