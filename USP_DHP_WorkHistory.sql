ALTER PROCEDURE USP_DHP_WorkHistory
	@Fk_ApplicantId		Int, 
	@EntryId		Int, 
	@Employer		Varchar(75), 
	@Phone			Char(14) = Null, 
	@Fax			Char(14) = Null, 
	@Address		Varchar(250) = Null, 
	@Supervisor		Varchar(30) = Null, 
	@PositionHeld		Varchar(50) = Null, 
	@RatePay		Money = Null, 
	@PayType		Int = Null, 
	@FromDate		SmallDateTime, 
	@ToDate			SmallDateTime, 
	@Accidents		Int = Null, 
        @ReasonForLiving	Varchar(1000) = Null
AS
DECLARE	@WorkingYears		Numeric(9,2)
SET	@WorkingYears		= (DATEDIFF(Day, @FromDate, @ToDate) / 365.00)

IF EXISTS (SELECT @EntryId FROM DHP_WorkHistory WHERE Fk_ApplicantId = @Fk_ApplicantId AND EntryId = @EntryId)
BEGIN
	BEGIN TRANSACTION Tran1

	UPDATE DHP_WorkHistory
	SET 	Employer	= @Employer, 
		Phone		= @Phone, 
		Fax		= @Fax,
		Address		= @Address, 
		Supervisor	= @Supervisor, 
		PositionHeld	= @PositionHeld, 
		RatePay		= @RatePay, 
		PayType		= @PayType, 
		FromDate	= @FromDate, 
		ToDate		= @ToDate, 
		Accidents	= @Accidents, 
	        ReasonForLiving	= @ReasonForLiving, 
		WorkingYears	= @WorkingYears
	WHERE 	Fk_ApplicantId 	= @Fk_ApplicantId AND 
		EntryId 	= @EntryId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION Tran1
		RETURN @@IDENTITY
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION Tran1
		RETURN @@ERROR * -1
	END
END
ELSE
BEGIN
	BEGIN TRANSACTION Tran1

	INSERT INTO DHP_WorkHistory (
		Fk_ApplicantId, 
		EntryId, 
		Employer, 
		Phone, 
		Fax, 
		Address, 
		Supervisor, 
		PositionHeld, 
		RatePay, 
		PayType, 
		FromDate, 
		ToDate, 
		Accidents, 
	        ReasonForLiving, 
		WorkingYears)
	VALUES (@Fk_ApplicantId, 
		@EntryId, 
		@Employer, 
		@Phone, 
		@Fax, 
		@Address, 
		@Supervisor, 
		@PositionHeld, 
		@RatePay, 
		@PayType, 
		@FromDate, 
		@ToDate, 
		@Accidents, 
	        @ReasonForLiving, 
		@WorkingYears)

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION Tran1
		RETURN @@IDENTITY
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION Tran1
		RETURN @@ERROR * -1
	END
END

GO