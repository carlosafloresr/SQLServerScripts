SELECT	DISTINCT FSI.BatchId,
		FSI.InvoiceNumber,
		FSI.RecordCode,
		FSI.ChargeAmount1,
		FSI.ICB_AP,
		FSI.PrePay,
		ISNULL(FSI.PrePayType, '') AS PrePayType,
		FSI.PierPassType,
		FSI.AccCode,
		FSI.PrepayReference,
		FSI.VndIntercompany,
		FIN.AccountNumber AS CreditAccount,
		FIN.InterAccount AS DebitAccount,
		CASE WHEN FSI.ICB_AP = 1 THEN 'ICB'
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' THEN 'PREPAY'
			 WHEN FSI.PierPassType = 1 THEN 'PIERPASS'
			 ELSE 'VENDOR PAY' END AS TransactionType
FROM	View_Integration_FSI_Full FSI
		LEFT JOIN View_FSI_Intercompany FIN ON FSI.Company = FIN.Company AND FSI.BatchId = FIN.OriginalBatchId AND FSI.InvoiceNumber = FIN.InvoiceNumber AND FIN.[Source] = 'AP'
		--INNER JOIN View_FSI_NonSale FSI ON DAT.Company = FSI.Company AND DAT.Invoice = FSI.InvoiceNumber
WHERE	FSI.Company = 'GLSO' 
		AND FSI.BatchId = '9FSI20201221_1510'
		AND FSI.RecordType = 'VND'
		--and ICB_AP = 1
		AND FSI.InvoiceNumber = '95-169420_T'

--ORDER BY FSI.BATCHID, DAT.Invoice

/*
SELECT	*
FROM	View_Integration_FSI_Full
WHERE	InvoiceNumber IN ('57-137946','58-120696','58-122269','58-122534','58-122796','58-122797')
*/