/*
EXECUTE USP_EFS_ApprovalLevels 'GIS'
*/
ALTER PROCEDURE USP_EFS_ApprovalLevels (@Company Varchar(5))
AS
SELECT	UserId,
		DisplayName,
		ISNULL(Location, Company) AS Location,
		Inactive,
		0.00 AS ApprovalAmount,
		CAST(0 AS Bit) AS InFile
FROM	DomainUsers
WHERE	Company = @Company
		AND Inactive = 0
		AND UserId NOT IN (SELECT Fk_UserId FROM Intranet.dbo.UserApprovalLevels)
UNION
SELECT	UserId,
		DisplayName,
		ISNULL(Location, Company) AS Location,
		DOU.Inactive,
		ApprovalAmount,
		CAST(1 AS Bit) AS InFile
FROM	DomainUsers DOU
		INNER JOIN Intranet.dbo.UserApprovalLevels UAL ON DOU.UserId = UAL.Fk_UserId
WHERE	Company = @Company
ORDER BY DisplayName