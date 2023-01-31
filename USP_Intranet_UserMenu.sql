ALTER PROCEDURE USP_Intranet_UserMenu
	@UserId	Varchar(25),
	@Level	Int,
	@Parent	Char(10) = Null
AS
IF @Level = 1
BEGIN
	SELECT	DISTINCT AP.AppGroup, AP.NodeGroup AS NodeId, Counter
	FROM	Modules MO
			INNER JOIN Applications AP ON MO.Category = AP.ApplicationId
			INNER JOIN (SELECT	AP.AppGroup,
								SUM(1) AS Counter
						FROM	Modules MO
								INNER JOIN Applications AP ON MO.Category = AP.ApplicationId
						WHERE	MO.Inactive = 0 AND
								(MO.ModuleId IN (SELECT Fk_ModuleId FROM UserModules WHERE Fk_UserId = @UserId) OR
								MO.ModuleId IN (SELECT Fk_ModuleId FROM GroupModules WHERE Fk_GroupId IN (SELECT DISTINCT Fk_GroupId from UserGroups where Fk_GroupId > 0 AND Fk_UserId = @UserId)))
						GROUP BY AP.AppGroup) SU ON AP.AppGroup = SU.AppGroup
	WHERE	MO.Inactive = 0 AND
			(MO.ModuleId IN (SELECT Fk_ModuleId FROM UserModules WHERE Fk_UserId = @UserId) OR
			MO.ModuleId IN (SELECT Fk_ModuleId FROM GroupModules WHERE Fk_GroupId IN (SELECT DISTINCT Fk_GroupId from UserGroups where Fk_GroupId > 0 AND Fk_UserId = @UserId)))
	ORDER BY 1
END

IF @Level = 2
BEGIN
	SELECT	MO.Category,
			AP.Application AS ModuleName,
			AP.Application,
			AP.AppGroup,
			AP.NodeGroup AS Parent,
			'SUB_' + AP.NodeId AS NodeId,
			COUNT(MO.ModuleId) AS Counter
	FROM	Modules MO
			INNER JOIN Applications AP ON MO.Category = AP.ApplicationId
	WHERE	MO.Inactive = 0 AND
			(MO.ModuleId IN (SELECT Fk_ModuleId FROM UserModules WHERE Fk_UserId = @UserId) OR
			MO.ModuleId IN (SELECT Fk_ModuleId FROM GroupModules WHERE Fk_GroupId IN (SELECT DISTINCT Fk_GroupId from UserGroups where Fk_GroupId > 0 AND Fk_UserId = @UserId)))
			AND (@Parent IS Null OR (@Parent IS NOT Null AND AP.NodeGroup = @Parent))
	GROUP BY
			MO.Category,
			AP.Application,
			AP.AppGroup,
			AP.NodeGroup,
			AP.NodeId
	--HAVING	COUNT(MO.ModuleId) > 1
	ORDER BY 3, 1
END

IF @Level = 3
BEGIN
	SELECT	MO.ModuleId,
			MO.ModuleName,
			RTRIM(AP.AppLocation) + '/' + MO.HtmlText AS HtmlText,
			MO.Category,
			AP.Application,
			AP.AppGroup,
			MO.Inactive,
			'AP' AS RecordType,
			Null AS ReportType,
			CASE WHEN Counter = 1 OR AP.Application = AP.AppGroup THEN AP.NodeGroup ELSE 'SUB_' + AP.NodeId END AS Parent,
			Counter,
			'AP_' + RTRIM(CAST(MO.ModuleId AS Char(10))) AS NodeId
	FROM	Modules MO
			INNER JOIN Applications AP ON MO.Category = AP.ApplicationId
			INNER JOIN (SELECT	MO.Category,
								AP.Application,
								AP.AppGroup,
								COUNT(MO.ModuleId) AS Counter
						FROM	Modules MO
								INNER JOIN Applications AP ON MO.Category = AP.ApplicationId
						WHERE	MO.Inactive = 0 AND
								(MO.ModuleId IN (SELECT Fk_ModuleId FROM UserModules WHERE Fk_UserId = @UserId) OR
								MO.ModuleId IN (SELECT Fk_ModuleId FROM GroupModules WHERE Fk_GroupId IN (SELECT DISTINCT Fk_GroupId from UserGroups where Fk_GroupId > 0 AND Fk_UserId = @UserId)))
						GROUP BY
								MO.Category,
								AP.Application,
								AP.AppGroup) SU ON MO.Category = SU.Category AND AP.AppGroup = SU.AppGroup
	WHERE	MO.Inactive = 0 AND
			(MO.ModuleId IN (SELECT Fk_ModuleId FROM UserModules WHERE Fk_UserId = @UserId) OR
			MO.ModuleId IN (SELECT Fk_ModuleId FROM GroupModules WHERE Fk_GroupId IN (SELECT DISTINCT Fk_GroupId from UserGroups where Fk_GroupId > 0 AND Fk_UserId = @UserId)))
			AND (@Parent IS Null OR (@Parent IS NOT Null AND CASE WHEN Counter = 1 OR AP.Application = AP.AppGroup THEN AP.NodeGroup ELSE 'SUB_' + AP.NodeId END = @Parent))
	ORDER BY 6, 8, 4
END
--UNION
--SELECT	ReportId,
--		ReportName,
--		FullPath,
--		ReportFolder,
--		ReportFolder,
--		'ILS Reporting Services',
--		Inactive,
--		'RE' AS RecordType,
--		ReportType
--FROM	Reports
--WHERE	Inactive = 0 AND
--		(ReportId IN (SELECT Fk_ReportId FROM UserReports WHERE Fk_UserId = @UserId) OR
--		ReportId IN (SELECT Fk_ReportId FROM GroupReports WHERE Fk_GroupId IN (SELECT DISTINCT Fk_GroupId from UserGroups where Fk_GroupId > 0 AND Fk_UserId = @UserId)))

/*
DECLARE	@UserId		Varchar(25)
SET		@UserId = 'CFLORES'
SELECT * FROM UserModules
SELECT * FROM UserReports

select * from GroupModules
SELECT DISTINCT Fk_GroupId from UserGroups where Fk_GroupId > 0 AND Fk_UserId = 'MBAKER'
SELECT * FROM Groups
EXECUTE USP_Intranet_UserMenu 'cflores', 1
EXECUTE USP_Intranet_UserMenu 'cflores', 2
EXECUTE USP_Intranet_UserMenu 'cflores', 3, 'PAYROLL'
*/