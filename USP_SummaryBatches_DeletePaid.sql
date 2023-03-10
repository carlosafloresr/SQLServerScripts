/*
SELECT [RecId]
      ,[Company]
      ,[Inv_No]
      ,[Inv_Date]
      ,[Acct_No]
      ,[Inv_Total]
      ,[Inv_Mech]
      ,[Container]
      ,[Chassis]
      ,[Inv_Batch]
      ,[ProcessDate]
      ,[Processed]
  FROM [Integrations].[dbo].[SummaryBatches]
  
  TRUNCATE TABLE [SummaryBatches]
  */

alter PROCEDURE USP_SummaryBatches_DeletePaid
AS
DELETE	SummaryBatches 
WHERE	Processed = 0 
		AND 'I' + Inv_No NOT IN (SELECT DocNumbr FROM ILSGP01.FI.dbo.RM20101 WHERE LEFT(DocNumbr, 1) = 'I' AND CustNmbr IN (SELECT CustomerId FROM ILSGP01.GPCustom.dbo.SummaryCustomers WHERE Company = 'FI'))

