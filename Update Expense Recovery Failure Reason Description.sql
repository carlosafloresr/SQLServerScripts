UPDATE	ExpenseRecovery
SET		ExpenseRecovery.FailureReason = DATA.FailureReason
FROM	(
		SELECT	ExpenseRecoveryId,
				ISNULL(LTRIM(UPPER(SUBSTRING(Reference, dbo.RAT('|', Reference, 1) + 1, 20))), FailureReason) AS FailureReason
		FROM	ExpenseRecovery
		WHERE	LEFT(VoucherNo, 3) IN ('RSA', 'IDV')
		) DATA
WHERE	ExpenseRecovery.ExpenseRecoveryId = DATA.ExpenseRecoveryId
		AND ExpenseRecovery.FailureReason <> DATA.FailureReason