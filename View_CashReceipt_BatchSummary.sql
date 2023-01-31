USE [GPCustom]
GO

/****** Object:  View [dbo].[View_CashReceipt_BatchSummary]    Script Date: 10/5/2021 9:23:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
SELECT * FROM View_CashReceipt_BatchSummary WHERE BatchId = 'LCKBX092921IREC-1' AND Company = 'IMCNA'
*/
ALTER VIEW [dbo].[View_CashReceipt_BatchSummary]
AS
SELECT	Company,
		NationalAccount,
		BatchId,
		CustomerNumber,
		--LEFT(BatchId, 10) + '_' + BatchConsecut + dbo.PADL(ROW_NUMBER() OVER(ORDER BY CheckNumber), 3, '0') AS DocumentNumber,
		CheckNumber,
		InvoiceNumber,
		Payment,
		Balance,
		[Difference] = (Payment - Balance),
		CASE	WHEN InvoiceNumber IS Null THEN 2 -- The invoice is unmatched
				WHEN Balance = 0 THEN 3 -- The invoice is fully paid already
				WHEN Payment = Balance THEN 4 -- Perfect match
				WHEN Payment > Balance THEN 5 -- Payment grather than current balance
				WHEN Payment < (Balance - 5) THEN 6 -- Underpaid
				WHEN ABS(Payment - Balance) <= 5 THEN 7 -- Writeoff
				ELSE 1 END AS Status -- Undefined
FROM	(
		SELECT	Company,
				NationalAccount,
				BatchId,
				CustomerNumber,
				CheckNumber,
				InvoiceNumber,
				BatchConsecut = IIF(dbo.AT('-', RIGHT(BatchId, 3), 1) > 0, dbo.PADL(RTRIM(SUBSTRING(BatchId, dbo.AT('-', BatchId, 1) + 1, 2)), 2, '0'), '00'),
				MAX(Payment) AS Payment,
				MAX(InvBalance) AS Balance
		FROM	View_CashReceipt
		GROUP BY
				Company,
				BatchId,
				CustomerNumber,
				NationalAccount,
				CheckNumber,
				InvoiceNumber
		) DATA
GO

