/****** Script for SelectTopNRows command from SSMS  ******/
SELECT Company
      ,Customer
      ,AccountType AS AccountTypeCode
      ,CASE	WHEN AccountType = 1 THEN 'Maintenance and Repairs'
      WHEN AccountType = 2 THEN 'Tire Repairs'
      ELSE 'Tire Replacements' END AS AccountType
      ,AccountNumber
      ,CASE WHEN Limit > 1000 THEN NULL ELSE Limit END AS LIMIT
      ,CASE WHEN Equipment = 'CH' THEN 'Chassis' WHEN Equipment = 'CO' THEN 'Container' ELSE '' END AS Equipment
      ,CASE WHEN CompanyEquipment IS Null THEN '' WHEN CompanyEquipment = 0 THEN 'Customer Equipment' ELSE 'Company Equipment' END AS CompanyEquipment
      ,Intercompany
FROM	Integrations.dbo.MSR_Accounts