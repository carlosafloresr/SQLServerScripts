UPDATE	ExpenseRecovery
SET		ExpenseRecovery.Reference = RECS.DISTREF
FROM	(
		SELECT	ER.ExpenseRecoveryId,
				AP.DISTREF
		FROM	ILSINT01.Integrations.dbo.Integrations_AP AP
				INNER JOIN ExpenseRecovery ER ON AP.VCHNUMWK = ER.VoucherNo AND ER.Source = 'AP' AND ER.GLAccount = AP.ACTNUMST
		WHERE	AP.Integration = 'DXP'
				AND AP.DISTREF <> ER.Reference
				AND ER.Reference = 'AP Credit'
		) RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId
/*
SELECT	*
FROM	ILSINT01.Integrations.dbo.Integrations_AP AP
WHERE	AP.Integration = 'DXP'

SELECT	*
FROM	ExpenseRecovery
*/