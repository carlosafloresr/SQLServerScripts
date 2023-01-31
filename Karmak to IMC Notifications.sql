/*
SELECT * FROM WorkFlowApprovals

SELECT * FROM WorkFlowApprovedItems

SELECT	KIN.*
FROM	KarmakIntegration KIN
WHERE	Processed = 2
		AND CustomerNumber NOT IN ('AIS','GIS','RCMR')
		AND Approved = 1
		--AND KIN.InvoiceNumber BETWEEN '5900' AND '6000'
ORDER BY InvoiceNumber		

SELECT	KIN.InvoiceNumber
		,KIN.KarmakIntegrationId
		,KIN.InvoicedDate
		,KIN.UnitNumber
		,KIN.CustomerNumber
		,KIN.Labor
		,KIN.Fuel_Price AS Fuel
		,KIN.Tires_Price AS Tires
		,KIN.Misc_Price AS Misc
		,KIN.Parts_Price AS Parts
		,KIN.Shop_Price AS Shop
		,KIN.Fees_Price AS Fees
		,KIN.InvoiceTotal
FROM	WorkFlowApprovedItems WAI
		INNER JOIN KarmakIntegration KIN ON WAI.RecordId = KIN.KarmakIntegrationId
		INNER JOIN WorkFlowApprovals WFA ON WAI.Fk_ApproverId = WFA.WorkFlowApprovalId AND WFA.ModuleId = 'KIM' AND WFA.RecordType = 'U'
		
EXECUTE USP_WorkFlowApprovedDocuments 'KIM', '5845,5847,5852,'
*/		
ALTER PROCEDURE USP_WorkFlowApprovedDocuments
		@ModuleId		Varchar(10),
		@Documents		Varchar(2000)
AS
SELECT	KIN.KarmakIntegrationId
		,KIN.InvoiceNumber
		,KIN.InvoicedDate
		,KIN.UnitNumber
		,KIN.CustomerNumber
		,KIN.Labor
		,KIN.Fuel_Price AS Fuel
		,KIN.Tires_Price AS Tires
		,KIN.Misc_Price AS Misc
		,KIN.Parts_Price AS Parts
		,KIN.Shop_Price AS Shop
		,KIN.Fees_Price AS Fees
		,KIN.InvoiceTotal
		,WFA.RecordId AS UserId
		,USR.UserName
		,WFA.ApprovalLevel
FROM	WorkFlowApprovedItems WAI
		INNER JOIN KarmakIntegration KIN ON WAI.RecordId = KIN.KarmakIntegrationId
		INNER JOIN WorkFlowApprovals WFA ON WAI.Fk_ApproverId = WFA.WorkFlowApprovalId AND WFA.ModuleId = @ModuleId AND WFA.RecordType = 'U'
		INNER JOIN ILSSQL01.Intranet.dbo.Users USR ON WFA.RecordId = USR.UserId AND USR.ForEmail = 1
WHERE	WAI.ModuleId = @ModuleId
		AND dbo.AT(KIN.InvoiceNumber, @Documents, 1) > 0
UNION
SELECT	KIN.KarmakIntegrationId
		,KIN.InvoiceNumber
		,KIN.InvoicedDate
		,KIN.UnitNumber
		,KIN.CustomerNumber
		,KIN.Labor
		,KIN.Fuel_Price AS Fuel
		,KIN.Tires_Price AS Tires
		,KIN.Misc_Price AS Misc
		,KIN.Parts_Price AS Parts
		,KIN.Shop_Price AS Shop
		,KIN.Fees_Price AS Fees
		,KIN.InvoiceTotal
		,DGR.UserId
		,USR.UserName
		,WFA.ApprovalLevel
FROM	WorkFlowApprovedItems WAI
		INNER JOIN KarmakIntegration KIN ON WAI.RecordId = KIN.KarmakIntegrationId
		INNER JOIN WorkFlowApprovals WFA ON WAI.Fk_ApproverId = WFA.WorkFlowApprovalId AND WFA.ModuleId = @ModuleId AND WFA.RecordType = 'G'
		INNER JOIN ILSSQL01.Intranet.dbo.DomainGroups DGR ON WFA.RecordId = DGR.DomainGroup
		INNER JOIN ILSSQL01.Intranet.dbo.Users USR ON DGR.UserId = USR.UserId AND USR.ForEmail = 1
WHERE	WAI.ModuleId = @ModuleId
		AND dbo.AT(KIN.InvoiceNumber, @Documents, 1) > 0
ORDER BY
		WFA.ApprovalLevel
		,KIN.InvoiceNumber
		,USR.UserName
		
