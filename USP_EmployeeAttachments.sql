CREATE PROCEDURE USP_EmployeeAttachments
		@EmployeeAttachmentId	Int,
		@Employid				Varchar(15),
		@CompanyID				Int,
		@Fk_DocumentTypeId		Int,
		@object_id				Bigint,
		@object_type			Varchar(10),
		@object_name			Varchar(250),
		@object_content			Image,
		@object_length			Int,
		@object_mime			Varchar(50),
		@object_description		Varchar(500),
		@Created_By				Varchar(50)
AS
IF @EmployeeAttachmentId IS NULL
BEGIN
	BEGIN TRANSACTION
	
	INSERT INTO EmployeeAttachments
           (Employid
           ,CompanyID
           ,Fk_DocumentTypeId
           ,object_id
           ,object_type
           ,object_name
           ,object_content
           ,object_length
           ,object_mime
           ,object_description
           ,Created_By)
     VALUES
           (@Employid
           ,@CompanyID
           ,@Fk_DocumentTypeId
           ,@object_id
           ,@object_type
           ,@object_name
           ,@object_content
           ,@object_length
           ,@object_mime
           ,@object_description
           ,@Created_By)
           
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
	
	UPDATE	EmployeeAttachments
	SET		object_description		= @object_description
	WHERE	EmployeeAttachmentId	= @EmployeeAttachmentId
	
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @EmployeeAttachmentId
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END
END
