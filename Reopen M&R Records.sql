/****** Script for SelectTopNRows command from SSMS  ******/
UPDATE [GPCustom].[dbo].[ExpenseRecovery]
SET Expense = ABS(RECOVERY), Recovery =0, Closed = 0, Status = 'Open', StatusText = 'Open'
  WHERE EffDate = '06/29/2011'