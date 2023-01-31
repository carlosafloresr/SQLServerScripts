ALTER PROCEDURE USP_DriverDocumentsUsers
AS
SELECT	UserId
		,UserName
		,Inactive 
FROM	Users 
WHERE	UserName <> '' 
		AND Inactive = 0 
		AND UserId IN (SELECT Fk_UserId FROM UserModules WHERE Fk_ModuleId = 37) 
UNION
SELECT	UserId
		,UserName
		,Inactive 
FROM	Users 
WHERE	UserName <> '' 
		AND Inactive = 0 
		AND UserId IN (	SELECT	Fk_UserId
						FROM	UserGroups
						WHERE	Fk_GroupId IN (SELECT Fk_GroupId FROM GroupModules WHERE Fk_ModuleId = 37))
ORDER BY UserName