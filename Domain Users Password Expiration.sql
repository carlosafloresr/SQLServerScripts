/*
EXECUTE USP_DomainUsers_Expiration
*/
CREATE PROCEDURE USP_DomainUsers_Expiration
AS
DECLARE	@ExpDays	Varchar(50) = (SELECT RTRIM(VarC) + ',' FROM Parameters WHERE ParameterCode = 'PASSWEXP_DAYS'),
		@ExpStart	Int

SET @ExpStart = CAST(LEFT(@ExpDays, dbo.AT(',', @ExpDays, 1) - 1) AS Int)
print @ExpStart

SELECT	Company, 
		UserId, 
		Name, 
		Mail, 
		PasswordExpiration, 
		PwdLastSet, 
		ExpirationDays,
		CAST(DATEADD(dd, 90, PwdLastSet) AS Date) AS ExpirationDate
FROM	View_DomainUsers
WHERE	Inactive = 0 
		--AND PasswordExpiration <= @ExpStart
		AND (dbo.AT(CAST(ExpirationDays AS Varchar) + ',', @ExpDays, 1) > 0 
		OR ExpirationDays < 0)
ORDER BY PasswordExpiration DESC, UserId