/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (2000) [RecordId]
      ,[Integration]
      ,[Company]
      ,[BatchId]
      ,[CustomerVendor]
      ,[ApplyFrom]
      ,[ApplyTo]
      ,[ApplyAmount]
      ,[RecordType]
      ,[Processed]
  FROM [Integrations].[dbo].[Integrations_ApplyTo]
  where applyfrom = 'TIP0621181325'
		and RecordType = 'ap'

SELECT	*
FROM	Integrations_ApplyTo 
WHERE	Integration = 'TIPAR' 
		AND Company = 'GLSO' 
		AND BatchId = 'TIPAR0621181325'
		and ApplyAmount < 0

