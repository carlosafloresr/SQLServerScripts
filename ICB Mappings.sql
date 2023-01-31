/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [Company]
      ,[LinkedCompany]
      ,IIF([RecordType] = 'C', 'Customer', 'Vendor') AS [RecordType]
      ,[Account]
FROM	[Integrations].[dbo].[FSI_Intercompany_ARAP]
WHERE	Company <> 'FI'
		and TransType = 'icb'
ORDER BY Company, LinkedCompany, RecordType

SELECT [ForCompany]
      ,[LinkedCompany]
	  ,IIF(LinkType = 'P', 'Payables', 'Receivables') AS [LinkType]
      ,[AccountNumber]
  FROM [Integrations].[dbo].[FSI_Intercompany_Companies]
  where Transtype = 'icb'
  ORDER BY ForCompany, LinkedCompany, LinkType