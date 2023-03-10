USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_VendorMaster]    Script Date: 12/30/2021 9:47:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_VendorMaster 'D0643', 'DNJ', '09/17/2013', NULL, 1, 0, 0, NULL, 0, NULL, 26, 'CFLORES', NULL, NULL, NULL, NULL, NULL, 'D0582', NULL
EXECUTE USP_VendorMaster '12771', 'IMC', '08/20/2014', NULL, 1, 0, 0, NULL, 0, NULL, 09, 'CFLORES', NULL, NULL, NULL, NULL, NULL, NULL, NULL
*/
ALTER PROCEDURE [dbo].[USP_VendorMaster]
		@VendorId				Nchar(10),
		@Company				Varchar(6),
		@HireDate				Datetime,
		@TerminationDate		Datetime = Null,
		@SubType				Int = 1,
		@ApplyRate				Bit,
		@Rate					Smallmoney,
		@ApplyAmount			Bit = 0,
		@Amount					Smallmoney,
		@ScheduledReleaseDate	Datetime = Null,
		@Division				Varchar(4) = Null,
		@ModifiedBy				Varchar(25),
		@RCCLAccount			Varchar(10) = Null,
		@Agent					Char(2) = Null,
		@UnitId					Varchar(12) = Null,
		@Miles					Int = Null,
		@DrvIssues				Varchar(200) = Null,
		@OldDriverId			Varchar(10) = Null,
		@CoPay					Numeric(10,2) = 0,
		@EmailAddress			Varchar(100) = Null,
		@DocumentsByEmail		Bit = 0,
		@MandRGroup				Bit = 0,
		@NewOOSDate				Date = Null,
		@InGoodStanding			Bit = 1
AS
DECLARE	@Record		Int = 1
SET		@Division	= dbo.PADL(LTRIM(RTRIM(@Division)), 2, '0')

IF @NewOOSDate IS Null
	SET @NewOOSDate = GETDATE()

BEGIN TRANSACTION

IF EXISTS (SELECT VendorId FROM VendorMaster WHERE Company = @Company AND VendorId = @VendorId)
BEGIN
	UPDATE	VendorMaster
	SET		HireDate			= @HireDate,
			TerminationDate		= @TerminationDate,
			SubType				= @SubType,
			ApplyRate			= @ApplyRate,
			Rate				= @Rate,
			ApplyAmount			= ISNULL(@ApplyAmount,0),
			Amount				= @Amount,
			ScheduledReleaseDate= @ScheduledReleaseDate,
			Division			= @Division,
			ModifiedBy			= @ModifiedBy,
			ModifiedOn			= GETDATE(),
			RCCLAccount			= CASE WHEN RCCLAccount IS NOT Null AND @RCCLAccount IS Null THEN RCCLAccount ELSE @RCCLAccount END,
			Agent				= CASE WHEN Agent IS NOT Null AND @Agent IS Null THEN Agent ELSE @Agent END,
			UnitId				= CASE WHEN UnitId IS NOT Null AND @UnitId IS Null THEN UnitId ELSE @UnitId END,
			Miles				= CASE WHEN Miles IS NOT Null AND @Miles IS Null THEN Miles ELSE @Miles END,
			Issues				= CASE WHEN Issues IS NOT Null AND @DrvIssues IS Null THEN Issues ELSE @DrvIssues END,
			OldDriverId			= @OldDriverId,
			CoPay				= @CoPay,
			EmailAddress		= @EmailAddress,
			DocumentsByEmail	= @DocumentsByEmail,
			MandRGroup			= @MandRGroup,
			NewOOSDate			= @NewOOSDate,
			InGoodStanding		= @InGoodStanding
	WHERE	VendorId			= @VendorId AND 
			Company				= @Company
END
ELSE
BEGIN
	INSERT INTO VendorMaster
		   (VendorId,
			Company,
			HireDate,
			TerminationDate,
			SubType,
			ApplyRate,
			Rate,
			ApplyAmount,
			Amount,
			ScheduledReleaseDate,
			Division,
			ModifiedBy,
			ModifiedOn,
			RCCLAccount,
			Agent,
			UnitId,
			Miles,
			Issues,
			OldDriverId,
			CoPay,
			EmailAddress,
			DocumentsByEmail,
			MandRGroup,
			NewOOSDate,
			InGoodStanding)
	VALUES (@VendorId,
			@Company,
			@HireDate,
			@TerminationDate,
			@SubType,
			@ApplyRate,
			@Rate,
			ISNULL(@ApplyAmount,0),
			@Amount,
			@ScheduledReleaseDate,
			@Division,
			@ModifiedBy,
			GETDATE(),
			@RCCLAccount,
			@Agent,
			@UnitId,
			@Miles,
			@DrvIssues,
			@OldDriverId,
			@CoPay,
			@EmailAddress,
			@DocumentsByEmail,
			@MandRGroup,
			@NewOOSDate,
			@InGoodStanding)

	IF @@ERROR = 0
	BEGIN
		EXECUTE GPCustom.dbo.USP_OOS_Escrow_AutoCreate @Company, @VendorId, @ModifiedBy, @HireDate
	END
END

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	SET @Record = 0
END

RETURN @Record