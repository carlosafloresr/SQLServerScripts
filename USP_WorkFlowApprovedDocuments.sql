/*
EXECUTE USP_WorkFlowApprovedDocuments 'KIM', '250,251,252,'

select KarmakIntegrationId, ',' + RTRIM(CAST(KarmakIntegrationId AS Varchar(10))) + ',', dbo.at(',' + RTRIM(CAST(KarmakIntegrationId AS Varchar(10))) + ',', ',250,251,252,', 1) as test from KarmakIntegration
*/		
ALTER PROCEDURE [dbo].[USP_WorkFlowApprovedDocuments]
		@ModuleId		Varchar(10),
		@Documents		Varchar(2000)
AS
SET		@Documents = ',' + @Documents
SELECT	*
FROM	(
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
				,ISNULL(WFA.RecordId, KIN.ApprovedBy) AS UserId
				,USR.UserName
				,WFL.ApprovalLevel
		FROM	KarmakIntegration KIN
				LEFT JOIN View_WorkFlowApprovalLevels WFL ON KIN.InvoiceTotal BETWEEN WFL.MinAmount AND WFL.MaxAmount AND WFL.ModuleId = @ModuleId
				LEFT JOIN WorkFlowApprovals WFA ON WFL.ApprovalLevel = WFA.ApprovalLevel AND WFA.ModuleId = @ModuleId AND WFA.RecordType = 'U'
				LEFT JOIN ILSSQL01.Intranet.dbo.Users USR ON WFA.RecordId = USR.UserId AND USR.ForEmail = 1
		WHERE	dbo.AT(',' + RTRIM(CAST(KIN.KarmakIntegrationId AS Varchar(10))) + ',', @Documents, 1) > 0
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
				,ISNULL(WFA.RecordId, KIN.ApprovedBy) AS UserId
				,USR.UserName
				,WFL.ApprovalLevel
		FROM	KarmakIntegration KIN
				LEFT JOIN View_WorkFlowApprovalLevels WFL ON KIN.InvoiceTotal BETWEEN WFL.MinAmount AND WFL.MaxAmount AND WFL.ModuleId = @ModuleId
				LEFT JOIN WorkFlowApprovals WFA ON WFL.ApprovalLevel = WFA.ApprovalLevel AND WFA.ModuleId = @ModuleId AND WFA.RecordType = 'G'
				LEFT JOIN ILSSQL01.Intranet.dbo.DomainGroups DGR ON WFA.RecordId = DGR.DomainGroup
				LEFT JOIN ILSSQL01.Intranet.dbo.Users USR ON DGR.UserId = USR.UserId AND USR.ForEmail = 1
		WHERE	dbo.AT(',' + RTRIM(CAST(KIN.KarmakIntegrationId AS Varchar(10))) + ',', @Documents, 1) > 0) RECS
WHERE	UserId IS NOT Null
		AND UserName IS NOT Null
ORDER BY
		ApprovalLevel
		,InvoiceNumber
		,UserName