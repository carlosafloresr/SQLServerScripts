/*
SELECT	*
FROM	SY01400

EXEC sp_addrolemember 'DYNGRP', 'CFLORES'

ALTER ROLE [DYNGRP] ADD MEMBER CFLORES;
*/
/*
EXECUTE USP_DYNGRP_AddUser 'johnvan'
*/
ALTER PROCEDURE USP_DYNGRP_AddUser
		@UserId			Varchar(30)
AS
SET NOCOUNT ON

DECLARE @Query			Varchar(200)
DECLARE @tblRoleUsers	Table (UserId Varchar(30))

INSERT INTO @tblRoleUsers
SELECT	ISNULL(DP2.name, 'No members') AS DatabaseUserName   
FROM	sys.database_role_members DRM  
		RIGHT OUTER JOIN sys.database_principals DP1 ON DRM.role_principal_id = DP1.principal_id  
		LEFT OUTER JOIN sys.database_principals DP2 ON DRM.member_principal_id = DP2.principal_id  
WHERE	DP1.type = 'R' AND DP1.name = 'DYNGRP'
ORDER BY DP2.name

IF NOT EXISTS(SELECT UserId FROM @tblRoleUsers WHERE UserId = @UserId)
BEGIN
	SET @Query = N'GRANT DYNGRP TO ' + RTRIM(@UserId)
	EXECUTE(@Query)

	SET @Query = N'EXEC sp_addrolemember ''DYNGRP'', ''' + RTRIM(@UserId) + ''''
	EXECUTE(@Query)
END