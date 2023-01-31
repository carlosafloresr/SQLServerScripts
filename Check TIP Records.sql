SELECT	Company,
		BatchId,
		WeekEndDate,
		BooksAccount AS CustVend,
		InvoiceNumber,
		LinkedCompany,
		Amount,
		AccountNumber AS CreditAccount,
		InterAccount AS DebitAccount,
		Description,
		Division,
		ICB,
		PrePay,
		Source
FROM	View_FSI_Intercompany 
WHERE	OriginalBatchId IN ('1FSI20201216_1020')

/*
SELECT BATCHID, COUNT(*) AS Count FROM FSI_ReceivedDetails WHERE BatchId LIKE '1FSI202012%' AND ICB = 1 GROUP BY BATCHID
*/