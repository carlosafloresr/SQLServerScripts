SELECT	BatchId, IntegrationType, TransType, CreditAccount, DebitAccount, FORMAT(SUM(Amount), 'C', 'en-us') AS Amount --GL_BatchId
FROM	FSI_TransactionDetails
WHERE	BatchId LIKE '9FSI20210817_1202'
GROUP BY BatchId, IntegrationType, TransType, CreditAccount, DebitAccount
ORDER BY BatchId, IntegrationType, TransType, CreditAccount, DebitAccount

