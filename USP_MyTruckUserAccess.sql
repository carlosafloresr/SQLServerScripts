/*
EXECUTE USP_MyTruckUserAccess 'CFLORES'
*/
ALTER PROCEDURE USP_MyTruckUserAccess (@UserId Varchar(25))
AS
DECLARE	@ReturnValue	Varchar(10),
		@ReturnType		Char(1)

IF EXISTS(SELECT Fk_ModuleId FROM UserModules WHERE Fk_UserId = @UserId AND Fk_ModuleId = 109) OR EXISTS(SELECT Fk_ModuleId FROM GroupModules WHERE Fk_ModuleId = 109 AND Fk_GroupId IN (SELECT Fk_GroupID FROM UserGroups WHERE Fk_UserId = @UserId))
BEGIN
	SET @ReturnValue = 'Internal'
	SET @ReturnType	 = 'I'
END
ELSE
BEGIN
	IF EXISTS(SELECT Fk_ModuleId FROM UserModules WHERE Fk_UserId = @UserId AND Fk_ModuleId = 110) OR EXISTS(SELECT Fk_ModuleId FROM GroupModules WHERE Fk_ModuleId = 110 AND Fk_GroupId IN (SELECT Fk_GroupID FROM UserGroups WHERE Fk_UserId = @UserId))
	BEGIN
		SET @ReturnValue = 'External'
		SET @ReturnType	 = 'E'
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT Fk_ModuleId FROM UserModules WHERE Fk_UserId = @UserId AND Fk_ModuleId = 111) OR EXISTS(SELECT Fk_ModuleId FROM GroupModules WHERE Fk_ModuleId = 111 AND Fk_GroupId IN (SELECT Fk_GroupID FROM UserGroups WHERE Fk_UserId = @UserId))
		BEGIN
			SET @ReturnValue = 'Accounting'
			SET @ReturnType	 = 'A'
		END
		ELSE
		BEGIN
			SET @ReturnValue = 'No Access'
			SET @ReturnType	 = 'N'
		END
	END
END

SELECT	@ReturnType AS RoleType, @ReturnValue AS Role
		