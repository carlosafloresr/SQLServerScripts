/*
EXECUTE USP_FindWorkFlowApprovalRecords 'KIM', 3, 1, 1
*/
ALTER PROCEDURE USP_FindWorkFlowApprovalRecords
		@ModuleId		Varchar(5),
		@ApprovalLevel	Int,
		@Assigned		Bit,
		@OnlyApprovers	Bit = 1
AS
IF @Assigned = 0
BEGIN
	SELECT	UserId AS RecordId 
			,RTRIM(UserName) + '  [USER]' AS [Description]
	FROM	ILSSQL01.Intranet.dbo.Users 
	WHERE	Inactive = 0 
			AND UserName <> '' 
			AND LEN(UserId) > 3 
			AND UserId NOT IN (SELECT RecordId FROM WorkFlowApprovals WHERE ModuleId = @ModuleId AND RecordType = 'U' AND ApprovalLevel = @ApprovalLevel AND Approver = @OnlyApprovers)
	UNION
	SELECT	DISTINCT DomainGroup AS RecordId 
			,RTRIM(DomainGroup) + '  [GROUP]' AS [Description]
	FROM	ILSSQL01.Intranet.dbo.DomainGroups
	WHERE	DomainGroup NOT IN (SELECT RecordId FROM WorkFlowApprovals WHERE ModuleId = @ModuleId AND RecordType = 'G' AND ApprovalLevel = @ApprovalLevel AND Approver = @OnlyApprovers)
	ORDER BY 2
END
ELSE
BEGIN
	SELECT	UserId AS RecordId 
			,RTRIM(UserName) + '  [USER]' AS [Description]
	FROM	ILSSQL01.Intranet.dbo.Users 
	WHERE	Inactive = 0 
			AND UserName <> '' 
			AND LEN(UserId) > 3 
			AND UserId IN (SELECT RecordId FROM WorkFlowApprovals WHERE ModuleId = @ModuleId AND RecordType = 'U' AND ApprovalLevel = @ApprovalLevel AND Approver = @OnlyApprovers)
	UNION
	SELECT	DISTINCT DomainGroup AS RecordId 
			,RTRIM(DomainGroup) + '  [GROUP]' AS [Description]
	FROM	ILSSQL01.Intranet.dbo.DomainGroups
	WHERE	DomainGroup IN (SELECT RecordId FROM WorkFlowApprovals WHERE ModuleId = @ModuleId AND RecordType = 'G' AND ApprovalLevel = @ApprovalLevel AND Approver = @OnlyApprovers)
	ORDER BY 2
END