ALTER PROCEDURE USP_DHP_UserModules
	@Fk_DHP_ModuleId	Int,
	@Fk_UserId		Varchar(25),
	@RO			Bit,
	@AD			Bit,
	@MO			Bit,
	@DE			Bit
AS
IF (@RO IS NULL OR @RO = 0) AND (@AD IS NULL OR @AD = 0) AND (@MO IS NULL OR @MO = 0) AND (@DE IS NULL OR @DE = 0)
	DELETE DHP_UserModules WHERE Fk_DHP_ModuleId = @Fk_DHP_ModuleId AND Fk_UserId = @Fk_UserId
ELSE
BEGIN
	IF EXISTS (SELECT DHP_UserModuleId FROM DHP_UserModules WHERE Fk_DHP_ModuleId = @Fk_DHP_ModuleId AND Fk_UserId = @Fk_UserId)
	BEGIN
		BEGIN TRANSACTION

		UPDATE	DHP_UserModules
		SET	RO		= @RO,
			AD		= @AD,
			MO		= @MO,
			DE		= @DE
		WHERE	Fk_DHP_ModuleId = @Fk_DHP_ModuleId AND 
			Fk_UserId 	= @Fk_UserId

		IF @@ERROR = 0
		BEGIN
			COMMIT TRANSACTION
			RETURN 1
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

		INSERT INTO DHP_UserModules (
			Fk_DHP_ModuleId,
			Fk_UserId,
			RO,
			AD,
			MO,
			DE)
		VALUES (@Fk_DHP_ModuleId,
			@Fk_UserId,
			@RO,
			@AD,
			@MO,
			@DE)

		IF @@ERROR = 0
		BEGIN
			COMMIT TRANSACTION
			RETURN 1
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			RETURN @@ERROR * -1
		END
	END
END
GO