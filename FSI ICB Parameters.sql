/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [ForCompany] AS Company
      ,IIF([LinkType] = 'P', 'Payable','Receivable') AS LinkType
      ,[LinkedCompany]
      ,[AccountNumber]
  FROM [Integrations].[dbo].[FSI_Intercompany_Companies]
  where Transtype = 'ICB'
  ORDER BY ForCompany, LinkedCompany, LinkType