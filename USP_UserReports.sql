USE [Intranet]
GO
/****** Object:  StoredProcedure [dbo].[USP_UserReports]    Script Date: 01/26/2009 13:39:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_UserReports] (@UserID Varchar(25))
AS
SELECT 	ReportId AS NodeId, 
	Parent, 
	ReportName AS Name, 
	ReportType, 
	FullPath,
	CustomFilter
FROM 	Reports
WHERE	ReportId IN (SELECT Fk_ReportId FROM UserReports INNER JOIN Users ON UserReports.Fk_UserId = Users.UserId WHERE Users.Inactive = 0 AND Fk_UserId = @UserID) OR 
	ReportId IN (SELECT Fk_ReportId FROM GroupReports WHERE Fk_GroupId IN 
	(SELECT Fk_GroupID FROM UserGroups INNER JOIN Groups ON UserGroups.Fk_GroupId = Groups.GroupId WHERE Groups.Inactive = 0 AND Fk_UserId = @UserID)) AND
	Reports.Inactive = 0
UNION
SELECT 	DISTINCT Parent AS NodeId, 
	Null AS Parent, 
	ReportFolder AS Name, 
	ReportType, 
	'' AS FullPath,
	CustomFilter
FROM 	Reports
WHERE	ReportId IN (SELECT Fk_ReportId FROM UserReports INNER JOIN Users ON UserReports.Fk_UserId = Users.UserId WHERE Users.Inactive = 0 AND Fk_UserId = @UserID) OR 
	ReportId IN (SELECT Fk_ReportId FROM GroupReports WHERE Fk_GroupId IN 
	(SELECT Fk_GroupID FROM UserGroups INNER JOIN Groups ON UserGroups.Fk_GroupId = Groups.GroupId WHERE Groups.Inactive = 0 AND Fk_UserId = @UserID)) AND
	Reports.Inactive = 0
ORDER BY Parent, Name

USP_UserReports 'cflores'