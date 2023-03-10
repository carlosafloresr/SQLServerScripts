/*
SELECT * FROM WorkFlowApprovals
SELECT * FROM WorkFlowApprovedItems
SELECT * FROM KarmakIntegration KAR
*/
SELECT	WFA.RecordType
		,WFA.RecordId
		,WFA.ApprovalLevel
		,WFA.Priority
		,API.RecordId
		,API.ApprovedOn
		,KAR.KarmakIntegrationId
FROM	KarmakIntegration KAR
		LEFT JOIN WorkFlowApprovals WFA ON WFA.ModuleId = 'KIM'
		LEFT JOIN WorkFlowApprovedItems API ON WFA.ModuleId = API.ModuleId AND WFA.WorkFlowApprovalId = API.Fk_ApproverId
WHERE	WFA.ModuleId = 'KIM' 
		AND WFA.ApprovalLevel = 3
		AND WFA.Approver = 1 
ORDER BY KAR.InvoiceNumber, WFA.Priority