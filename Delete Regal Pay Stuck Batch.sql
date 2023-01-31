/****** Script for SelectTopNRows command from SSMS  ******/
SELECT	*
FROM	[PaymentTransactions]
WHERE	BatchID LIKE '1000000591'
		AND CheckNumber IN ('EFT000000004525')

  -- DELETE FROM PaymentTransactions where BatchID = '1000000591' and CheckNumber IN ('EFT000000004525')