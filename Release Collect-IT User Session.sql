DECLARE	@UserId Varchar(15) = 'unlock'

UPDATE	CS_User 
SET		IsUserLogin = 0 
WHERE	UserName = @UserId

/*
SELECT	*
FROM	CS_User
*/