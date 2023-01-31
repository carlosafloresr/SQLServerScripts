ALTER PROCEDURE USP_DHP_Applicants
	@DHP_ApplicantId	Int, 
	@FirstName		Varchar(25) = Null,
	@MiddleName		Varchar(20) = Null,
	@LastName		Varchar(30) = Null,
	@DriverType		Char(1) = Null, 
	@Fk_CompanyID		Char(6) = Null,
	@Fk_DivisionId		Int = Null, 
	@USCitizen		Bit = Null,
	@RWSEnglish		Bit = Null, 
	@EligibleforEmployment	Bit = Null, 
	@Address		Varchar(75) = Null, 
	@City			Varchar(25) = Null, 
        @State			Char(2) = Null, 
	@ZipCode		Char(15) = Null, 
	@Months			Int = Null, 
	@Years			Int = Null, 
	@HomePhone		Char(14) = Null, 
	@CellPhone		Char(14) = Null, 
	@DateofBirth		SmallDateTime = Null, 
	@SSN			Char(11) = Null, 
	@CDL			Char(20) = Null, 
	@CDL_State		Char(2) = Null, 
	@CDL_ExpDate		SmallDateTime = Null, 
	@UnitNumber		Char(15) = Null, 
	@UnitYear		Char(4) = Null, 
	@UnitMake		Char(15) = Null, 
	@UnitModel		Char(20) = Null, 
        @OrientationDate	SmallDateTime = Null, 
	@Approved		Bit, 
	@CurrentState		Int =  Null, 
	@Fk_ModuleId		Int, 
	@Cancelled		Bit, 
	@DEType1		Varchar(30) = Null, 
	@DEType2		Varchar(30) = Null, 
	@DEType3		Varchar(30) = Null, 
	@DEDateFrom1		SmallDateTime = Null,
	@DEDateFrom2		SmallDateTime = Null,
	@DEDateFrom3		SmallDateTime = Null,
        @DEDateTo1		SmallDateTime = Null,
	@DEDateTo2		SmallDateTime = Null,
	@DEDateTo3		SmallDateTime = Null,
	@DEMileage1		Int = Null, 
	@DEMileage2		Int = Null, 
	@DEMileage3		Int = Null
AS
DECLARE	@TmpDiff		Int

IF @DHP_ApplicantId = 0
BEGIN
	SET @TmpDiff = (SELECT MAX(DHP_ApplicantId) AS DHP_ApplicantId FROM DHP_Applicants WHERE IsTemp = 1 AND DATEDIFF(Hour, TempDate, GETDATE()) > 1)
	IF @TmpDiff IS NOT Null
	BEGIN
		SET @DHP_ApplicantId = @TmpDiff
	END
END

IF EXISTS(SELECT DHP_ApplicantId FROM DHP_Applicants WHERE DHP_ApplicantId = @DHP_ApplicantId)
BEGIN
	BEGIN TRANSACTION

	UPDATE	DHP_Applicants
	SET	IsTemp			= 0,
		TempDate		= GETDATE(),
		FirstName		= @FirstName,
		MiddleName		= @MiddleName,
		LastName		= @LastName,
		DriverType		= @DriverType,
		Fk_CompanyID		= @Fk_CompanyID,
		Fk_DivisionId		= @Fk_DivisionId,
		USCitizen		= @USCitizen,
		RWSEnglish		= @RWSEnglish,
		EligibleforEmployment	= @EligibleforEmployment,
		Address			= @Address,
		City			= @City,
	        State			= @State,
		ZipCode			= @ZipCode,
		Months			= @Months,
		Years			= @Years,
		HomePhone		= @HomePhone,
		CellPhone		= @CellPhone,
		DateofBirth		= @DateofBirth,
		SSN			= @SSN,
		CDL			= @CDL,
		CDL_State		= @CDL_State,
		CDL_ExpDate		= @CDL_ExpDate,
		UnitNumber		= @UnitNumber,
		UnitYear		= @UnitYear,
		UnitMake		= @UnitMake,
		UnitModel		= @UnitModel,
	        OrientationDate		= @OrientationDate,
		Approved		= @Approved,
		CurrentState		= @CurrentState,
		Fk_ModuleId		= @Fk_ModuleId,
		Cancelled		= @Cancelled,
		DEType1			= @DEType1,
		DEType2			= @DEType2,
		DEType3			= @DEType3,
		DEDateFrom1		= @DEDateFrom1,
		DEDateFrom2		= @DEDateFrom2,
		DEDateFrom3		= @DEDateFrom3,
	        DEDateTo1		= @DEDateTo1,
		DEDateTo2		= @DEDateTo2,
		DEDateTo3		= @DEDateTo3,
		DEMileage1		= @DEMileage1,
		DEMileage2		= @DEMileage2,
		DEMileage3		= @DEMileage3
	WHERE	DHP_ApplicantId 	= @DHP_ApplicantId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION Tran1
		RETURN @DHP_ApplicantId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION Tran1
		RETURN @@ERROR * -1
	END
END
ELSE
BEGIN
	BEGIN TRANSACTION

	INSERT INTO DHP_Applicants
	       (IsTemp,
		TempDate,
		FirstName,
		MiddleName,
		LastName,
		DriverType,
		Fk_CompanyID,
		Fk_DivisionId,
		USCitizen, 
		RWSEnglish, 
		EligibleforEmployment, 
		Address, 
		City, 
	        State, 
		ZipCode, 
		Months, 
		Years, 
		HomePhone, 
		CellPhone, 
		DateofBirth, 
		SSN, 
		CDL, 
		CDL_State, 
		CDL_ExpDate, 
		UnitNumber, 
		UnitYear, 
		UnitMake, 
		UnitModel, 
	        OrientationDate, 
		Approved,
		ApplicationDate,
		CurrentState, 
		Fk_ModuleId, 
		Cancelled, 
		DEType1, 
		DEType2, 
		DEType3, 
		DEDateFrom1, 
		DEDateFrom2, 
		DEDateFrom3, 
	        DEDateTo1, 
		DEDateTo2, 
		DEDateTo3, 
		DEMileage1, 
		DEMileage2, 
		DEMileage3)
	VALUES (1,
		GETDATE(),
		@FirstName, 
		@MiddleName, 
		@LastName, 
		@DriverType, 
		@Fk_CompanyID, 
		@Fk_DivisionId, 
		@USCitizen, 
		@RWSEnglish, 
		@EligibleforEmployment, 
		@Address, 
		@City, 
	        @State, 
		@ZipCode, 
		@Months, 
		@Years, 
		@HomePhone, 
		@CellPhone, 
		@DateofBirth, 
		@SSN, 
		@CDL, 
		@CDL_State, 
		@CDL_ExpDate, 
		@UnitNumber, 
		@UnitYear, 
		@UnitMake, 
		@UnitModel, 
	        @OrientationDate, 
		@Approved, 
		GETDATE(), 
		@CurrentState, 
		@Fk_ModuleId, 
		@Cancelled, 
		@DEType1, 
		@DEType2, 
		@DEType3, 
		@DEDateFrom1, 
		@DEDateFrom2, 
		@DEDateFrom3, 
	        @DEDateTo1, 
		@DEDateTo2, 
		@DEDateTo3, 
		@DEMileage1, 
		@DEMileage2, 
		@DEMileage3)

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