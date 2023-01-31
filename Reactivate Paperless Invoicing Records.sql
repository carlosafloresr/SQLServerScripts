SELECT	*
FROM	PaperlessInvoices
WHERE	Company = 'GLSO'
		AND InvoiceNumber IN (
								SELECT	InvoiceNumber
								UPDATE	FSI_ReceivedDetails
								SET		RecordStatus = 1
								WHERE	BatchId IN (
													SELECT	BatchId
													FROM	FSI_ReceivedHeader
													WHERE	WeekEndDate = '01/31/2015'
															AND Company = 'GLSO'
													)
							)