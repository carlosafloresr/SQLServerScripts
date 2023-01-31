/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [Company] AS SourceCompany
      ,[LinkedCompany] AS 'ICB_Company'
      ,CASE WHEN [RecordType] = 'C' THEN 'CUSTOMER' ELSE 'VENDOR' END AS [RecordType]
      ,[Account]
  FROM [Integrations].[dbo].[FSI_Intercompany_ARAP]
  where TransType = 'ICB'
  ORDER BY Company, LinkedCompany, RecordType, aCCOUNT