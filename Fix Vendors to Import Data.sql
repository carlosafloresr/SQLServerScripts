/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [VendorCode]
      ,[VendorType]
      ,[VendorName]
      ,[Address]
      ,[Address2]
      ,[City]
      ,[State]
      ,[ZipCode]
      ,[AccountNo]
      ,[Contact]
      ,[Phone]
      ,[Fax]
FROM [GPCustom].[dbo].[PTS_Vendors_List]

/*
  UPDATE	PTS_Vendors_List
  SET		Phone = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Phone, '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''), 'EXT', ''), 'X', ''),
			Fax = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Fax, '(', ''), ')', ''), '-', ''), '.', ''), ' ', ''), 'EXT', ''), 'X', '')
*/