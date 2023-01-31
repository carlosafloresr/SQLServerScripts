SELECT	*
FROM	ExpenseRecovery
WHERE	InvDate IS NULL
		--AND Company = 'DNJ'
		
		SELECT * FROM DNJ.dbo.PM20000 WHERE VCHRNMBR IN ('IDV25133400150221','IDV25133400150221','IDV25133400150228','IDV25133400150222')

UPDATE	ExpenseRecovery
SET		ExpenseRecovery.InvDate = RECS.DOCDATE,
		ExpenseRecovery.EffDate = RECS.POSTEDDT
FROM	(
		SELECT	ER.ExpenseRecoveryId
				,AP.DOCDATE
				,AP.POSTEDDT
		FROM	ExpenseRecovery ER
				INNER JOIN GIS.dbo.PM30200 AP ON ER.VoucherNo = AP.VCHRNMBR
		WHERE	ER.InvDate IS NULL
				AND ER.Company = 'GIS'
		UNION
		SELECT	ER.ExpenseRecoveryId
				,AP.DOCDATE
				,AP.POSTEDDT
		FROM	ExpenseRecovery ER
				INNER JOIN GIS.dbo.PM20000 AP ON ER.VoucherNo = AP.VCHRNMBR
		WHERE	ER.InvDate IS NULL
				AND ER.Company = 'GIS'
		) RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId
