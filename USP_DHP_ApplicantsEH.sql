ALTER PROCEDURE USP_DHP_ApplicantsEH
	@Fk_DHP_ApplicantId	Int,
	@StatusId		Int,
	@Rejected		Bit,
	@EH_Clear		Bit = Null,
	@EH_Notes		Varchar(2000) = Null,
	@CSAT_Positive		Bit = Null,
	@CSAT_Notes		Varchar(2000) = Null,
	@HireOrientation	SmallDateTime = Null,
	@RoadTest_Pass		Bit = Null,
	@RoadTest_Required	Bit = Null,
	@RoadTest_Notes		Varchar(2000) = Null, 
	@Insurance_Received	Bit = Null,
        @Insurance_Approved	Bit = Null,
	@Contract_Signed	Bit = Null,
	@Contract_Approved	Bit = Null,
	@Inspection_Received	Bit = Null,
	@Inspection_Approved	Bit = Null,
	@FHWA_Received		Bit = Null,
	@FHWA_Approved		Bit = Null,
	@Submitted6W		Bit = Null,
        @SubmittedGP		Bit = Null,
	@NotifyDS		Bit = Null,
	@SubmittedOn		SmallDateTime = Null,
	@SubmittedBy		Varchar(25) = Null,
	@Accepted		Bit = Null
AS
IF @Rejected = 1
BEGIN
	BEGIN TRANSACTION

	DELETE 	DHP_ApplicantsEH
	WHERE 	Fk_DHP_ApplicantId = @Fk_DHP_ApplicantId

	UPDATE 	DHP_Applicants 
	SET 	CurrentState 	= 2,
		Fk_ModuleId	= 3,
		Accepted 	= 0
	WHERE 	DHP_ApplicantId = @Fk_DHP_ApplicantId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @Fk_DHP_ApplicantId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN @@ERROR * -1
	END
END
ELSE
BEGIN
	BEGIN TRANSACTION

	IF @SubmittedOn IS NOT Null
		SET @SubmittedOn = GETDATE()

	UPDATE 	DHP_ApplicantsEH
	SET	EH_Clear		= @EH_Clear,
		EH_Notes		= @EH_Notes,
		CSAT_Positive		= @CSAT_Positive,
		CSAT_Notes		= @CSAT_Notes,
		HireOrientation		= @HireOrientation,
		RoadTest_Pass		= @RoadTest_Pass,
		RoadTest_Required	= @RoadTest_Required,
		RoadTest_Notes		= @RoadTest_Notes,
		Insurance_Received	= @Insurance_Received,
	        Insurance_Approved	= @Insurance_Approved,
		Contract_Signed		= @Contract_Signed,
		Contract_Approved	= @Contract_Approved,
		Inspection_Received	= @Inspection_Received,
		Inspection_approved	= @Inspection_approved,
		FHWA_Received		= @FHWA_Received,
		FHWA_Approved		= @FHWA_Approved,
		Submitted6W		= @Submitted6W,
	        SubmittedGP		= @SubmittedGP,
		NotifyDS		= @NotifyDS,
		SubmittedOn		= @SubmittedOn,
		SubmittedBy		= @SubmittedBy,
		Accepted		= @Accepted
	WHERE	Fk_DHP_ApplicantId	= @Fk_DHP_ApplicantId

	IF @@ERROR = 0
	BEGIN
		IF @SubmittedBy IS NOT Null
		BEGIN
			UPDATE 	DHP_Applicants 
			SET 	Fk_ModuleId		= 4,
				Approved		= 1
			WHERE 	DHP_ApplicantId 	= @Fk_DHP_ApplicantId

			IF @@ERROR = 0
			BEGIN
				COMMIT TRANSACTION
				RETURN @Fk_DHP_ApplicantId
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				RETURN @@ERROR * -1
			END
		END
		ELSE
		BEGIN
			UPDATE 	DHP_Applicants 
			SET 	Accepted 		= 1,
				CurrentState 		= 2,
				Fk_ModuleId		= 3
			WHERE 	DHP_ApplicantId 	= @Fk_DHP_ApplicantId

			COMMIT TRANSACTION
			RETURN @Fk_DHP_ApplicantId
		END
	END
END

GO

