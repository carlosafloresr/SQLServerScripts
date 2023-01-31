/*
EXECUTE USP_User_Integrations_Save @UserId='CFLORES',@Integration='FSIP'
*/
ALTER PROCEDURE USP_User_Integrations_Save
		@UserId			Varchar(25),
		@GPModule		Varchar(10) = Null,
		@Integration	Varchar(10) = Null,
		@Delete			Bit = 0
AS
IF @Integration IS NULL
BEGIN
	IF EXISTS(SELECT UserId FROM User_GPModules WHERE GPModule = @GPModule AND UserId = @UserId) AND @Delete = 1
	BEGIN
		DELETE	User_GPModules 
		WHERE	UserId = @UserId
				AND GPModule = @GPModule

		DELETE	User_Integrations
		WHERE	UserId = @UserId
				AND Integration IN (SELECT Integration FROM Integrations WHERE GPModule = @GPModule)
	END

	IF NOT EXISTS(SELECT UserId FROM User_GPModules WHERE GPModule = @GPModule AND UserId = @UserId) AND @Delete = 0
		INSERT INTO User_GPModules (UserId, GPModule) VALUES (@UserId, @GPModule)

END
ELSE
BEGIN
	IF EXISTS(SELECT UserId FROM User_Integrations WHERE Integration = @Integration AND UserId = @UserId) AND @Delete = 1
	BEGIN
		DELETE	User_Integrations
		WHERE	UserId = @UserId
				AND Integration = @Integration
	END

	IF NOT EXISTS(SELECT UserId FROM User_Integrations WHERE Integration = @Integration AND UserId = @UserId) AND @Delete = 0
		INSERT INTO User_Integrations (UserId, Integration) VALUES (@UserId, @Integration)
END