/*
EXECUTE USP_FixExpenseRecoveryDocuments
*/
ALTER PROCEDURE USP_FixExpenseRecoveryDocuments
AS
UPDATE	ExpenseRecovery
SET		ExpenseRecovery.DocNumber = RECS.DOCNUMBR
FROM	(
		SELECT	ExpenseRecoveryId, VoucherNo, ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR) AS DOCNUMBR
		FROM	ExpenseRecovery
				LEFT JOIN AIS..PM20000 ON ExpenseRecovery.VoucherNo = PM20000.VCHRNMBR
				LEFT JOIN AIS..PM30200 ON ExpenseRecovery.VoucherNo = PM30200.VCHRNMBR
		WHERE	Company = 'AIS'
				AND DocNumber = '') RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId

UPDATE	ExpenseRecovery
SET		ExpenseRecovery.DocNumber = RECS.DOCNUMBR
FROM	(
		SELECT	ExpenseRecoveryId, VoucherNo, ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR) AS DOCNUMBR
		FROM	ExpenseRecovery
				LEFT JOIN IMC..PM20000 ON ExpenseRecovery.VoucherNo = PM20000.VCHRNMBR
				LEFT JOIN IMC..PM30200 ON ExpenseRecovery.VoucherNo = PM30200.VCHRNMBR
		WHERE	Company = 'IMC'
				AND DocNumber = '') RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId

UPDATE	ExpenseRecovery
SET		ExpenseRecovery.DocNumber = RECS.DOCNUMBR
FROM	(
		SELECT	ExpenseRecoveryId, VoucherNo, ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR) AS DOCNUMBR
		FROM	ExpenseRecovery
				LEFT JOIN GIS..PM20000 ON ExpenseRecovery.VoucherNo = PM20000.VCHRNMBR
				LEFT JOIN GIS..PM30200 ON ExpenseRecovery.VoucherNo = PM30200.VCHRNMBR
		WHERE	Company = 'GIS'
				AND DocNumber = '') RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId

UPDATE	ExpenseRecovery
SET		ExpenseRecovery.DocNumber = RECS.DOCNUMBR
FROM	(
		SELECT	ExpenseRecoveryId, VoucherNo, ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR) AS DOCNUMBR
		FROM	ExpenseRecovery
				LEFT JOIN NDS..PM20000 ON ExpenseRecovery.VoucherNo = PM20000.VCHRNMBR
				LEFT JOIN NDS..PM30200 ON ExpenseRecovery.VoucherNo = PM30200.VCHRNMBR
		WHERE	Company = 'NDS'
				AND DocNumber = '') RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId

UPDATE	ExpenseRecovery
SET		ExpenseRecovery.DocNumber = RECS.DOCNUMBR
FROM	(
		SELECT	ExpenseRecoveryId, VoucherNo, ISNULL(PM20000.DOCNUMBR, PM30200.DOCNUMBR) AS DOCNUMBR
		FROM	ExpenseRecovery
				LEFT JOIN DNJ..PM20000 ON ExpenseRecovery.VoucherNo = PM20000.VCHRNMBR
				LEFT JOIN DNJ..PM30200 ON ExpenseRecovery.VoucherNo = PM30200.VCHRNMBR
		WHERE	Company = 'DNJ'
				AND DocNumber = '') RECS
WHERE	ExpenseRecovery.ExpenseRecoveryId = RECS.ExpenseRecoveryId

/*
SELECT	*
FROM	AIS..PM20000
WHERE	VCHRNMBR = '00000000000024389'
*/