SELECT	* --CAST(RecordId AS Varchar) + ','
FROM	(
		SELECT	*,
				CASE WHEN GPAmount = 0 AND DiffDetail = 0 THEN 'Missing'
					 WHEN SWSAmount = ABS(GPAmount) AND DiffAmount = (SWSAmount * 2) THEN 'Reversal/Transaction'
					 WHEN SWSAmount = ABS(GPAmount) THEN 'Reversal'
					 WHEN DiffDetail <> 0 THEN 'Partial'
				ELSE '' END AS RecordType
		FROM	(
				SELECT	Company,
						Invoice,
						Amount AS SWSAmount,
						GPAmount,
						Amount - GPAmount AS DiffAmount,
						IIF(Amount - ABS(GPAmount) <> 0 AND ABS(GPAmount) > 0, Amount - ABS(GPAmount), 0) AS DiffDetail
				FROM	FSI_MissingInvoices
				WHERE	Company = 'GLSO'
				) DATA
		) DAT
		INNER JOIN View_FSI_NonSale FSI ON DAT.Company = FSI.Company AND DAT.Invoice = FSI.InvoiceNumber
--WHERE	RecordType = 'Partial'
WHERE	DiffAmount = Amount
--ORDER BY 10,11
