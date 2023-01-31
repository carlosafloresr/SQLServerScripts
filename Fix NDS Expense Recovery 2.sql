DECLARE	@ProNumber	Varchar(25) = 'ISN0000141',
		@FixIt		Bit = 0

SELECT	CompanyId,
		AccountNumber,
		EscrowTransactionId,
		Amount,
		ProNumber,
		SOPDocumentNumber,
		PostingDate
FROM	View_EscrowTransactions
WHERE	CompanyId = 'NDS'
		AND Fk_EscrowModuleId = 5
		AND AccountNumber = '22-11-1107'
		AND (ProNumber = @ProNumber
		OR SOPDocumentNumber = @ProNumber)
		AND (ProNumber = SOPDocumentNumber
		OR SOPDocumentNumber IS Null)

SELECT	CompanyId,
		AccountNumber,
		EscrowTransactionId,
		Amount,
		ProNumber,
		SOPDocumentNumber,
		PostingDate
FROM	View_EscrowTransactions
WHERE	CompanyId = 'NDS'
		AND Fk_EscrowModuleId = 5
		AND AccountNumber = '22-11-1107'
		AND (ProNumber = @ProNumber
		OR SOPDocumentNumber = @ProNumber)
		AND (ProNumber <> SOPDocumentNumber
		AND SOPDocumentNumber IS NOT Null)

IF @FixIt = 1
BEGIN
	UPDATE	EscrowTransactions
	SET		ProNumber = SOPDocumentNumber
	WHERE	CompanyId = 'NDS'
			AND Fk_EscrowModuleId = 5
			AND AccountNumber = '22-11-1107'
			AND (ProNumber = @ProNumber
			OR SOPDocumentNumber = @ProNumber)
			AND (ProNumber <> SOPDocumentNumber
			AND SOPDocumentNumber IS NOT Null)

	UPDATE	EscrowTransactionsHistory
	SET		ProNumber = SOPDocumentNumber
	WHERE	CompanyId = 'NDS'
			AND Fk_EscrowModuleId = 5
			AND AccountNumber = '22-11-1107'
			AND (ProNumber = @ProNumber
			OR SOPDocumentNumber = @ProNumber)
			AND (ProNumber <> SOPDocumentNumber
			AND SOPDocumentNumber IS NOT Null)
END
--SELECT	SUM(Amount) as Amount
--FROM	View_EscrowTransactions
--WHERE	CompanyId = 'NDS'
--		AND Fk_EscrowModuleId = 5
--		AND AccountNumber = '22-11-1107'
--		AND (ProNumber = @ProNumber
--		OR SOPDocumentNumber = @ProNumber)
--		AND (ProNumber = SOPDocumentNumber
--		OR SOPDocumentNumber IS Null)
/*
UPDATE	EscrowTransactions
SET		ProNumber = 'HAPAG 2%'
WHERE	ProNumber = 'HAPAG-2%'
ESCROWTRANSACTIONID = 1981506

UPDATE	EscrowTransactionsHistory
SET		ProNumber = '96-70189'
WHERE	EscrowTransactionId = 729692
*/

