/*
SELECT [EscrowInterestId]
      ,[CompanyId]
      ,[AccountIndex]
      ,[AccountNumber]
      ,[DriverClass]
      ,[VendorId]
      ,[Period]
      ,[DateIni]
      ,[DateEnd]
      ,[AmountInvested]
      ,[InterestRate]
      ,[InterestAmount]
      ,[Approved]
      ,[CreatedOn]
      ,[CreatedBy]
      ,[BatchId]
      ,[Processed]
      ,[msrepl_tran_version]
  FROM [GPCustom].[dbo].[EscrowInterest]
  where [AccountNumber] = '0-02-2790' AND CompanyId = 'IMC' AND Period = '201002'
*/
  update [GPCustom].[dbo].[EscrowInterest]
  set approved = 1
  where [AccountNumber] = '0-02-2790' AND CompanyId = 'GIS' AND Period = '201002'