ALTER PROCEDURE USP_PayrollNotice
	@PayrollNoticeId	Int, 
	@BatchId		Char(15), 
	@Company		Char(6), 
	@EmployeeId		Int, 
	@NoticeType		Int,
	@EmploymentDate		DateTime,
	@EffectiveDate		DateTime,
	@Supervisor		Char(15), 
	@Location		Char(15), 
	@GridClassification	Int, 
	@DOLStatus		Int, 
	@MBO_Eligible		Bit, 
	@MBO_Percentage		Numeric(18,2), 
	@Department		Char(10), 
        @JobPosition		Char(10), 
	@Amount			Money, 
	@Anual			Money,
	@Increase		Numeric(18,2),
	@FTPT			Char(1), 
	@Comments		Varchar(2500), 
	@RecommendedBy		Varchar(35), 
	@ApprovedBy1		Varchar(35), 
	@ApprovedBy2		Varchar(35), 
	@UserId			Varchar(25)
AS
IF @PayrollNoticeId = 0
BEGIN
	BEGIN TRANSACTION

	INSERT INTO PayrollNotice
	       (BatchId, 
		Company, 
		EmployeeId, 
		NoticeType,
		EmploymentDate,
		EffectiveDate,
		Supervisor, 
		Location, 
		GridClassification, 
		DOLStatus, 
		MBO_Eligible, 
		MBO_Percentage, 
		Department, 
	        JobPosition, 
		Amount, 
		Anual,
		Increase,
		FTPT, 
		Comments, 
		RecommendedBy, 
		ApprovedBy1, 
		ApprovedBy2, 
		EnteredBy, 
		ChangedBy)
	VALUES (@BatchId, 
		@Company, 
		@EmployeeId, 
		@NoticeType,
		@EmploymentDate,
		@EffectiveDate,
		@Supervisor, 
		@Location, 
		@GridClassification, 
		@DOLStatus, 
		@MBO_Eligible, 
		@MBO_Percentage, 
		@Department, 
	        @JobPosition, 
		@Amount, 
		@Anual,
		@Increase,
		@FTPT, 
		@Comments, 
		@RecommendedBy, 
		@ApprovedBy1, 
		@ApprovedBy2, 
		@UserId, 
		@UserId)

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

	UPDATE PayrollNotice
	SET	BatchId			= @BatchId, 
		Company			= @Company, 
		EmployeeId		= @EmployeeId, 
		NoticeType		= @NoticeType,
		EmploymentDate		= @EmploymentDate,
		EffectiveDate		= @EffectiveDate,
		Supervisor		= @Supervisor, 
		Location		= @Location, 
		GridClassification	= @GridClassification, 
		DOLStatus		= @DOLStatus, 
		MBO_Eligible		= @MBO_Eligible, 
		MBO_Percentage		= @MBO_Percentage, 
		Department		= @Department, 
	        JobPosition		= @JobPosition, 
		Amount			= @Amount, 
		Anual			= @Anual,
		Increase		= @Increase,
		FTPT			= @FTPT, 
		Comments		= @Comments, 
		RecommendedBy		= @RecommendedBy, 
		ApprovedBy1		= @ApprovedBy1, 
		ApprovedBy2		= @ApprovedBy2, 
		ChangedBy		= @UserId,
		ChangedOn		= GETDATE()
	WHERE	PayrollNoticeId		= @PayrollNoticeId

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @PayrollNoticeId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END
GO