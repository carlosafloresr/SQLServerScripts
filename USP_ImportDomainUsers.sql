USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_ImportDomainUsers]    Script Date: 2/18/2022 12:20:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_ImportDomainUsers
*/
ALTER PROCEDURE [dbo].[USP_ImportDomainUsers]
AS
DECLARE @nAsciiValue	smallint,
		@sChar			char(1),
		@Query			varchar(2500)

SET NOCOUNT ON

SELECT	* 
INTO	#tmpADUsers
FROM	OPENQUERY(ADSI, 'SELECT ObjectSID, givenName, sn, mail, name, displayName, samAccountName, company, telephoneNumber, physicalDeliveryOfficeName, 
		department, title, l, st, streetAddress, PostalCode, userAccountControl, extensionAttribute1, PwdLastSet
		FROM ''LDAP://DC=iilogistics,DC=com'' WHERE objectCategory = ''Person'' AND objectClass = ''personal'' AND msExchRecipientTypeDetails = 1 ORDER BY name') TEST
WHERE	Mail IS NOT Null 
		AND samAccountName IS NOT Null
		AND SN IS NOT Null

SELECT @nAsciiValue = 65

WHILE @nAsciiValue < 91
BEGIN
	SELECT @sChar= CHAR(@nAsciiValue)
	
	SET @Query = REPLACE('SELECT * FROM OPENQUERY(ADSI, ''SELECT ObjectSID, givenName, sn, mail, name, displayName, samAccountName, company, telephoneNumber, physicalDeliveryOfficeName, 
		department, title, l, st, streetAddress, PostalCode, userAccountControl, extensionAttribute1, PwdLastSet
		FROM ''''LDAP://DC=iilogistics,DC=com'''' WHERE objectCategory = ''''Person'''' AND objectClass = ''''person'''' AND SAMAccountName = ''''%s*'''' ORDER BY name'') TEST
		WHERE Mail IS NOT Null 
		AND samAccountName IS NOT Null
		AND SN IS NOT Null', '%s', @sChar)

	INSERT #tmpADUsers
	EXECUTE(@Query)

	SELECT @nAsciiValue = @nAsciiValue + 1
END

TRUNCATE TABLE DomainUsers

INSERT INTO DomainUsers
SELECT	LEFT(GivenName, 25) AS GivenName
		,LEFT(SN, 25) AS SN
		,RTRIM(LEFT(LOWER(Mail), 100)) AS Mail
		,RTRIM(dbo.PROPER(LEFT(Name, 50))) AS Name
		,RTRIM(dbo.PROPER(LEFT(DisplayName, 50))) AS DisplayName
		,RTRIM(LEFT(LOWER(samAccountName), 25)) AS UserId
		,LEFT(Company, 50) AS Company
		,dbo.FormatPhoneNumber(LEFT(TelephoneNumber, 25)) AS TelephoneNumber
		,LEFT(ISNULL(PhysicalDeliveryOfficeName, extensionAttribute1), 250) AS Location
		,Department
		,Title
		,L AS PhysicalLocation
		,ST AS [State]
		,StreetAddress
		,PostalCode
		,CAST(CASE WHEN userAccountControl = 514 THEN 1 ELSE 0 END AS Bit) AS Inactive
		,null AS TelephoneNumber2
		,null AS Mobile
		,dbo.fn_SIDToString(ObjectSID)
		,dbo.fn_GetDatetimeFromADTimestamp(PwdLastSet, 1)
		,ISNULL(DATEDIFF(Day, dbo.fn_GetDatetimeFromADTimestamp(PwdLastSet, 1), GETDATE()),0)
FROM	#tmpADUsers
WHERE	Company NOT IN ('SERV', 'SHARED', 'INFO', 'N/A', '???', 'TEST', 'SM_c3a1800094a845c2b', 'PRIV', 'EXT', 'TEMP')

DROP TABLE #tmpADUsers

PRINT 'Updating Fields...'

UPDATE	DomainUsers
SET		Inactive = CASE WHEN Inactive = 0 AND LEFT(DisplayName, 2) = '20' THEN 1 ELSE Inactive END,
		UserId = LOWER(UserId),
		Department = ISNULL(Department, ''),
		Location = CASE WHEN Location IS Null AND Company IS Not Null THEN CASE WHEN Company LIKE 'IMC Companies%' THEN 'IMCC' ELSE RTRIM(Company) END + ' - ' + RTRIM(PhysicalLocation) ELSE Location END

UPDATE	DomainUsers
SET		Company = CASE	WHEN Company LIKE '%ILS%' THEN 'IMCC'
						WHEN Company LIKE '%NDS%' THEN 'NDS' 
						ELSE Company END
WHERE	Company IS NOT Null

UPDATE	DomainUsers
SET		Company = DATA.CompanyId
FROM	(
		SELECT	VCA.CompanyId,
				DOU.UserId AS [User_Id]
		FROM	DomainUsers DOU
				LEFT JOIN View_CompaniesAndAgents VCA ON DOU.Mail LIKE '%@' + VCA.WebAddress + '%'
		) DATA
WHERE	UserId = DATA.[User_Id]

UPDATE	DomainUsers
SET		Location = Company
WHERE	Location IS Null

