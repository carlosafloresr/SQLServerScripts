SELECT * 
FROM	ILSGP01T.GPCustom.dbo.EscrowTransactions 
WHERE	EscrowTransactionId NOT IN (SELECT EscrowTransactionId FROM GPCustom.dbo.EscrowTransactions)

--SELECT top 10 * FROM ILSGP01T.GPCustom.dbo.EscrowTransactions