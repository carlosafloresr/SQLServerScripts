ALTER PROCEDURE USP_DHP_ApplicantsAA
	@Fk_DHP_ApplicantId	Int,
	@StatusId		Int,
	@Rejected		Bit,
	@MVR_Clear		Bit = Null, 
	@MVR_InLimits		Bit = Null, 
	@MVR_Notes		Varchar(2000) = Null, 
	@CDLIS_State1		Char(2) = Null, 
	@CDLIS_State2		Char(2) = Null,
	@CDLIS_State3		Char(2) = Null,
	@CBC_Clear		Bit = Null,
	@CBC_InLimits		Bit = Null,
	@CBC_Notes		Varchar(2000) = Null,
	@DAC_Confirmed		Bit = Null,
	@DAC_notes		Varchar(2000) = Null,
	@Accidents		Bit = Null, 
	@AccidentsDetails	Varchar(3000) = Null, 
	@GeneralStatus		Int = Null,
	@GeneralScore 		Int = Null,
	@Score_TurnOver		Int = Null, 
	@Score_Age		Int = Null,
	@Score_Violations	Int = Null,
	@Score_Accidents	Int = Null,
	@SubmittedOn		SmallDateTime = Null,
	@SubmittedBy		Varchar(25) = Null
AS

IF @Rejected = 1
BEGIN
	BEGIN TRANSACTION

	DELETE 	DHP_ApplicantsAA 
	WHERE 	Fk_DHP_ApplicantId = @Fk_DHP_ApplicantId

	UPDATE 	DHP_Applicants 
	SET 	CurrentState = 2,
		Accepted = 0
	WHERE 	DHP_ApplicantId = @Fk_DHP_ApplicantId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION Tran1
		RETURN @Fk_DHP_ApplicantId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION Tran1
		RETURN @@ERROR * -1
	END
END
ELSE
BEGIN
	IF @SubmittedOn IS NOT Null
		SET @SubmittedOn = GETDATE()
	
	BEGIN TRANSACTION
	
	UPDATE 	DHP_ApplicantsAA
	SET	MVR_Clear		= @MVR_Clear,
		MVR_InLimits		= @MVR_InLimits,
		MVR_Notes		= @MVR_Notes,
		CDLIS_State1		= @CDLIS_State1,
		CDLIS_State2		= @CDLIS_State2,
		CDLIS_State3		= @CDLIS_State3,
		CBC_Clear		= @CBC_Clear,
		CBC_InLimits		= @CBC_InLimits,
		CBC_Notes		= @CBC_Notes,
		DAC_Confirmed		= @DAC_Confirmed,
		DAC_notes		= @DAC_notes,
		Accidents		= @Accidents,
		AccidentsDetails	= @AccidentsDetails,
		GeneralStatus		= @GeneralStatus,
		GeneralScore		= @GeneralScore,
		Score_TurnOver		= @Score_TurnOver,
		Score_Age		= @Score_Age,
		Score_Violations	= @Score_Violations,
		Score_Accidents		= @Score_Accidents,
		SubmittedOn		= @SubmittedOn,
		SubmittedBy		= @SubmittedBy
	WHERE	Fk_DHP_ApplicantId	= @Fk_DHP_ApplicantId

	UPDATE 	DHP_Applicants 
	SET 	Accepted 		= 1,
		CurrentState 		= 2,
		Fk_ModuleId		= 2
	WHERE 	DHP_ApplicantId 	= @Fk_DHP_ApplicantId
	
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION Tran1
		RETURN @Fk_DHP_ApplicantId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION Tran1
		RETURN @@ERROR * -1
	END
END

GO