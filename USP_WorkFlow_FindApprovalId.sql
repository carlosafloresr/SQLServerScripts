SELECT * FROM KarmakIntegration WHERE KarmakIntegrationId = 774

USP_WorkFlow_FindApprovalId 'KIM', 774, 'CFLORES'

ALTER PROCEDURE [dbo].[USP_WorkFlow_FindApprovalId] 
		@ModuleId	Varchar(10), 
		@RegistroId	Int, 
		@UserId		Varchar(25)
AS
BEGIN
	DECLARE	@ApplicantId	Int
	SET		@ApplicantId = (SELECT	WFA.WorkFlowApprovalId
							FROM	View_KarmakIntegration KAR
									INNER JOIN View_WorkFlowApprovalLevels WFL ON KAR.InvoiceTotal BETWEEN WFL.MinAmount AND WFL.MaxAmount AND WFL.ModuleId = @ModuleId
									INNER JOIN (SELECT TOP 1 * FROM WorkFlowApprovedItems WHERE ModuleId = @ModuleId AND RecordId = @RegistroId ORDER BY ApprovedOn DESC) API ON API.ModuleId = @ModuleId AND KAR.KarmakIntegrationId = API.RecordId
									INNER JOIN WorkFlowApprovals WFA ON WFL.ApprovalLevel = WFA.ApprovalLevel AND WFL.ModuleId = WFA.ModuleId AND WFA.WorkFlowApprovalId = API.Fk_ApproverId
							WHERE	KAR.KarmakIntegrationId = @RegistroId)
	
	
	--SELECT TOP 1 WorkFlowApprovalId
	--						FROM (
	--						SELECT	WorkFlowApprovalId
	--						FROM	WorkFlowApprovals
	--						WHERE	ApprovalLevel = @Level
	--								AND ModuleId = @ModuleId
	--								AND RecordId = @UserId
	--						UNION
	--						SELECT	WorkFlowApprovalId
	--						FROM	WorkFlowApprovals
	--						WHERE	ApprovalLevel = @Level
	--								AND ModuleId = @ModuleId
	--								AND RecordId IN (SELECT DomainGroup FROM ILSSQL01.Intranet.dbo.DomainGroups WHERE UserId = @UserId)) RECS)
	RETURN @ApplicantId
END