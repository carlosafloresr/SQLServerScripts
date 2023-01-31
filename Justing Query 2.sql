/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [IntegrationSOPId]
      ,[Integration]
      ,[Company]
      ,[INVOICETYPE]
      ,[BACHNUMB]
      ,[SOPTYPE]
      ,[DOCID]
      ,[SOPNUMBE]
      ,[TRXDSCRN]
      ,[DOCDATE]
      ,[CUSTNMBR]
      ,[DOCAMNT]
      ,[SUBTOTAL]
      ,[ITEMNMBR]
      ,[QUANTITY]
      ,[UNITPRICE]
      ,[DISTTYPE]
      ,[ACTNUMST]
      ,[DEBITAMT]
      ,[CRDTAMNT]
      ,[DistRef]
      ,[PostingDate]
      ,[IsFee]
      ,[ProNumber]
      ,[Chassis]
      ,[Container]
      ,[VendorId]
      ,[DriverId]
      ,[VendorName]
      ,[InvoiceNumber]
      ,[Reference]
      ,[InDate]
      ,[OutDate]
      ,[FreeTime]
      ,[Processed]
      ,[PopUpId]
  FROM [Integrations].[dbo].[Integrations_SOP]
  where SOPNUMBE = 'DM-G6105'