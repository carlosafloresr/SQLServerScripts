UPDATE	ExpenseRecovery
SET		EffDate = DEX.PstgDate
FROM	(
			SELECT	EX.ExpenseRecoveryId
					,EX.Company
					,EX.VoucherNo
					,EX.DocNumber
					,EX.EffDate
					,AP.PstgDate
			FROM	ExpenseRecovery EX
					INNER JOIN ILSINT02.Integrations.dbo.Integrations_AP AP ON AP.Integration = 'DXP' AND EX.PopUpId = AP.PopUpId
			WHERE	EX.Closed = 0
		) DEX
WHERE	ExpenseRecovery.ExpenseRecoveryId = DEX.ExpenseRecoveryId

/*
SELECT	EX.ExpenseRecoveryId
		,EX.Company
		,EX.VoucherNo
		,EX.DocNumber
		,EX.EffDate
		,AP.PstgDate
		,EX.CreationDate
FROM	ExpenseRecovery EX
		INNER JOIN ILSINT02.Integrations.dbo.Integrations_AP AP ON AP.Integration = 'DXP' AND EX.PopUpId = AP.PopUpId
WHERE	EX.Closed = 0
ORDER BY EX.CreationDate DESC
*/