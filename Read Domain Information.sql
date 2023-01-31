ALTER PROCEDURE USP_ImportDomainUsers
AS
SELECT	GivenName
		,SN
		,Mail
		,Name
		,RTRIM(LEFT(MailNickname, 25)) AS UserId
		,Company
		,TelephoneNumber
		,PhysicalDeliveryOfficeName AS Location
		,Department
		,Title
		,L AS PhysicalLocation
		,ST AS [State]
		,StreetAddress
		,PostalCode
INTO	#TempUsers
FROM	OPENQUERY (ADSI, 'SELECT givenName, sn, mail, name, mailNickname, company, 
		telephoneNumber, physicalDeliveryOfficeName, department, title, l, st, streetAddress, PostalCode
		FROM ''LDAP://DC=iilogistics,DC=com'' WHERE objectclass= ''person'' order by sn')
WHERE	Mail IS NOT Null 
		AND MailNickname IS NOT Null
ORDER BY Name

DELETE DomainUsers

INSERT INTO DomainUsers
SELECT * FROM #TempUsers

DROP TABLE #TempUsers
/*
EXECUTE USP_ImportDomainUsers

SELECT * FROM DomainUsers ORDER BY Department

Select A.displayName, A.mail, A.company, A.department, A.telephoneNumber, A.postalCode, A.physicalDeliveryOfficeName
FROM(
SELECT * FROM OPENQUERY( ADSI, 
    'SELECT displayName, mail, company, department, telephoneNumber, postalCode, physicalDeliveryOfficeName
     FROM ''LDAP://DC=IILOGISTICS,DC=com'' 
     WHERE objectCategory = ''Person'' AND objectClass = ''user''')
) A
WHERE A.company IS NOT NULL
order by A.company, A.displayName

*/