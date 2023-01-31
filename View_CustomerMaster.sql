USE [GPCustom]
GO

/****** Object:  View [dbo].[View_CustomerMaster]    Script Date: 3/28/2022 8:31:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
SELECT * FROM View_CustomerMaster WHERE CompanyId = 'AIS' AND ICB_CompanyNumber > 0
*/
ALTER VIEW [dbo].[View_CustomerMaster]
AS
SELECT	CM.CustomerMasterId
		,CM.CompanyId
		,CO.CompanyNumber
		,CO.SWSCustomers
		,CO.Trucking
		,CM.CustNmbr
		,CM.CustName
		,CM.CustClas
		,CM.Address1
		,CM.Address2
		,CM.City
		,CM.State
		,CM.Zip
		,CM.Phone1
		,CM.Inactive
		,CM.Hold
		,CM.CntCprsn
		,CM.SalsTerr
		,CM.AltShipperOnly
		,CM.InvoiceEmailOption
		,CASE InvoiceEmailOption WHEN 1 THEN 'Paper Invoice'
								 WHEN 2 THEN 'Email Invoicing - Multiple Pro and PDF per Email'
								 WHEN 3 THEN 'Email Invoicing - Multiple Pro on Single PDF per Email'
								 WHEN 4 THEN 'Email Invoicing - Multiple Pro on PDF per Email'
		ELSE 'Email Invoicing - Single Pro separated Support Docs per Email' END AS InvoiceEmailOptionType
		,CM.LastDateInvoicesSubmitted
		,ISNULL(CM.SWSCustomerId,'') AS SWSCustomerId
		,CM.BillType
		,CASE CM.BillType WHEN 0 THEN 'No Defined'
						  WHEN 1 THEN 'Principal'
						  WHEN 2 THEN 'Cargo Owner'
						  ELSE '3rd Party Logistics Provider' END AS PerDiem_BillType
		,CM.BillToAllLocations
		,CM.Changed
		,CM.Trasmitted
		,CM.ChangedBy
		,CM.Result
		,CM.DailyInvoicing
		,CM.PymTrmId
		,CM.PymTrmDays
		,ISNULL(FS.LinkedCompany, '') AS ICB_Company
		,IIF(C2.CompanyId IS Null, 0, C2.CompanyNumber) AS ICB_CompanyNumber
FROM	CustomerMaster CM
		INNER JOIN Companies CO ON CM.CompanyId = CO.CompanyId
		LEFT JOIN IntegrationsDB.Integrations.dbo.FSI_Intercompany_ARAP FS ON CM.CompanyId = FS.Company AND CM.CustNmbr = FS.Account AND FS.RecordType = 'C' AND FS.TransType = 'ICB'
		LEFT JOIN Companies C2 ON FS.LinkedCompany = C2.CompanyId
GO


