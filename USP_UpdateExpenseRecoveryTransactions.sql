CREATE PROCEDURE USP_UpdateExpenseRecoveryTransactions
AS
UPDATE	GPCustom.dbo.ExpenseRecovery
SET		EFfDate = DATA.POSTEDDT
FROM	(
		SELECT	ERT.ExpenseRecoveryId,
				APH.POSTEDDT
		FROM	PM20000 APH
				INNER JOIN PM10100 APD ON APH.VCHRNMBR = APD.VCHRNMBR AND APH.TRXSORCE = APD.TRXSORCE
				INNER JOIN GL00105 GLA ON APD.DSTINDX = GLA.ACTINDX
				INNER JOIN GPCustom.dbo.ExpenseRecovery ERT ON APH.VCHRNMBR = ERT.VoucherNo AND APD.DEBITAMT = ERT.Expense AND ERT.EffDate IS Null AND ERT.Closed = 0 AND GLA.ACTNUMST = ERT.GLAccount
		UNION
		SELECT	ERT.ExpenseRecoveryId,
				APH.POSTEDDT
		FROM	PM30200 APH
				INNER JOIN PM30600 APD ON APH.VCHRNMBR = APD.VCHRNMBR AND APH.TRXSORCE = APD.TRXSORCE
				INNER JOIN GL00105 GLA ON APD.DSTINDX = GLA.ACTINDX
				INNER JOIN GPCustom.dbo.ExpenseRecovery ERT ON APH.VCHRNMBR = ERT.VoucherNo AND APD.DEBITAMT = ERT.Expense AND ERT.EffDate IS Null AND ERT.Closed = 0 AND GLA.ACTNUMST = ERT.GLAccount
		) DATA
WHERE	ExpenseRecovery.ExpenseRecoveryId = DATA.ExpenseRecoveryId