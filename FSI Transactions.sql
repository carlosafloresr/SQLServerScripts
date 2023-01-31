SELECT	Company,
		BatchId,
		WeekendDate,
		InvoiceNumber,
		InvoiceDate,
		Amount,
		TransType,
		IntegrationType,
		CreditAccount,
		DebitAccount
FROM	FSI_TransactionDetails 
WHERE	BatchId = '9FSI20220613_1623'
		AND TransType = 'DEMURRAGE'
order by TransType

-- IILOGISTICS\tgerlich