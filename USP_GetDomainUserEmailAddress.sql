/*
EXECUTE USP_GetDomainUserEmailAddress 'JTOVO'
*/
CREATE PROCEDURE USP_GetDomainUserEmailAddress (@UserId Varchar(25))
AS
SELECT	Mail AS EMailAddress
FROM	DomainUsers
WHERE	UserId = @UserId