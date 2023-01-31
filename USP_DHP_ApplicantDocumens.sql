ALTER PROCEDURE USP_DHP_ApplicantDocumens
	@Fk_DHP_DocumentId	Int,
	@Fk_ApplicantId		Int,
	@FileName		Varchar(50),
	@FullPath		Varchar(100),
	@Notes			Varchar(1000) = Null
AS
BEGIN
	BEGIN TRANSACTION

	INSERT INTO DHP_ApplicantDocumens
	       (Fk_DHP_DocumentId,
		Fk_ApplicantId,
		FileName,
		FullPath,
		Notes)
	VALUES (@Fk_DHP_DocumentId,
		@Fk_ApplicantId,
		@FileName,
		@FullPath,
		@Notes)

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @@IDENTITY
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN @@ERROR * -1
	END
END
GO