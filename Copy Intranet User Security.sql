CREATE PROCEDURE USP_CopayUserSecurity
		@FromUser	Varchar(25),
		@ToUser		Varchar(25)
AS
INSERT INTO UserModules
SELECT	@ToUser AS Fk_UserId,
		FK_ModuleId
FROM	UserModules
WHERE	Fk_UserId = @FromUser
		AND RTRIM(@ToUser) + '-' + dbo.PADL(FK_ModuleId, 5, '0') NOT IN (SELECT RTRIM(Fk_UserId) + '-' + dbo.PADL(FK_ModuleId, 5, '0') FROM UserModules)

INSERT INTO UserGroups
SELECT	@ToUser AS Fk_UserId,
		Fk_GroupID,
		GroupName
FROM	UserGroups
WHERE	Fk_UserId = @FromUser
		AND RTRIM(@ToUser) + '-' + dbo.PADL(Fk_GroupID, 5, '0') + '-' + RTRIM(GroupName) NOT IN (SELECT RTRIM(Fk_UserId) + '-' + dbo.PADL(Fk_GroupID, 5, '0') + '-' + RTRIM(GroupName) FROM UserGroups)