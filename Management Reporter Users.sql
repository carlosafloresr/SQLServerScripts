SELECT	[UserName],
		CASE [RoleType] WHEN 5 THEN 'Administrator'
		WHEN 4 THEN 'Designer'
		WHEN 3 THEN 'Generator'
		WHEN 2 THEN 'Viewer'
		ELSE '' END AS Role,
		ISNULL(DU.UserId, '** Unmatched ** ') AS UserId,
		CASE WHEN ISNUMERIC(LEFT(DU.Name, 6)) = 1 THEN 'Inactive' WHEN DU.UserId IS Null THEN 'Unknow' ELSE 'Active' END AS Status
FROM	[ManagementReporter].[Reporting].[SecurityUser] MR
		LEFT JOIN PRISQL01P.GPCustom.dbo.DomainUsers DU ON MR.WindowsSecurityIdentifier = DU.strSID
		ORDER BY 1