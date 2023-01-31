--SELECT	VCHRNMBR
--FROM	PM20000 PMD
--WHERE	PMD.BACHNUMB = 'OOSDNJ_121213'

UPDATE	OOS_Transactions
SET		Processed = CASE WHEN DATA.VCHRNMBR IS NULL THEN 0 ELSE 1 END
FROM	(
		SELECT	DISTINCT OOS.TransactionId,
				PMD.VCHRNMBR
		FROM	GPCustom.dbo.View_OOS_Transactions OOS
				INNER JOIN DNJ..PM20000 PMD ON OOS.Invoice = PMD.VCHRNMBR
		WHERE	BATCHID = 'OOSDNJ_121213'
		UNION
		SELECT	DISTINCT OOS.TransactionId,
				PMD.VCHRNMBR
		FROM	GPCustom.dbo.View_OOS_Transactions OOS
				INNER JOIN DNJ..PM30200 PMD ON OOS.Invoice = PMD.VCHRNMBR
		WHERE	BATCHID = 'OOSDNJ_121213'
		) DATA
WHERE	OOS_Transactions.OOS_TransactionId = DATA.TransactionId

-- EXECUTE GPCustom..USP_OOS_Transactions 'DNJ', 'OOSDNJ_121213'